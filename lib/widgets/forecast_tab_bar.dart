import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class ForecastTabBar extends StatelessWidget {
  const ForecastTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      tabs: [
        Tab(text: "Сутки"),
        Tab(text: "6 часов"),
        Tab(text: "Час"),
      ],
    );
  }
}

class DailyForecastTab extends StatelessWidget {
  const DailyForecastTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (weatherProvider.forecast.isEmpty) {
          _loadForecast(context, weatherProvider);
          return const Center(child: Text("Загрузка прогноза..."));
        }
        
        final forecasts = weatherProvider.forecast;
        
        return RefreshIndicator(
          onRefresh: () => weatherProvider.fetchForecast(weatherProvider.currentCity),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              final date = DateFormat('dd.MM').format(DateTime.parse(forecast.date));
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text("$date"),
                  subtitle: Text("Температура: ${forecast.tempRangeString}\n${forecast.condition}"),
                  trailing: forecast.conditionIcon.isNotEmpty 
                    ? Image.network('https:${forecast.conditionIcon}', width: 40, height: 40)
                    : const Icon(Icons.wb_cloudy),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  void _loadForecast(BuildContext context, WeatherProvider provider) {
    if (!provider.isLoading && provider.forecast.isEmpty) {
      Future.microtask(() => provider.fetchForecast(provider.currentCity));
    }
  }
}

class Every6HoursForecastTab extends StatelessWidget {
  const Every6HoursForecastTab({super.key});

  @override
  Widget build(BuildContext context) {
    final periods = ['00:00', '06:00', '12:00', '18:00'];
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (weatherProvider.forecast.isEmpty) {
          _loadForecast(context, weatherProvider);
          return const Center(child: Text("Загрузка прогноза..."));
        }
        
        // Временная заглушка - в будущем можно добавить более детальные данные
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: periods.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text("Период: ${periods[index]}"),
                subtitle: const Text("Температура: 12°C\nПеременная облачность"),
                trailing: const Icon(Icons.wb_sunny),
              ),
            );
          },
        );
      },
    );
  }
  
  void _loadForecast(BuildContext context, WeatherProvider provider) {
    if (!provider.isLoading && provider.forecast.isEmpty) {
      Future.microtask(() => provider.fetchForecast(provider.currentCity));
    }
  }
}

class HourlyForecastTab extends StatelessWidget {
  const HourlyForecastTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (weatherProvider.forecast.isEmpty) {
          _loadForecast(context, weatherProvider);
          return const Center(child: Text("Загрузка прогноза..."));
        }
        
        // Временная заглушка - в будущем можно добавить более детальные данные почасового прогноза
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 12,
          itemBuilder: (context, index) {
            final hour = (index + 6) % 24;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text("Час: $hour:00"),
                subtitle: const Text("Температура: 11°C\nЯсно"),
                trailing: const Icon(Icons.wb_sunny_outlined),
              ),
            );
          },
        );
      },
    );
  }
  
  void _loadForecast(BuildContext context, WeatherProvider provider) {
    if (!provider.isLoading && provider.forecast.isEmpty) {
      Future.microtask(() => provider.fetchForecast(provider.currentCity));
    }
  }
}
