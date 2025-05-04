import 'package:flutter/foundation.dart';
import '../models/wardrobe_model.dart';
import '../models/weather_model.dart';
import '../services/wardrobe_service.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

class WardrobeProvider with ChangeNotifier {
  final WardrobeService _wardrobeService = WardrobeService();
  final WeatherService _weatherService = WeatherService();
  
  ClothingRecommendation? _currentRecommendation;
  final List<TravelPlan> _travelPlans = [];
  TravelPackingList? _packingList;
  String? _error;
  bool _isLoading = false;
  
  // Геттеры
  ClothingRecommendation? get currentRecommendation => _currentRecommendation;
  List<TravelPlan> get travelPlans => _travelPlans;
  TravelPackingList? get packingList => _packingList;
  String? get error => _error;
  bool get isLoading => _isLoading;
  
  // Получить рекомендацию по одежде для текущей погоды с учетом прогноза на день
  Future<void> getDailyRecommendation(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Получаем текущую погоду
      final weather = await _weatherService.getCurrentWeather(city);
      
      if (weather != null) {
        // Пытаемся получить прогноз, чтобы учесть изменения в течение дня
        try {
          final List<Forecast> forecasts = await _weatherService.getForecast(city, days: 1);
          
          if (forecasts.isNotEmpty && forecasts[0].hourlyForecasts.isNotEmpty) {
            // Используем новый метод с учетом почасового прогноза
            _currentRecommendation = _wardrobeService.getDailyRecommendationWithForecast(
              weather, 
              forecasts[0].hourlyForecasts
            );
          } else {
            // Если прогноз не доступен, используем только текущую погоду
            _currentRecommendation = _wardrobeService.getDailyRecommendation(weather);
          }
        } catch (e) {
          // Если получение прогноза не удалось, используем только текущую погоду
          _currentRecommendation = _wardrobeService.getDailyRecommendation(weather);
        }
      } else {
        _error = 'Не удалось получить данные о погоде';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Добавить город в план путешествия
  Future<void> addCityToTravelPlan(String city, DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Получаем прогноз погоды на указанную дату
      final List<Forecast> forecasts = await _weatherService.getForecast(city, days: 14);
      
      // Проверяем, что прогноз есть и содержит нужную дату
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final forecast = forecasts.firstWhere(
        (f) => f.date == dateString,
        orElse: () => throw Exception('Нет прогноза на выбранную дату'),
      );
      
      // Создаем "виртуальную" погоду из прогноза для получения рекомендации
      final weather = Weather(
        cityName: city,
        temperature: (forecast.maxTemp + forecast.minTemp) / 2, // средняя температура
        condition: forecast.condition,
        conditionIcon: forecast.conditionIcon,
        humidity: 0, // эти данные не важны для рекомендации по одежде
        pressure: 0,
        windSpeed: 0,
        uvIndex: 0,
      );
      
      // Получаем рекомендацию по одежде для этого дня
      ClothingRecommendation recommendation;
      
      // Если есть почасовой прогноз, используем его для детальной рекомендации
      if (forecast.hourlyForecasts.isNotEmpty) {
        recommendation = _wardrobeService.getDailyRecommendationWithForecast(
          weather, 
          forecast.hourlyForecasts
        );
      } else {
        recommendation = _wardrobeService.getDailyRecommendation(weather);
      }
      
      // Создаем план на этот день
      final travelPlan = TravelPlan(
        cityName: city,
        date: date,
        recommendation: recommendation,
      );
      
      // Добавляем в список или заменяем существующий на эту дату
      final existingIndex = _travelPlans.indexWhere(
        (plan) => DateFormat('yyyy-MM-dd').format(plan.date) == dateString
      );
      
      if (existingIndex >= 0) {
        _travelPlans[existingIndex] = travelPlan;
      } else {
        _travelPlans.add(travelPlan);
      }
      
      // Сортируем по дате
      _travelPlans.sort((a, b) => a.date.compareTo(b.date));
      
      // Обновляем список упаковки
      _updatePackingList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Добавить диапазон дат для города (оптимизированный метод с единым запросом)
  Future<void> addCityToTravelPlanForDateRange(String city, List<DateTime> dates) async {
    if (dates.isEmpty) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Находим максимальное количество дней для прогноза
      final DateTime now = DateTime.now();
      final DateTime farthestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
      final int daysNeeded = farthestDate.difference(now).inDays + 1;
      
      // Ограничиваем до 14 дней (максимум API)
      final int daysToRequest = daysNeeded > 14 ? 14 : daysNeeded;
      
      // Делаем единственный запрос к API для получения прогноза на все даты
      final List<Forecast> forecasts = await _weatherService.getForecast(city, days: daysToRequest);
      
      // Для каждой даты создаем план поездки, но используем уже загруженный прогноз
      for (final date in dates) {
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        
        // Проверяем есть ли прогноз на эту дату
        final forecastIndex = forecasts.indexWhere((f) => f.date == dateString);
        
        if (forecastIndex == -1) {
          // Если даты нет в прогнозе, пропускаем (например, она слишком далекая)
          continue;
        }
        
        final forecast = forecasts[forecastIndex];
        
        // Создаем "виртуальную" погоду из прогноза для получения рекомендации
        final weather = Weather(
          cityName: city,
          temperature: (forecast.maxTemp + forecast.minTemp) / 2,
          condition: forecast.condition,
          conditionIcon: forecast.conditionIcon,
          humidity: 0,
          pressure: 0,
          windSpeed: 0,
          uvIndex: 0,
        );
        
        // Получаем рекомендацию по одежде для этого дня
        ClothingRecommendation recommendation;
        
        if (forecast.hourlyForecasts.isNotEmpty) {
          recommendation = _wardrobeService.getDailyRecommendationWithForecast(
            weather, 
            forecast.hourlyForecasts
          );
        } else {
          recommendation = _wardrobeService.getDailyRecommendation(weather);
        }
        
        // Создаем план на этот день
        final travelPlan = TravelPlan(
          cityName: city,
          date: date,
          recommendation: recommendation,
        );
        
        // Добавляем в список или заменяем существующий на эту дату
        final existingIndex = _travelPlans.indexWhere(
          (plan) => DateFormat('yyyy-MM-dd').format(plan.date) == dateString
        );
        
        if (existingIndex >= 0) {
          _travelPlans[existingIndex] = travelPlan;
        } else {
          _travelPlans.add(travelPlan);
        }
      }
      
      // Сортируем по дате
      _travelPlans.sort((a, b) => a.date.compareTo(b.date));
      
      // Обновляем список упаковки
      _updatePackingList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Удалить город из плана путешествия
  void removeCityFromTravelPlan(int index) {
    if (index >= 0 && index < _travelPlans.length) {
      _travelPlans.removeAt(index);
      _updatePackingList();
      notifyListeners();
    }
  }
  
  // Обновить список упаковки на основе плана путешествия
  void _updatePackingList() {
    if (_travelPlans.isNotEmpty) {
      _packingList = _wardrobeService.calculateTravelPacking(_travelPlans);
    } else {
      _packingList = null;
    }
  }
  
  // Очистить план путешествия
  void clearTravelPlan() {
    _travelPlans.clear();
    _packingList = null;
    notifyListeners();
  }
  
  // Очистить ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 