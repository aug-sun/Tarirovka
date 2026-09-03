import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = StorageService();
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _storage.loadSettings();
    setState(() {
      _nameCtrl.text = s.userName;
      _companyCtrl.text = s.companyName;
    });
  }

  Future<void> _save() async {
    final current = await _storage.loadSettings();
    final s = AppSettings(
      userName: _nameCtrl.text,
      companyName: _companyCtrl.text,
      darkMode: current.darkMode,
      separateExport: current.separateExport,
    );
    await _storage.saveSettings(s);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль успешно сохранен!')),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        const Text('Профиль сотрудника', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'ФИО Пользователя'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _companyCtrl,
          decoration: const InputDecoration(labelText: 'Организация установщик'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Сохранить изменения'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
