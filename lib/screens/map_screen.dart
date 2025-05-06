import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../widgets/right_drawer_menu.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';

enum MapMode {
  viewInfo,
  addLocation
}

class MapScreen extends StatefulWidget {
  final MapMode mode;

  const MapScreen({super.key, this.mode = MapMode.viewInfo});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapMode _mode;
  String _selectedCity = "";
  final MapController _mapController = MapController();

  LatLng _center = LatLng(53.9, 27.56);
  LatLng _markerPosition = LatLng(53.9, 27.56);

  String _locationInfo = "";
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _mode = widget.mode;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      _searchLocation(weatherProvider.currentCity, setCenter: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: _mode == MapMode.viewInfo ? RightDrawerMenu() : null,
      appBar: AppBar(
        actions: [
          if (_mode == MapMode.addLocation && _selectedCity.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _addSelectedCity(context),
            ),
        ],
      ),
      body: Builder(
        builder: (context) => Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 5.0,
                onTap: (tapPosition, point) => _handleMapTap(context, point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _markerPosition,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_pin,
                        color: _mode == MapMode.addLocation ? Colors.red : Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Поиск места...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _searchLocation(value, setCenter: true);
                            }
                          },
                        ),
                      ),
                      if (_isSearching)
                        const CircularProgressIndicator(strokeWidth: 2)
                      else
                        IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _centerOnCurrentLocation,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            if (_mode == MapMode.addLocation)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Название города',
                            hintText: 'Введите название города',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(text: _selectedCity),
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
                          },
                        ),
                        if (_locationInfo.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _locationInfo,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Отмена'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _selectedCity.isNotEmpty
                                  ? () => _addSelectedCity(context)
                                  : null,
                              icon: const Icon(Icons.add_location),
                              label: const Text('Добавить'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_mode == MapMode.viewInfo)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[900] 
                      : Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Нажмите на карту, чтобы посмотреть информацию о погоде',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
                          ),
                        ),
                        if (_locationInfo.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _locationInfo,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white70 
                                    : Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.rotate(0);
          _mapController.move(_center, 5.0);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _handleMapTap(BuildContext context, LatLng point) async {
    setState(() {
      _markerPosition = point;
      _isSearching = true;
    });
    
    try {
      final locationInfo = await _getLocationInfo(point);
      setState(() {
        _locationInfo = locationInfo.locationInfo;
        _selectedCity = locationInfo.cityName;
        _isSearching = false;
      });

      if (_mode == MapMode.viewInfo) {
        final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
        await weatherProvider.fetchWeatherByCoordinates(point.latitude, point.longitude);
        Scaffold.of(context).openEndDrawer();
      }
    } catch (e) {
      setState(() {
        _locationInfo = "Не удалось определить место: $e";
        _isSearching = false;
      });
    }
  }

  Future<void> _searchLocation(String query, {bool setCenter = false}) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      await Future.delayed(const Duration(seconds: 1));

      LatLng location;
      switch (query.toLowerCase()) {
        case 'минск':
          location = LatLng(53.9, 27.56);
          break;
        case 'москва':
          location = LatLng(55.75, 37.62);
          break;
        case 'киев':
          location = LatLng(50.45, 30.52);
          break;
        case 'берлин':
          location = LatLng(52.52, 13.4);
          break;
        default:
          location = LatLng(
            50 + (DateTime.now().millisecond % 10),
            20 + (DateTime.now().second % 20),
          );
      }
      
      setState(() {
        _markerPosition = location;
        _selectedCity = query;
        _locationInfo = "Координаты: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}";
        
        if (setCenter) {
          _center = location;
          _mapController.move(location, 8.0);
        }
        
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _locationInfo = "Ошибка поиска: $e";
        _isSearching = false;
      });
    }
  }

  void _centerOnCurrentLocation() {
    final minsk = LatLng(53.9, 27.56);
    _mapController.move(minsk, 10);
    setState(() {
      _center = minsk;
      _markerPosition = minsk;
    });
  }

  void _addSelectedCity(BuildContext context) async {
    if (_selectedCity.isNotEmpty) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      await weatherProvider.addLocation(_selectedCity);
      weatherProvider.changeCity(_selectedCity);
      Navigator.pop(context);
    }
  }

  Future<LocationInfo> _getLocationInfo(LatLng point) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final lat = point.latitude.toStringAsFixed(4);
    final lng = point.longitude.toStringAsFixed(4);
    String cityName;

    if ((point.latitude - 53.9).abs() < 1 && (point.longitude - 27.56).abs() < 1) {
      cityName = "Минск";
    } else if ((point.latitude - 55.75).abs() < 1 && (point.longitude - 37.62).abs() < 1) {
      cityName = "Москва";
    } else if ((point.latitude - 50.45).abs() < 1 && (point.longitude - 30.52).abs() < 1) {
      cityName = "Киев";
    } else if ((point.latitude - 52.52).abs() < 1 && (point.longitude - 13.4).abs() < 1) {
      cityName = "Берлин";
    } else {
      try {
        final weatherService = WeatherService();
        final location = await weatherService.getWeatherByCoordinates(point.latitude, point.longitude);
        cityName = location.cityName;
      } catch (e) {
        cityName = "Место ($lat, $lng)";
      }
    }
    
    return LocationInfo(
      cityName: cityName,
      locationInfo: "Координаты: $lat, $lng"
    );
  }
}

class LocationInfo {
  final String cityName;
  final String locationInfo;
  
  LocationInfo({
    required this.cityName,
    required this.locationInfo,
  });
}
