import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/calibration.dart';
import '../models/tank.dart';
import '../models/app_settings.dart';
import 'export_service.dart';

class PdfService {
  static Future<pw.Font?> _tryLoadCustomFont() async {
    try {
      final data = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return null;
    }
  }

  static Future<Uint8List> generatePdfBytes(Calibration cal, AppSettings settings) async {
    final font = await _tryLoadCustomFont() ?? pw.Font.helvetica();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => _buildContent(cal, settings, font),
      ),
    );

    return await pdf.save();
  }

  static Future<void> export(Calibration cal, AppSettings settings, String dirPath) async {
    final bytes = await generatePdfBytes(cal, settings);
    final client = ExportService.safeFilename(cal.client);
    final grz = ExportService.safeFilename(cal.grz);
    final date = ExportService.safeFilename(cal.date);
    final filename = '${client}_${grz}_${date}.pdf';
    final file = File('$dirPath/$filename');
    await file.writeAsBytes(bytes);
  }

  static List<pw.Widget> _buildContent(Calibration cal, AppSettings settings, pw.Font font) {
    final widgets = <pw.Widget>[];
    final style16 = pw.TextStyle(font: font, fontSize: 16);
    final style11 = pw.TextStyle(font: font, fontSize: 11);
    final style10 = pw.TextStyle(font: font, fontSize: 10);

    widgets.add(pw.Center(child: pw.Text('ПАСПОРТ СЕРТИФИКАТА ТАРИРОВКИ', style: style16)));
    widgets.add(pw.SizedBox(height: 4));
    widgets.add(pw.Text('Организация: ${settings.companyName}', style: style10));
    widgets.add(pw.Text('Клиент: ${cal.client}', style: style10));
    widgets.add(pw.Text('Адрес проведения работ: ${cal.workAddress}', style: style10));
    widgets.add(pw.Text('Дата: ${cal.date}', style: style10));
    widgets.add(pw.Text('ТС: ${cal.carModel} (Г.Р.З: ${cal.grz})', style: style10));
    widgets.add(pw.Text('АТ: ${cal.atModel} | IMEI: ${cal.atImei}', style: style10));
    widgets.add(pw.SizedBox(height: 6));

    final tanks = cal.tanks;
    for (int i = 0; i < tanks.length; i += 2) {
      final tank1 = tanks[i];
      final tank2 = i + 1 < tanks.length ? tanks[i + 1] : null;

      widgets.add(pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _buildTankSection(tank1, font)),
          if (tank2 != null) pw.SizedBox(width: 20),
          if (tank2 != null) pw.Expanded(child: _buildTankSection(tank2, font)),
        ],
      ));
      widgets.add(pw.SizedBox(height: 10));
    }

    widgets.add(pw.SizedBox(height: 5));
    widgets.add(pw.Text('Специалист: ${settings.userName}', style: style11));
    return widgets;
  }

  static pw.Widget _buildTankSection(Tank tank, pw.Font font) {
    final style11 = pw.TextStyle(font: font, fontSize: 11);
    final style9 = pw.TextStyle(font: font, fontSize: 9);

    final rawRows = tank.table;
    final isSplit = rawRows.length > 25;

    List<List<String>> headers;
    List<List<String>> rows;
    List<double> widths;

    if (!isSplit) {
      headers = [['У.Е.', 'Литры']];
      rows = rawRows.map((r) => [r.ue, r.liters]).toList();
      widths = [45, 45];
    } else {
      final mid = (rawRows.length + 1) ~/ 2;
      final left = rawRows.sublist(0, mid);
      final right = rawRows.sublist(mid);
      headers = [['У.Е.', 'Литры', 'У.Е.', 'Литры']];
      rows = [];
      final maxLen = left.length > right.length ? left.length : right.length;
      for (int i = 0; i < maxLen; i++) {
        final row = <String>[];
        if (i < left.length) {
          row.add(left[i].ue);
          row.add(left[i].liters);
        } else {
          row.addAll(['', '']);
        }
        if (i < right.length) {
          row.add(right[i].ue);
          row.add(right[i].liters);
        } else {
          row.addAll(['', '']);
        }
        rows.add(row);
      }
      widths = [22.5, 22.5, 22.5, 22.5];
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Таблица: ${tank.name}', style: style11),
        pw.SizedBox(height: 2),
        pw.Text('ДУТ: ${tank.dutModel} [S/N: ${tank.dutSn}]', style: style9),
        pw.Text('Длина ДУТ: ${tank.dutLength} мм | Глубина бака: ${tank.tankDepth} мм', style: style9),
        pw.Text('Ёмкость бака: ${tank.tankCapacity} л | Степень фильтр.: ${tank.filtrationDegree}', style: style9),
        pw.Text('Пломба (корпус): ${tank.sealBody}', style: style9),
        pw.Text('Пломба (разъем): ${tank.sealConnector}', style: style9),
        pw.SizedBox(height: 4),
        _buildPdfTable(headers, rows, widths, font),
        pw.SizedBox(height: 4),
        pw.Text('Расположение датчика:', style: style9),
        _buildTankShape(tank),
      ],
    );
  }

  static pw.Widget _buildPdfTable(List<List<String>> headers, List<List<String>> rows, List<double> widths, pw.Font font) {
    final style9 = pw.TextStyle(font: font, fontSize: 9);
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {for (int i = 0; i < widths.length; i++) i: pw.FixedColumnWidth(widths[i])},
      children: [
        ...headers.map((h) => pw.TableRow(
          children: h.map((cell) => pw.Center(
            child: pw.Text(cell, style: style9),
          )).toList(),
        )),
        ...rows.map((r) => pw.TableRow(
          children: r.map((cell) => pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Text(cell, style: style9),
          )).toList(),
        )),
      ],
    );
  }

  static pw.Widget _buildTankShape(Tank tank) {
    final relX = ((tank.sensorX - 10) / 350).clamp(0.0, 1.0);
    final relY = ((tank.sensorY - 10) / 120).clamp(0.0, 1.0);
    return pw.Container(
      width: 60,
      height: 20,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Stack(
        children: [
          pw.Positioned(
            left: relX * 60 - 1.5,
            top: relY * 20 - 1.5,
            child: pw.Container(
              width: 3,
              height: 3,
              decoration: const pw.BoxDecoration(
                color: PdfColors.red,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}