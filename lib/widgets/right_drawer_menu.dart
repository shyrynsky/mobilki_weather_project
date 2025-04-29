import 'package:flutter/material.dart';

class RightDrawerMenu extends StatelessWidget {
  const RightDrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      child: Column(
        children: [
          AppBar(
            title: const Text('Станция'),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context), // Закрытие через навигатор
              ),
            ],
          ),
          const ListTile(
            leading: Icon(Icons.thermostat),
            title: Text("Температура: 14°C"),
          ),
          const ListTile(
            leading: Icon(Icons.water_drop),
            title: Text("Влажность: 55%"),
          ),
          const ListTile(
            leading: Icon(Icons.air),
            title: Text("CO₂: 400 ppm"),
          ),
        ],
      ),
    );
  }
}
