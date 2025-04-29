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

  // Вспомогательные методы для форматирования данных
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

  Forecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.conditionIcon,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'],
      minTemp: json['day']['mintemp_c'],
      condition: json['day']['condition']['text'],
      conditionIcon: json['day']['condition']['icon'],
    );
  }

  String get tempRangeString => '${minTemp.round()}°-${maxTemp.round()}°';
} 