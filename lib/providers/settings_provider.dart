import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _useCelsius = true;

  bool get useCelsius => _useCelsius;

  void setUseCelsius(bool value) {
    _useCelsius = value;
    notifyListeners();
  }

  // Конвертация температуры по необходимости
  double convertTemperature(double temp) {
    if (_useCelsius) {
      return temp; // Температура уже в Цельсиях
    } else {
      return (temp * 9 / 5) + 32; // Конвертация в Фаренгейты
    }
  }

  // Получение символа единицы измерения
  String get temperatureUnit => _useCelsius ? '°C' : '°F';
} 