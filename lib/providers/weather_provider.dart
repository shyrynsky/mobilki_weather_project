import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../constants.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  Weather? _currentWeather;
  List<Forecast> _forecast = [];
  String _currentCity = AppConstants.defaultCity;
  bool _isLoading = false;
  String? _error;
  
  // Функция для синхронизации города с другими провайдерами
  Function(String)? onCityChanged;
  
  // Геттеры
  Weather? get currentWeather => _currentWeather;
  List<Forecast> get forecast => _forecast;
  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Инициализация при старте
  WeatherProvider() {
    _initializeWithLocation();
  }

  // Метод для инициализации с геолокацией
  Future<void> _initializeWithLocation() async {
    final hasPermission = await LocationService.checkLocationPermission();
    if (hasPermission) {
      final city = await LocationService.getCurrentCity();
      if (city != null) {
        _currentCity = city;
        await fetchWeatherData(city);
        return;
      }
    }
    // Если не удалось получить город по геолокации, используем сохраненный или дефолтный
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('city');
    if (savedCity != null) {
      _currentCity = savedCity;
    }
    await fetchWeatherData(_currentCity);
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

      if (weather != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('city', city);
        await prefs.setString('temp', weather.temperatureString);
        await prefs.setString('condition', weather.condition);
        await prefs.setString('humidity', weather.humidity.toString());
        await prefs.setString('wind', weather.windSpeed.toString());
        await prefs.setString('icon_url', "https:" + weather.conditionIcon);


        await const MethodChannel('widget_channel').invokeMethod('updateWidget');
      }

    } catch (e) {
      _error = e.toString();
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Метод для получения погоды по координатам
  Future<void> fetchWeatherByCoordinates(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final weather = await _weatherService.getWeatherByCoordinates(lat, lon);
      _currentWeather = weather.weather;
      _currentCity = weather.cityName;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для получения прогноза
  Future<void> fetchForecast(String city, {int days = 7}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final forecastData = await _weatherService.getForecast(city, days: days);
      _forecast = forecastData;
    } catch (e) {
      _error = e.toString();
      // Оставляем предыдущий прогноз, если он есть
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для обновления всех данных
  Future<void> refreshAllData() async {
    _error = null;
    await fetchWeatherData(_currentCity);
    await fetchForecast(_currentCity);
  }
  
  // Метод для изменения города
  void changeCity(String newCity) {
    if (newCity.isNotEmpty && newCity != _currentCity) {
      _currentCity = newCity;
      refreshAllData();
      
      // Уведомить других провайдеров об изменении города
      if (onCityChanged != null) {
        onCityChanged!(newCity);
      }
    }
  }
  
  // Сброс ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 