import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/ecology/air_screen.dart';
import 'screens/map_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/units_settings_screen.dart';
import 'providers/weather_provider.dart';
import 'providers/ecology_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/wardrobe_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';


@pragma('vm:entry-point')
void callbackDispatcher() {
  print('=== callbackDispatcher запущен ===');
  Workmanager().executeTask((task, inputData) async {
    print('=== executeTask: $task ===');
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await NotificationService.checkAndSendNotification();
      print('=== checkAndSendNotification завершён ===');
      return Future.value(true);
    } catch (e, stack) {
      print('=== ОШИБКА в callbackDispatcher: $e\\n$stack');
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  runApp(const WeatherApp());
}
class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => WeatherAppState();
}

class WeatherAppState extends State<WeatherApp> {
  bool _isDarkMode = false;

  late final WeatherProvider _weatherProvider = WeatherProvider();
  late final EcologyProvider _ecologyProvider = EcologyProvider();
  late final SettingsProvider _settingsProvider = SettingsProvider(); // Изменить


  void toggleTheme(bool value) {
    setState(() => _isDarkMode = value);
  }

  static WeatherAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<WeatherAppState>();
  }
  
  @override
  void initState() {
    super.initState();

    _weatherProvider.onCityChanged = (city) {
      _ecologyProvider.changeCity(city);
    };
    

    _ecologyProvider.onCityChanged = (city) {
      _weatherProvider.changeCity(city);
    };

    _settingsProvider.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherProvider>.value(value: _weatherProvider),
        ChangeNotifierProvider<EcologyProvider>.value(value: _ecologyProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        ChangeNotifierProvider<SettingsProvider>.value(value: _settingsProvider),
      ],
      child: MaterialApp(
        title: 'Погода+',
        theme: _isDarkMode
            ? ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        )
            : ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: MainNavigation(toggleTheme: toggleTheme),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final Function(bool) toggleTheme;

  const MainNavigation({super.key, required this.toggleTheme});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const ForecastScreen(),
    const WardrobeScreen(),
    const AirScreen(),
    const MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnitsSettingsScreen()),
              );
              
              if (result != null && result is bool) {
                widget.toggleTheme(result);
              }
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getTitle(int index) {
    const titles = ["Погода", "Прогноз", "Гардероб", "Воздух", "Карта"];
    return titles[index];
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud),
          label: 'Погода',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Прогноз',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checkroom),
          label: 'Гардероб',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.air),
          label: 'Воздух',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Карта',
        ),
      ],
    );
  }
}