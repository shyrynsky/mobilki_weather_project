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
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.blue[900] 
                      : Colors.blue[700],
                ),
                child: Text(
                  'Мои места', 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  )
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
                title: Text(
                  'Добавить по названию',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
                onTap: () => _showAddLocationDialog(context, weatherProvider),
              ),
              ListTile(
                leading: Icon(
                  Icons.map,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
                title: Text(
                  'Добавить на карте',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const MapScreen(mode: MapMode.addLocation)),
                ),
              ),
              const Divider(),
              // Текущий город
              _buildCurrentLocationItem(context, weatherProvider),
              
              // Список сохраненных мест
              ...weatherProvider.savedLocations.map((location) => 
                _buildLocationItem(context, location, weatherProvider)
              ),
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

  Widget _buildLocationItem(BuildContext context, String location, WeatherProvider provider) {
    return ListTile(
      leading: Icon(
        Icons.location_city,
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Colors.black,
      ),
      title: Text(
        location,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => provider.removeLocation(location),
      ),
      onTap: () {
        provider.changeCity(location);
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
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await provider.addLocation(controller.text);
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