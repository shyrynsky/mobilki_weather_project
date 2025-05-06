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
  List<String> _savedLocations = [];

  Function(String)? onCityChanged;

  Weather? get currentWeather => _currentWeather;
  List<Forecast> get forecast => _forecast;
  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get savedLocations => _savedLocations;

  WeatherProvider() {
    _initializeWithLocation();
    _loadSavedLocations();
  }

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
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('city');
    if (savedCity != null) {
      _currentCity = savedCity;
    }
    await fetchWeatherData(_currentCity);
  }

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

  Future<void> fetchForecast(String city, {int days = 7}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final forecastData = await _weatherService.getForecast(city, days: days);
      _forecast = forecastData;
    } catch (e) {
      _error = e.toString();
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAllData() async {
    _error = null;
    await fetchWeatherData(_currentCity);
    await fetchForecast(_currentCity);
  }

  void changeCity(String newCity) {
    if (newCity.isNotEmpty && newCity != _currentCity) {
      _currentCity = newCity;
      refreshAllData();

      if (onCityChanged != null) {
        onCityChanged!(newCity);
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    _savedLocations = prefs.getStringList('savedLocations') ?? [];
    notifyListeners();
  }

  Future<void> _saveLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedLocations', _savedLocations);
  }

  Future<void> addLocation(String location) async {
    if (!_savedLocations.contains(location)) {
      _savedLocations.add(location);
      await _saveLocations();
      notifyListeners();
    }
  }

  Future<void> removeLocation(String location) async {
    _savedLocations.remove(location);
    await _saveLocations();
    notifyListeners();
  }
} 