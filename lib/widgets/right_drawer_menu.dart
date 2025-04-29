import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';

class RightDrawerMenu extends StatelessWidget {
  const RightDrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final weather = weatherProvider.currentWeather;
    final isLoading = weatherProvider.isLoading;
    
    return Drawer(
      width: 260,
      child: Column(
        children: [
          AppBar(
            title: Text(weatherProvider.currentCity),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (weather == null)
            const Expanded(
              child: Center(
                child: Text('Нет данных о погоде'),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.thermostat),
                    title: Text(
                      "Температура: ${weather.getTemperatureString(settingsProvider)}",
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.water_drop),
                    title: Text("Влажность: ${weather.humidityString}"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.air),
                    title: Text("Давление: ${weather.pressureString}"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.air),
                    title: Text("Ветер: ${weather.windSpeedString}"),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add_location),
                    title: const Text("Добавить как место"),
                    onTap: () {
                      // Закрываем меню
                      Navigator.pop(context);
                      
                      // Показываем сообщение
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Добавлено место: ${weatherProvider.currentCity}',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
