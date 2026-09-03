import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportService {
  static Future<bool> requestPermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) return true;
    final manage = await Permission.manageExternalStorage.request();
    return manage.isGranted;
  }

  /// 1. Возвращает публичную папку /storage/emulated/0/Documents/Tarirovka (Android)
  static Future<String> getExportDirectory() async {
    Directory? base;
    if (Platform.isAndroid) {
      base = Directory('/storage/emulated/0/Documents');
      if (!await base.exists()) {
        base = await getExternalStorageDirectory();
      }
    } else {
      base = await getApplicationDocumentsDirectory();
    }

    final path = '${base?.path ?? ''}/Tarirovka';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  /// 2. Открывает системный проводник Android (SAF) для выбора места сохранения
  static Future<String?> saveFileWithPicker({
    required List<int> bytes,
    required String fileName,
  }) async {
    return await FilePicker.platform.saveFile(
      dialogTitle: 'Выберите папку для сохранения $fileName',
      fileName: fileName,
      bytes: Uint8List.fromList(bytes),
    );
  }

  static String safeFilename(String text) {
    return text.replaceAll(RegExp(r'[\\/*?:"<>| ]'), '_');
  }
}