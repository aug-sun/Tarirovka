import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calibration.dart';
import '../models/app_settings.dart';

class StorageService {
  static const _key = 'app_storage_v1';

  Future<Map<String, dynamic>> _loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str == null || str.isEmpty) return _defaults();
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return _defaults();
    }
  }

  Map<String, dynamic> _defaults() => {
    'user_name': 'Иван Иванов',
    'company_name': 'ООО «Сантел Сервис»',
    'dark_mode': false,
    'separate_export': false,
    'calibrations': <Map<String, dynamic>>[],
  };

  Future<void> _saveRaw(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<AppSettings> loadSettings() async {
    final raw = await _loadRaw();
    return AppSettings.fromJson(raw);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final raw = await _loadRaw();
    raw['user_name'] = settings.userName;
    raw['company_name'] = settings.companyName;
    raw['dark_mode'] = settings.darkMode;
    raw['separate_export'] = settings.separateExport;
    await _saveRaw(raw);
  }

  Future<List<Calibration>> loadCalibrations() async {
    final raw = await _loadRaw();
    final list = raw['calibrations'] as List<dynamic>? ?? [];
    return list.map((e) => Calibration.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCalibrations(List<Calibration> cals) async {
    final raw = await _loadRaw();
    raw['calibrations'] = cals.map((e) => e.toJson()).toList();
    await _saveRaw(raw);
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
