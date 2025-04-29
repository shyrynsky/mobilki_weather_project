import 'package:flutter/material.dart';
import '../screens/units_settings_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Text('Меню', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Профиль'),
            onTap: () {}, // Заглушка
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text("Единицы измерения"), // Переименовано
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UnitsSettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}