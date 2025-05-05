import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _checkPermissions(BuildContext context) async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Требуются разрешения'),
            content: const Text('Для работы уведомлений необходимо разрешение'),
            actions: [
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Выход'),
              ),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Настройки'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Уведомления")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Включить уведомления'),
            value: settings.notificationsEnabled,
            onChanged: (value) async {
              await _checkPermissions(context);
              settings.setNotificationSettings(enabled: value);
            },
          ),

          // Настройки для сегодня
          _buildRainNotificationSection(
            context,
            'Уведомлять о дожде сегодня',
            settings.notifyRainToday,
            settings.notificationTimeToday,
                (value) => settings.setNotificationSettings(notifyToday: value),
                (time) => settings.setNotificationSettings(timeToday: time),
          ),

          // Настройки для завтра
          _buildRainNotificationSection(
            context,
            'Уведомлять о дожде завтра',
            settings.notifyRainTomorrow,
            settings.notificationTimeTomorrow,
                (value) => settings.setNotificationSettings(notifyTomorrow: value),
                (time) => settings.setNotificationSettings(timeTomorrow: time),
          ),
        ],
      ),
    );
  }
  Widget _buildRainNotificationSection(
      BuildContext context,
      String title,
      bool value,
      TimeOfDay time,
      Function(bool) onChanged,
      Function(TimeOfDay) onTimeChanged,
      ) {
    final settings = Provider.of<SettingsProvider>(context);
    final isEnabled = settings.notificationsEnabled;
    
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            title,
            style: TextStyle(
              color: isEnabled ? null : Colors.grey,
            ),
          ),
          value: value,
          onChanged: isEnabled ? onChanged : null,
        ),
        if (value)
          ListTile(
            title: Text(
              'Время уведомления: ${time.format(context)}',
              style: TextStyle(
                color: isEnabled ? null : Colors.grey,
              ),
            ),
            trailing: Icon(
              Icons.access_time,
              color: isEnabled ? null : Colors.grey,
            ),
            onTap: isEnabled ? () async {
              final newTime = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (newTime != null) onTimeChanged(newTime);
            } : null,
          ),
      ],
    );
  }
}