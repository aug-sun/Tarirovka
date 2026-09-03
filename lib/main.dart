import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await StorageService().loadSettings();
  runApp(MyApp(initialDarkMode: settings.darkMode));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;

  const MyApp({super.key, required this.initialDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.initialDarkMode;
  }

  void _setDarkMode(bool v) => setState(() => _darkMode = v);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тарировка Бак-Контроль',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2979FF), brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2979FF), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: HomeScreen(onThemeChanged: _setDarkMode),
    );
  }
}
