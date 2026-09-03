import 'dart:io';
import 'dart:convert';
import '../models/calibration.dart';
import 'export_service.dart';

class CsvService {
  static List<int> generateCsvBytes(List<dynamic> rowsData) {
    final buffer = StringBuffer();
    buffer.writeCharCode(0xFEFF); // UTF-8 BOM
    for (final row in rowsData) {
      buffer.writeln('${row.ue};${row.liters}');
    }
    return utf8.encode(buffer.toString());
  }

  static Future<int> export(Calibration cal, String dirPath) async {
    int count = 0;
    final client = ExportService.safeFilename(cal.client);
    final grz = ExportService.safeFilename(cal.grz);
    final date = ExportService.safeFilename(cal.date);

    for (int i = 0; i < cal.tanks.length; i++) {
      final tank = cal.tanks[i];
      final tankName = ExportService.safeFilename(tank.name.isNotEmpty ? tank.name : 'Бак№${i + 1}');
      final filename = '${client}_${grz}_${tankName}_${date}.csv';
      final file = File('$dirPath/$filename');

      final bytes = generateCsvBytes(tank.table);
      await file.writeAsBytes(bytes);
      count++;
    }
    return count;
  }
}