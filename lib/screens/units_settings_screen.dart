import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnitsSettingsScreen extends StatefulWidget {
  const UnitsSettingsScreen({super.key});

  @override
  State<UnitsSettingsScreen> createState() => _UnitsSettingsScreenState();
}

class _UnitsSettingsScreenState extends State<UnitsSettingsScreen> {
  bool _useCelsius = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Единицы измерения")),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Градусы Цельсия"),
            value: _useCelsius,
            onChanged: (value) => setState(() => _useCelsius = value),
          ),
        ],
      ),
    );
  }
}