  import 'package:flutter/material.dart';

  class WaterScreen extends StatelessWidget {
    const WaterScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Качество воды",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.water),
              title: const Text("Неман"),
              subtitle: const Text("Темп: 12°C\npH: 7.1"),
              trailing: const Icon(Icons.info_outline),
              onTap: () => debugPrint('Нажат Неман'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.water),
              title: const Text("Сож"),
              subtitle: const Text("Темп: 14°C\npH: 6.8"),
              trailing: const Icon(Icons.info_outline),
              onTap: () => debugPrint('Нажат Сож'),
            ),
          ),
        ],
      );
    }
  }
