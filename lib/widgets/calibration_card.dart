import 'package:flutter/material.dart';
import '../models/calibration.dart';

class CalibrationCard extends StatelessWidget {
  final Calibration calibration;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExportAll;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportCsv;
  final bool separateExport;

  const CalibrationCard({
    super.key,
    required this.calibration,
    required this.onEdit,
    required this.onDelete,
    required this.onExportAll,
    this.onExportPdf,
    this.onExportCsv,
    required this.separateExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Color(0xFF2979FF), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    calibration.client.isNotEmpty ? calibration.client : 'Без имени',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (separateExport) ...[
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.orange, size: 22),
                    tooltip: 'Экспорт PDF',
                    onPressed: onExportPdf,
                  ),
                  IconButton(
                    icon: const Icon(Icons.table_chart, color: Colors.green, size: 22),
                    tooltip: 'Экспорт CSV',
                    onPressed: onExportCsv,
                  ),
                ] else
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Color(0xFF4CAF50), size: 22),
                    tooltip: 'Экспорт PDF + CSV',
                    onPressed: onExportAll,
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF2979FF), size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outlined, color: Color(0xFFEF5350), size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pin, size: 16, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text('Г.Р.З: ${calibration.grz}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(calibration.date, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
