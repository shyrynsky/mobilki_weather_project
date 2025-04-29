import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/map_screen.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/error_handler.dart';

class LocationDrawer extends StatelessWidget {
  const LocationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          final error = weatherProvider.error;
          
          // Показываем ошибку как SnackBar, если она есть
          if (error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ErrorHandler.showError(context, error);
              weatherProvider.clearError();
            });
          }
          
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Мои места', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Добавить по названию'),
                onTap: () => _showAddLocationDialog(context, weatherProvider),
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Добавить на карте'),
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const MapScreen(mode: MapMode.addLocation)),
                ),
              ),
              const Divider(),
              // Текущий город
              _buildCurrentLocationItem(context, weatherProvider),
              
              // Здесь можно добавить сохраненные города
              // Пока используем статические данные, но в будущем можно сохранять историю
              _buildLocationItem(context, 'Минск', weatherProvider),
              _buildLocationItem(context, 'Москва', weatherProvider),
              _buildLocationItem(context, 'Киев', weatherProvider),
              _buildLocationItem(context, 'Берлин', weatherProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentLocationItem(BuildContext context, WeatherProvider provider) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final weather = provider.currentWeather;
    final city = provider.currentCity;
    final temp = weather != null ? weather.getTemperatureString(settingsProvider) : 'Loading...';
    
    return ListTile(
      title: Row(
        children: [
          Text(city),
          const SizedBox(width: 8),
          const Icon(Icons.location_on, size: 16, color: Colors.blue),
        ],
      ),
      subtitle: Text(temp),
      selected: true,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () {
        provider.fetchWeatherData(city);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLocationItem(BuildContext context, String name, WeatherProvider provider) {
    final isCurrentLocation = name == provider.currentCity;
    
    return ListTile(
      title: Text(name),
      selected: isCurrentLocation,
      selectedTileColor: isCurrentLocation ? Colors.blue.withOpacity(0.1) : null,
      onTap: () {
        provider.changeCity(name);
        Navigator.pop(context);
      },
    );
  }

  void _showAddLocationDialog(BuildContext context, WeatherProvider provider) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить место'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Название города'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.changeCity(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}