import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:weather_app/constants.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleDailyCheck(SettingsProvider settings) async {
    // await Workmanager().cancelByTag('rain_notifications');
    // await Workmanager().cancelByUniqueName("today_rain_check");
    //
    // await Workmanager().cancelByUniqueName("tomorrow_rain_check");



    final tasks = [
      if (settings.notifyRainToday)
        _createTask(
          settings.notificationTimeToday,
          'today_rain_check',
        ),
      if (settings.notifyRainTomorrow)
        _createTask(
          settings.notificationTimeTomorrow,
          'tomorrow_rain_check',
        ),
    ];

    for (final task in tasks) {
      await Workmanager().registerPeriodicTask(
        task['tag'],
        task['task'],
        frequency: Duration(days: 1),
        initialDelay: Duration(seconds: 5),
        constraints: Constraints(networkType: NetworkType.connected),

      );
    }
  }

  static Map<String, dynamic> _createTask(TimeOfDay time, String tag) {
    return {
      'tag': tag,
      'task': tag,
      'delay': _calculateInitialDelay(time),
    };
  }



  static Duration _calculateInitialDelay(TimeOfDay time) {
    return const Duration(seconds: 10);
    // final now = DateTime.now();
    // var scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    //
    // if (scheduledTime.isBefore(now)) {
    //   scheduledTime = scheduledTime.add(const Duration(days: 1));
    // }
    //
    // return scheduledTime.difference(now);
  }
  static final WeatherService _weatherService = WeatherService();

  static Future<void> checkAndSendNotification() async {
    print('=== checkAndSendNotification вызван ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      print('SharedPreferences получен');
      final settings = SettingsProvider();
      await settings.loadSettings();
      print('Настройки загружены');

      final city = prefs.getString('city') ?? AppConstants.defaultCity;
      final forecastDays = settings.notifyRainTomorrow ? 2 : 1;

      try {
        final forecast = await _weatherService.getForecast(city, days: forecastDays);
        print('Прогноз получен');

        // Проверка на сегодня
        if (settings.notifyRainToday) {
          final todayForecast = forecast.first;
          final rainPeriods = _getRainPeriods(todayForecast.hourlyForecasts);
          print('rainPeriods сегодня: $rainPeriods');
          if (rainPeriods.isNotEmpty) {
            await _showRainNotification('Дождь сегодня', rainPeriods);
            print('Уведомление на сегодня отправлено');
          }
        }

        // Проверка на завтра
        if (settings.notifyRainTomorrow && forecast.length > 1) {
          final tomorrowForecast = forecast[1];
          final rainPeriods = _getRainPeriods(tomorrowForecast.hourlyForecasts);
          print('rainPeriods завтра: $rainPeriods');
          if (rainPeriods.isNotEmpty) {
            await _showRainNotification('Дождь завтра', rainPeriods);
            print('Уведомление на завтра отправлено');
          }
        }
      } catch (e, stack) {
        print('Ошибка при получении прогноза: $e\\n$stack');
        rethrow;
      }
    } catch (e, stack) {
      print('Ошибка в checkAndSendNotification: $e\\n$stack');
      rethrow;
    }
  }
  static List<String> _getRainPeriods(List<HourForecast> hourlyForecasts) {
    final rainHours = hourlyForecasts
        .where((hour) => hour.chanceOfRain >= 30)
        .map((hour) => hour.time.split(' ')[1].substring(0, 5))
        .toList();

    return _groupConsecutiveHours(rainHours);
  }

  static List<String> _groupConsecutiveHours(List<String> times) {
    if (times.isEmpty) return [];

    final List<String> periods = [];
    DateTime? start;
    DateTime? end;

    for (final time in times.map((t) => DateTime.parse("2000-01-01 $t"))) {
      if (start == null) {
        start = time;
        end = time;
      } else if (time.difference(end!) == const Duration(hours: 1)) {
        end = time;
      } else {
        periods.add('${_formatTime(start!)}-${_formatTime(end!)}');
        start = time;
        end = time;
      }
    }

    if (start != null) {
      periods.add('${_formatTime(start!)}-${_formatTime(end!)}');
    }

    return periods;
  }

  static String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  static Future<void> _showRainNotification(String title, List<String> periods) async {
    print('Показываем уведомление: $title, периоды: $periods');
    try {
      final message = periods.length > 3
          ? 'Дождь ожидается несколько раз'
          : 'Дождь ожидается в периоды: ${periods.join(', ')}';

      await _notificationsPlugin.show(
        UniqueKey().hashCode,
        title,
        'Не забудьте зонт ☔',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'rain_channel',
            'Уведомления о дожде',
            importance: Importance.high,
            styleInformation: BigTextStyleInformation(
              message,
              contentTitle: title,
            ),
          ),
        ),
      );
      print('Уведомление успешно показано');
    } catch (e, stack) {
      print('Ошибка при показе уведомления: $e\\n$stack');
      rethrow;
    }
  }
}