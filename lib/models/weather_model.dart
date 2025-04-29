import '../providers/settings_provider.dart';

class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final String conditionIcon;
  final int humidity;
  final double pressure;
  final double windSpeed;
  final double uvIndex;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.conditionIcon,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.uvIndex,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Предполагаем, что API возвращает данные в определенном формате
    // Этот формат может потребоваться изменить в зависимости от выбранного API
    return Weather(
      cityName: json['location']['name'],
      temperature: json['current']['temp_c'],
      condition: json['current']['condition']['text'],
      conditionIcon: json['current']['condition']['icon'],
      humidity: json['current']['humidity'],
      pressure: json['current']['pressure_mb'],
      windSpeed: json['current']['wind_kph'],
      uvIndex: json['current']['uv'],
    );
  }

  // Создаем метод для получения замоканных данных 
  // (будет использоваться при ошибках API или тестировании)
  factory Weather.mock() {
    return Weather(
      cityName: 'Минск',
      temperature: 14.0,
      condition: 'Облачно',
      conditionIcon: '//cdn.weatherapi.com/weather/64x64/day/116.png',
      humidity: 60,
      pressure: 745.0,
      windSpeed: 5.0,
      uvIndex: 2.0,
    );
  }

  // Вспомогательные методы для форматирования данных с учетом единиц измерения
  String getTemperatureString(SettingsProvider settings) {
    final convertedTemp = settings.convertTemperature(temperature);
    return '${convertedTemp.round()}${settings.temperatureUnit}';
  }
  
  // Старый метод для обратной совместимости
  String get temperatureString => '${temperature.round()}°C';
  
  String get humidityString => '$humidity%';
  String get pressureString => '${pressure.round()} мм';
  String get windSpeedString => '${windSpeed.round()} м/с';
  String get uvIndexString => '${uvIndex.toStringAsFixed(1)}';
}

class Forecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String conditionIcon;
  final List<HourForecast> hourlyForecasts;

  Forecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.conditionIcon,
    required this.hourlyForecasts,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    // Парсим почасовой прогноз
    List<HourForecast> hourlyData = [];
    if (json['hour'] != null) {
      hourlyData = List<HourForecast>.from(
        json['hour'].map((hour) => HourForecast.fromJson(hour))
      );
    }

    return Forecast(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'],
      minTemp: json['day']['mintemp_c'],
      condition: json['day']['condition']['text'],
      conditionIcon: json['day']['condition']['icon'],
      hourlyForecasts: hourlyData,
    );
  }

  // Метод с учетом настроек
  String getTempRangeString(SettingsProvider settings) {
    final minTempConverted = settings.convertTemperature(minTemp).round();
    final maxTempConverted = settings.convertTemperature(maxTemp).round();
    return '$minTempConverted${settings.temperatureUnit}-$maxTempConverted${settings.temperatureUnit}';
  }
  
  // Старый метод для обратной совместимости
  String get tempRangeString => '${minTemp.round()}°-${maxTemp.round()}°';
  
  // Получение прогноза для определенных часов (например, для 6-часового отображения)
  List<HourForecast> getPeriodicForecasts(List<int> hours) {
    return hourlyForecasts.where((hour) => hours.contains(hour.hour)).toList();
  }
}

// Новый класс для хранения почасового прогноза
class HourForecast {
  final int hour;
  final String time;
  final double temp;
  final String condition;
  final String conditionIcon;
  final int humidity;
  final double windSpeed;
  final double chanceOfRain;

  HourForecast({
    required this.hour,
    required this.time,
    required this.temp,
    required this.condition,
    required this.conditionIcon,
    required this.humidity,
    required this.windSpeed,
    required this.chanceOfRain,
  });

  factory HourForecast.fromJson(Map<String, dynamic> json) {
    // Извлекаем час из строки времени (пример: "2023-07-26 09:00")
    final timeString = json['time'] as String;
    final hourString = timeString.split(' ')[1].split(':')[0];
    final hour = int.parse(hourString);

    return HourForecast(
      hour: hour,
      time: timeString,
      temp: json['temp_c'],
      condition: json['condition']['text'],
      conditionIcon: json['condition']['icon'],
      humidity: json['humidity'],
      windSpeed: json['wind_kph'],
      chanceOfRain: json['chance_of_rain'].toDouble(),
    );
  }
  
  // Метод с учетом настроек
  String getTempString(SettingsProvider settings) {
    final convertedTemp = settings.convertTemperature(temp).round();
    return '$convertedTemp${settings.temperatureUnit}';
  }

  // Старые методы для обратной совместимости
  String get tempString => '${temp.round()}°C';
  String get windString => '${windSpeed.round()} м/с';
  String get hourString => '$hour:00';
  String get rainChanceString => '${chanceOfRain.round()}%';
} 