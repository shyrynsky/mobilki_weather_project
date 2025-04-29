import 'package:flutter/material.dart';

class ChernobylScreen extends StatelessWidget {
  const ChernobylScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Зона Чернобыля",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.dangerous, color: Colors.red),
            title: const Text("Полесье"),
            subtitle: const Text("Загрязнение: 3.2 Ки/км²"),
            trailing: const Icon(Icons.warning_amber, color: Colors.orange),
            onTap: () => debugPrint('Полесье Чернобыль'),
          ),
        ),
      ],
    );
  }
}
