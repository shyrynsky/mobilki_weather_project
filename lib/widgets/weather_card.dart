import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/error_handler.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final settingsProvider = Provider.of<SettingsProvider>(context);
        final weather = weatherProvider.currentWeather;
        final isLoading = weatherProvider.isLoading;
        final error = weatherProvider.error;
        
        if (isLoading) {
          return _buildLoadingCard();
        }
        
        // Отображаем ошибку если нет данных о погоде
        if (weather == null) {
          // Если есть ошибка, показываем ее через ErrorHandler
          if (error != null) {
            // Показываем сообщение об ошибке только один раз
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ErrorHandler.showError(context, error);
              // Очищаем ошибку после показа
              weatherProvider.clearError();
            });
          }
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: const Column(
              children: [
                Icon(Icons.cloud_off, size: 64, color: Colors.blueGrey),
                SizedBox(height: 16),
                Text(
                  "Нет данных о погоде",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }
        
        // Если есть данные о погоде, но также есть ошибка, показываем ее через попап
        if (error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ErrorHandler.showError(context, error);
            // Очищаем ошибку после показа
            weatherProvider.clearError();
          });
        }
        
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.blue[900] 
                : Colors.blue[100],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              if (weather.conditionIcon.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: 'https:${weather.conditionIcon}',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.cloud, size: 120, color: Colors.blueGrey),
                )
              else
                const Icon(Icons.cloud, size: 120, color: Colors.blueGrey),
              const SizedBox(height: 16),
              Text(
                weather.condition,
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                weather.getTemperatureString(settingsProvider),
                style: TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
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
