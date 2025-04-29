import 'package:flutter/material.dart';

class RadiationScreen extends StatelessWidget {
  const RadiationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Радиационный фон",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text("Могилев"),
            subtitle: const Text("0.15 мкЗв/ч — в норме"),
            trailing: const Icon(Icons.shield, color: Colors.green),
            onTap: () => debugPrint('Могилев радиация'),
          ),
        ),
      ],
    );
  }
}
