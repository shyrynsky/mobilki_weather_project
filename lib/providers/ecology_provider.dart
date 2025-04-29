import 'package:flutter/foundation.dart';
import '../models/ecology_model.dart';
import '../services/ecology_service.dart';
import '../constants.dart';

class EcologyProvider with ChangeNotifier {
  final EcologyService _ecologyService = EcologyService();
  
  EcologyData? _ecologyData;
  String _currentCity = AppConstants.defaultCity;
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  EcologyData? get ecologyData => _ecologyData;
  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Инициализация при старте
  EcologyProvider() {
    fetchEcologyData(_currentCity);
  }
  
  // Метод для получения экологических данных
  Future<void> fetchEcologyData(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await _ecologyService.getEcologyData(city);
      _ecologyData = data;
      _currentCity = city;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для получения данных о качестве воды
  Future<void> fetchWaterQuality(String city) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final waterData = await _ecologyService.getWaterQuality(city);
      if (_ecologyData != null) {
        _ecologyData = EcologyData(
          airQuality: _ecologyData!.airQuality,
          waterQuality: waterData,
          radiationData: _ecologyData!.radiationData,
        );
      }
    } catch (e) {
      _error = 'Не удалось загрузить данные о качестве воды: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для получения данных о радиации
  Future<void> fetchRadiationData(String city) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final radiationData = await _ecologyService.getRadiationData(city);
      if (_ecologyData != null) {
        _ecologyData = EcologyData(
          airQuality: _ecologyData!.airQuality,
          waterQuality: _ecologyData!.waterQuality,
          radiationData: radiationData,
        );
      }
    } catch (e) {
      _error = 'Не удалось загрузить данные о радиации: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для обновления всех экологических данных
  Future<void> refreshAllData() async {
    _error = null;
    await fetchEcologyData(_currentCity);
    await fetchWaterQuality(_currentCity);
    await fetchRadiationData(_currentCity);
  }
  
  // Метод для изменения города
  void changeCity(String newCity) {
    if (newCity.isNotEmpty && newCity != _currentCity) {
      _currentCity = newCity;
      refreshAllData();
    }
  }
  
  // Сброс ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 