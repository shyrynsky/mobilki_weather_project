import 'package:flutter/material.dart';

class AgroScreen extends StatelessWidget {
  const AgroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Агрометео данные",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.grass),
            title: const Text("Брест"),
            subtitle: const Text("Почва: +10°C\nОсадки: 1.5 мм"),
            trailing: const Icon(Icons.eco),
            onTap: () => debugPrint('Брест агро'),
          ),
        ),
      ],
    );
  }
}
