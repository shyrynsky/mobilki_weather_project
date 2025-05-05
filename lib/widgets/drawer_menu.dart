import 'package:flutter/material.dart';
import '../screens/units_settings_screen.dart';
import '../screens/notification_settings_screen.dart';

import '../main.dart';

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
            leading: const Icon(Icons.settings),
            title: const Text("Настройки"),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnitsSettingsScreen()),
              );
              
              // Handle theme toggle result
              if (result != null && result is bool) {
                // Use the public accessor method to get the WeatherApp state
                WeatherAppState.of(context)?.toggleTheme(result);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Уведомления"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}