import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/weather_provider.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final weather = weatherProvider.currentWeather;
        final isLoading = weatherProvider.isLoading;
        
        if (isLoading) {
          return _buildLoadingCard();
        }
        
        if (weather == null) {
          return _buildErrorCard();
        }
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              if (weather.conditionIcon.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: 'https:${weather.conditionIcon}',
                  height: 64,
                  width: 64,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.cloud, size: 64, color: Colors.blueGrey),
                )
              else
                const Icon(Icons.cloud, size: 64, color: Colors.blueGrey),
              const SizedBox(height: 16),
              Text(
                weather.condition,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                weather.temperatureString,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            "Загрузка данных...",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: const Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            "Ошибка загрузки данных",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class WeatherDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetailCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
