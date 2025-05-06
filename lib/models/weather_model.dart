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

  String getTemperatureString(SettingsProvider settings) {
    final convertedTemp = settings.convertTemperature(temperature);
    return '${convertedTemp.round()}${settings.temperatureUnit}';
  }

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

  String getTempRangeString(SettingsProvider settings) {
    final minTempConverted = settings.convertTemperature(minTemp).round();
    final maxTempConverted = settings.convertTemperature(maxTemp).round();
    return '$minTempConverted${settings.temperatureUnit}-$maxTempConverted${settings.temperatureUnit}';
  }

  String get tempRangeString => '${minTemp.round()}°-${maxTemp.round()}°';

  List<HourForecast> getPeriodicForecasts(List<int> hours) {
    return hourlyForecasts.where((hour) => hours.contains(hour.hour)).toList();
  }
}

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

  String getTempString(SettingsProvider settings) {
    final convertedTemp = settings.convertTemperature(temp).round();
    return '$convertedTemp${settings.temperatureUnit}';
  }

  String get tempString => '${temp.round()}°C';
  String get windString => '${windSpeed.round()} м/с';
  String get hourString => '$hour:00';
  String get rainChanceString => '${chanceOfRain.round()}%';
} 