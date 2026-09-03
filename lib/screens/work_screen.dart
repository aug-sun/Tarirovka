import 'package:flutter/material.dart';
import '../models/calibration.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import '../services/pdf_service.dart';
import '../services/csv_service.dart';
import '../widgets/calibration_card.dart';
import 'calibration_edit_screen.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  final _storage = StorageService();
  List<Calibration> _cals = [];
  AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cals = await _storage.loadCalibrations();
    final settings = await _storage.loadSettings();
    setState(() {
      _cals = cals;
      _settings = settings;
    });
  }

  Future<void> _delete(int index) async {
    _cals.removeAt(index);
    await _storage.saveCalibrations(_cals);
    setState(() {});
  }

  /// Экспорт с открытием системного диалога Android File Picker
  Future<void> _exportAll(int index) async {
    final cal = _cals[index];
    final client = ExportService.safeFilename(cal.client);
    final grz = ExportService.safeFilename(cal.grz);
    final date = ExportService.safeFilename(cal.date);

    try {
      final pdfBytes = await PdfService.generatePdfBytes(cal, _settings);
      final pdfSavedPath = await ExportService.saveFileWithPicker(
        bytes: pdfBytes,
        fileName: '${client}_${grz}_${date}.pdf',
      );

      if (pdfSavedPath != null) {
        _showSnack('PDF успешно сохранен');
      }

      for (int i = 0; i < cal.tanks.length; i++) {
        final tank = cal.tanks[i];
        final tankName = ExportService.safeFilename(tank.name.isNotEmpty ? tank.name : 'Бак№${i + 1}');
        final csvBytes = CsvService.generateCsvBytes(tank.table);
        await ExportService.saveFileWithPicker(
          bytes: csvBytes,
          fileName: '${client}_${grz}_${tankName}_${date}.csv',
        );
      }
    } catch (e) {
      _showSnack('Ошибка экспорта: $e');
    }
  }

  Future<void> _exportPdfOnly(int index) async {
    final cal = _cals[index];
    final client = ExportService.safeFilename(cal.client);
    final grz = ExportService.safeFilename(cal.grz);
    final date = ExportService.safeFilename(cal.date);

    try {
      final bytes = await PdfService.generatePdfBytes(cal, _settings);
      final savedPath = await ExportService.saveFileWithPicker(
        bytes: bytes,
        fileName: '${client}_${grz}_${date}.pdf',
      );
      if (savedPath != null) {
        _showSnack('PDF сохранен!');
      }
    } catch (e) {
      _showSnack('Ошибка: $e');
    }
  }

  Future<void> _exportCsvOnly(int index) async {
    final cal = _cals[index];
    final client = ExportService.safeFilename(cal.client);
    final grz = ExportService.safeFilename(cal.grz);
    final date = ExportService.safeFilename(cal.date);

    try {
      for (int i = 0; i < cal.tanks.length; i++) {
        final tank = cal.tanks[i];
        final tankName = ExportService.safeFilename(tank.name.isNotEmpty ? tank.name : 'Бак№${i + 1}');
        final bytes = CsvService.generateCsvBytes(tank.table);
        await ExportService.saveFileWithPicker(
          bytes: bytes,
          fileName: '${client}_${grz}_${tankName}_${date}.csv',
        );
      }
      _showSnack('CSV сохранен!');
    } catch (e) {
      _showSnack('Ошибка: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        children: [
          const SizedBox(height: 35),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalibrationEditScreen()),
            ).then((_) => _load()),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2979FF),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Создать новый файл тарировки',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_cals.isNotEmpty) ...[
            const Text('История тарировок:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(_cals.length, (index) {
              final reversedIndex = _cals.length - 1 - index;
              final cal = _cals[reversedIndex];
              return CalibrationCard(
                calibration: cal,
                separateExport: _settings.separateExport,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CalibrationEditScreen(
                      calibration: cal,
                      editIndex: reversedIndex,
                    ),
                  ),
                ).then((_) => _load()),
                onDelete: () => _delete(reversedIndex),
                onExportAll: () => _exportAll(reversedIndex),
                onExportPdf: _settings.separateExport ? () => _exportPdfOnly(reversedIndex) : null,
                onExportCsv: _settings.separateExport ? () => _exportCsvOnly(reversedIndex) : null,
              );
            }),
          ],
        ],
      ),
    );
  }
}