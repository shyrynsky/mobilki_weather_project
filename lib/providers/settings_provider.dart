import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _useCelsius = true;
  bool _notificationsEnabled = false;

  bool _notifyRainToday = true;
  bool _notifyRainTomorrow = false;
  TimeOfDay _notificationTimeToday = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _notificationTimeTomorrow = const TimeOfDay(hour: 19, minute: 0);

  bool get useCelsius => _useCelsius;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notifyRainToday => _notifyRainToday;
  bool get notifyRainTomorrow => _notifyRainTomorrow;
  TimeOfDay get notificationTimeToday => _notificationTimeToday;
  TimeOfDay get notificationTimeTomorrow => _notificationTimeTomorrow;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _useCelsius = prefs.getBool('useCelsius') ?? true;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;

    _notifyRainToday = prefs.getBool('notifyRainToday') ?? true;
    _notifyRainTomorrow = prefs.getBool('notifyRainTomorrow') ?? false;

    _notificationTimeToday = TimeOfDay(
      hour: prefs.getInt('notificationHourToday') ?? 8,
      minute: prefs.getInt('notificationMinuteToday') ?? 0,
    );

    _notificationTimeTomorrow = TimeOfDay(
      hour: prefs.getInt('notificationHourTomorrow') ?? 19,
      minute: prefs.getInt('notificationMinuteTomorrow') ?? 0,
    );

    notifyListeners();

    if (_notificationsEnabled) {
      await NotificationService.scheduleDailyCheck(this);
    }
  }

  Future<void> setNotificationSettings({
    bool? enabled,
    bool? notifyToday,
    bool? notifyTomorrow,
    TimeOfDay? timeToday,
    TimeOfDay? timeTomorrow,
  }) async {
    if (enabled == true) {
      final hasPermissions = !(await Permission.notification.isDenied);
      if (!hasPermissions) return;
    }
    final prefs = await SharedPreferences.getInstance();
    bool scheduleNeeded = false;

    if (enabled != null) {
      _notificationsEnabled = enabled;
      await prefs.setBool('notificationsEnabled', enabled);
      scheduleNeeded = true;
    }

    if (notifyToday != null) {
      _notifyRainToday = notifyToday;
      await prefs.setBool('notifyRainToday', notifyToday);
    }

    if (notifyTomorrow != null) {
      _notifyRainTomorrow = notifyTomorrow;
      await prefs.setBool('notifyRainTomorrow', notifyTomorrow);
    }

    if (timeToday != null) {
      _notificationTimeToday = timeToday;
      await prefs.setInt('notificationHourToday', timeToday.hour);
      await prefs.setInt('notificationMinuteToday', timeToday.minute);
      scheduleNeeded = true;
    }

    if (timeTomorrow != null) {
      _notificationTimeTomorrow = timeTomorrow;
      await prefs.setInt('notificationHourTomorrow', timeTomorrow.hour);
      await prefs.setInt('notificationMinuteTomorrow', timeTomorrow.minute);
      scheduleNeeded = true;
    }

    notifyListeners();

    if (_notificationsEnabled) {
      if (notifyToday != null || timeToday != null) {
        await Workmanager().cancelByUniqueName("today_rain_check");
      }
      if (notifyTomorrow != null || timeTomorrow != null) {
        await Workmanager().cancelByUniqueName("tomorrow_rain_check");
      }
      await NotificationService.scheduleDailyCheck(this);
    }
  }

  void setUseCelsius(bool value) {
    _useCelsius = value;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCelsius', _useCelsius);
  }

  double convertTemperature(double temp) {
    return _useCelsius ? temp : (temp * 9/5) + 32;
  }

  String get temperatureUnit => _useCelsius ? '°C' : '°F';
}