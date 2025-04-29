import 'package:flutter/material.dart';
import '../widgets/location_drawer.dart';
import '../widgets/weather_card.dart';
import '../widgets/drawer_menu.dart';
import '../constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.location_pin),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
        title: const Text('Погода+'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      endDrawer: const LocationDrawer(),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationRow(),
            const SizedBox(height: 24),
            const WeatherCard(),
            const SizedBox(height: 24),
            _buildWeatherGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow() => Row(
    children: [
      const Icon(Icons.location_pin, color: Colors.blue),
      const SizedBox(width: 8),
      Text(AppConstants.defaultCity, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const Spacer(),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => debugPrint('Поиск города'), // Заглушка
      ),
    ],
  );

  Widget _buildWeatherGrid() => Expanded(
    child: GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        WeatherDetailCard(icon: Icons.water_drop, label: "Влажность", value: AppConstants.humidity),
        WeatherDetailCard(icon: Icons.speed, label: "Давление", value: AppConstants.pressure),
        WeatherDetailCard(icon: Icons.air, label: "Ветер", value: AppConstants.windSpeed),
        WeatherDetailCard(icon: Icons.wb_sunny, label: "УФ индекс", value: AppConstants.uvIndex),
      ],
    ),
  );
}