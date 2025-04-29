import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../widgets/error_handler.dart';

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
        final error = weatherProvider.error;
        
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Если есть ошибка, показываем ее через ErrorHandler
        if (error != null) {
          // Показываем ошибку как полноэкранное сообщение, если нет данных
          if (weatherProvider.forecast.isEmpty) {
            return ErrorHandler.buildFullScreenError(
              error,
              onRetry: () {
                weatherProvider.clearError();
                weatherProvider.fetchForecast(weatherProvider.currentCity);
              },
            );
          } else {
            // Если есть данные, но также есть ошибка, показываем ее через попап
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ErrorHandler.showError(context, error);
              weatherProvider.clearError();
            });
          }
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

  // Интервалы для отображения прогноза каждые 6 часов
  final List<int> sixHourIntervals = const [0, 6, 12, 18];

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final error = weatherProvider.error;
        
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Показываем ошибку, если она есть
        if (error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ErrorHandler.showError(context, error);
            weatherProvider.clearError();
          });
        }
        
        if (weatherProvider.forecast.isEmpty) {
          _loadForecast(context, weatherProvider);
          return const Center(child: Text("Загрузка прогноза..."));
        }
        
        // Создаем список для отображения прогноза по 6-часовым интервалам
        final List<HourForecast> sixHourForecasts = [];
        
        // Собираем все 6-часовые прогнозы со всех дней
        for (var forecast in weatherProvider.forecast) {
          sixHourForecasts.addAll(forecast.getPeriodicForecasts(sixHourIntervals));
        }
        
        return RefreshIndicator(
          onRefresh: () => weatherProvider.fetchForecast(weatherProvider.currentCity),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sixHourForecasts.length,
            itemBuilder: (context, index) {
              final hourForecast = sixHourForecasts[index];
              final date = DateFormat('dd.MM').format(DateTime.parse(hourForecast.time.split(' ')[0]));
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text("$date, ${hourForecast.hourString}"),
                  subtitle: Text("${hourForecast.tempString}\n${hourForecast.condition}"),
                  trailing: hourForecast.conditionIcon.isNotEmpty 
                    ? Image.network('https:${hourForecast.conditionIcon}', width: 40, height: 40)
                    : const Icon(Icons.wb_sunny),
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

class HourlyForecastTab extends StatelessWidget {
  const HourlyForecastTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final error = weatherProvider.error;
        
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Показываем ошибку, если она есть
        if (error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ErrorHandler.showError(context, error);
            weatherProvider.clearError();
          });
        }
        
        if (weatherProvider.forecast.isEmpty) {
          _loadForecast(context, weatherProvider);
          return const Center(child: Text("Загрузка прогноза..."));
        }
        
        // Создаем список всех часовых прогнозов
        final List<HourForecast> allHourlyForecasts = [];
        
        // Собираем почасовые прогнозы за все доступные дни
        for (var forecast in weatherProvider.forecast) {
          allHourlyForecasts.addAll(forecast.hourlyForecasts);
        }
        
        // Сортируем по времени, если нужно
        allHourlyForecasts.sort((a, b) => a.time.compareTo(b.time));
        
        // Ограничиваем количество, чтобы не перегружать интерфейс
        final hourlyForecasts = allHourlyForecasts.take(24).toList();
        
        return RefreshIndicator(
          onRefresh: () => weatherProvider.fetchForecast(weatherProvider.currentCity),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hourlyForecasts.length,
            itemBuilder: (context, index) {
              final hourForecast = hourlyForecasts[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text("${hourForecast.hourString}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${hourForecast.tempString} · ${hourForecast.condition}"),
                      Row(
                        children: [
                          Icon(Icons.water_drop, size: 14, color: Colors.blue[300]),
                          Text(" ${hourForecast.rainChanceString}  "),
                          Icon(Icons.air, size: 14, color: Colors.grey),
                          Text(" ${hourForecast.windString}"),
                        ],
                      ),
                    ],
                  ),
                  trailing: hourForecast.conditionIcon.isNotEmpty 
                    ? Image.network('https:${hourForecast.conditionIcon}', width: 40, height: 40)
                    : const Icon(Icons.wb_sunny_outlined),
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
