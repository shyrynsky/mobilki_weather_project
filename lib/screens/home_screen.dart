import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/location_drawer.dart';
import '../widgets/weather_card.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../widgets/error_handler.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const LocationDrawer(),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          final weather = weatherProvider.currentWeather;
          final isLoading = weatherProvider.isLoading;
          final error = weatherProvider.error;
          
          // Показываем ошибку через ErrorHandler, если полностью нет данных
          if (error != null && weather == null) {
            return ErrorHandler.buildFullScreenError(
              error,
              onRetry: () {
                weatherProvider.clearError();
                weatherProvider.refreshAllData();
              },
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildLocationRow(context, weatherProvider),
                const SizedBox(height: 24),
                const WeatherCard(),
                const SizedBox(height: 24),
                _buildWeatherGrid(weather),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, WeatherProvider provider) => Row(
    children: [
      const Icon(Icons.location_pin, color: Colors.blue),
      const SizedBox(width: 8),
      Text(provider.currentCity, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const Spacer(),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          _showCitySearchDialog(context);
        },
      ),
      IconButton(
        icon: const Icon(Icons.location_pin),
        onPressed: () => Scaffold.of(context).openEndDrawer(),
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          provider.refreshAllData();
        },
      ),
    ],
  );

  void _showCitySearchDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Найти город'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введите название города',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final provider = Provider.of<WeatherProvider>(context, listen: false);
                provider.changeCity(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Найти'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherGrid(Weather? weather) {
    if (weather == null) {
      return const Expanded(
        child: Center(
          child: Text('Данные о погоде недоступны'),
        ),
      );
    }
    
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          WeatherDetailCard(icon: Icons.water_drop, label: "Влажность", value: weather.humidityString),
          WeatherDetailCard(icon: Icons.speed, label: "Давление", value: weather.pressureString),
          WeatherDetailCard(icon: Icons.air, label: "Ветер", value: weather.windSpeedString),
          WeatherDetailCard(icon: Icons.wb_sunny, label: "УФ индекс", value: weather.uvIndexString),
        ],
      ),
    );
  }
}