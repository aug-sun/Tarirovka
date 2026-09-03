import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService();
  bool _darkMode = false;
  bool _separateExport = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _storage.loadSettings();
    setState(() {
      _darkMode = s.darkMode;
      _separateExport = s.separateExport;
    });
  }

  Future<void> _saveTheme(bool value) async {
    final s = await _storage.loadSettings();
    s.darkMode = value;
    await _storage.saveSettings(s);
    setState(() => _darkMode = value);
    widget.onThemeChanged(value);
  }

  Future<void> _saveSeparateExport(bool value) async {
    final s = await _storage.loadSettings();
    s.separateExport = value;
    await _storage.saveSettings(s);
    setState(() => _separateExport = value);
  }

  Future<void> _reset() async {
    await _storage.resetAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные сброшены. Перезапустите приложение.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        const Text('Настройки системы', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SwitchListTile(
          title: const Text('Темная тема оформления'),
          value: _darkMode,
          onChanged: _saveTheme,
        ),
        SwitchListTile(
          title: const Text('Раздельный импорт'),
          subtitle: const Text('Показывать отдельные кнопки для PDF и CSV'),
          value: _separateExport,
          onChanged: _saveSeparateExport,
        ),
        const Divider(),
        DropdownButtonFormField<String>(
          value: 'ru',
          selectedItemBuilder: (BuildContext context) {
            return [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Русский'),
              ),
            ];
          },
          items: const [
            DropdownMenuItem(
              value: 'ru',
              child: Text('Дохрена умный? Тебе и русского хватит'),
            ),
          ],
          onChanged: (_) {},
          decoration: const InputDecoration(
            labelText: 'Язык интерфейса',
          ),
        ),
        const Divider(height: 32),
        const Text('О приложении', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Row(children: [Text('Версия: '), Text('1.6.1', style: TextStyle(fontWeight: FontWeight.bold))]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Сбросить все данные'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1744),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}