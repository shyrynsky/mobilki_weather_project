import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Тема")),
      body: SwitchListTile(
        title: const Text("Тёмный режим"),
        value: _isDarkMode,
        onChanged: (value) {
          setState(() => _isDarkMode = value);
          widget.onThemeChanged(value);
        },
      ),
    );
  }
}