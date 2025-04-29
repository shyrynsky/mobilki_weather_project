import 'package:flutter/material.dart';
import 'water_screen.dart';
import 'radiation_screen.dart';
import 'agro_screen.dart';
import 'chernobyl_screen.dart';

class AirScreen extends StatelessWidget {
  const AirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            isScrollable: true,
            tabs: [
              Tab(text: 'Воздух'),
              Tab(text: 'Вода'),
              Tab(text: 'Радиация'),
              Tab(text: 'Агро'),
              Tab(text: 'Чернобыль'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                AirContent(),
                WaterScreen(),
                RadiationScreen(),
                AgroScreen(),
                ChernobylScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AirContent extends StatelessWidget {
  const AirContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Качество воздуха",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.air),
            title: const Text("Минск"),
            subtitle: const Text("PM2.5: 12 µg/m³\nCO: 0.4 ppm"),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {
              debugPrint('Открыт Минск - воздух');
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.air),
            title: const Text("Гомель"),
            subtitle: const Text("PM2.5: 18 µg/m³\nCO: 0.6 ppm"),
            trailing: const Icon(Icons.warning, color: Colors.orange),
            onTap: () {
              debugPrint('Открыт Гомель - воздух');
            },
          ),
        ),
      ],
    );
  }
}
