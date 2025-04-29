import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/settings_provider.dart';

class UnitsSettingsScreen extends StatefulWidget {
  const UnitsSettingsScreen({super.key});

  @override
  State<UnitsSettingsScreen> createState() => _UnitsSettingsScreenState();
}

class _UnitsSettingsScreenState extends State<UnitsSettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize dark mode value from the app's theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness = Theme.of(context).brightness;
      setState(() {
        _isDarkMode = brightness == Brightness.dark;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Настройки")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Единицы измерения",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SwitchListTile(
            title: Text("Градусы Цельсия (${settingsProvider.useCelsius ? '°C' : '°F'})"),
            subtitle: Text(settingsProvider.useCelsius 
                ? "Сейчас используются градусы Цельсия" 
                : "Сейчас используются градусы Фаренгейта"),
            value: settingsProvider.useCelsius,
            onChanged: (value) => settingsProvider.setUseCelsius(value),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Внешний вид",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text("Тёмный режим"),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
              // Use the public accessor method to update theme
              WeatherAppState.of(context)?.toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }
}