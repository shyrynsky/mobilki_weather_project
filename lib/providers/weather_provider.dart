import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../constants.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  Weather? _currentWeather;
  List<Forecast> _forecast = [];
  String _currentCity = AppConstants.defaultCity;
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  Weather? get currentWeather => _currentWeather;
  List<Forecast> get forecast => _forecast;
  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Инициализация при старте
  WeatherProvider() {
    fetchWeatherData(_currentCity);
  }
  
  // Метод для получения текущей погоды
  Future<void> fetchWeatherData(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final weather = await _weatherService.getCurrentWeather(city);
      _currentWeather = weather;
      _currentCity = city;
      _error = null;
    } catch (e) {
      _error = 'Не удалось загрузить данные о погоде: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для получения прогноза
  Future<void> fetchForecast(String city, {int days = 7}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final forecastData = await _weatherService.getForecast(city, days: days);
      _forecast = forecastData;
    } catch (e) {
      _error = 'Не удалось загрузить прогноз погоды: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для обновления всех данных
  Future<void> refreshAllData() async {
    await fetchWeatherData(_currentCity);
    await fetchForecast(_currentCity);
  }
  
  // Метод для изменения города
  void changeCity(String newCity) {
    if (newCity.isNotEmpty && newCity != _currentCity) {
      _currentCity = newCity;
      refreshAllData();
    }
  }
} 