import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/ecology/air_screen.dart';
import 'screens/map_screen.dart';
import 'widgets/drawer_menu.dart';
import 'providers/weather_provider.dart';
import 'providers/ecology_provider.dart';
import 'providers/settings_provider.dart';
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
  WidgetsFlutterBinding.ensureInitialized(); // Добавить

  // Инициализация уведомлений
  await NotificationService.initialize();

  // Инициализация Workmanager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  // Workmanager().registerOneOffTask(
  //   "initTest",
  //   "rain_notifications",
  //   // frequency: Duration(days: 1),
  //   initialDelay: Duration(seconds: 5),
  //   // constraints: Constraints(networkType: NetworkType.connected),
  //   // tag: 'rain_notifications'
  // );

  runApp(const WeatherApp());
}
class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => WeatherAppState();
}

class WeatherAppState extends State<WeatherApp> {
  bool _isDarkMode = false;
  
  // Создаем провайдеры заранее для установки связи между ними
  late final WeatherProvider _weatherProvider = WeatherProvider();
  late final EcologyProvider _ecologyProvider = EcologyProvider();
  late final SettingsProvider _settingsProvider = SettingsProvider(); // Изменить


  void toggleTheme(bool value) {
    setState(() => _isDarkMode = value);
  }

  // Add a public accessor method
  static WeatherAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<WeatherAppState>();
  }
  
  @override
  void initState() {
    super.initState();
    // Устанавливаем связь между провайдерами для синхронизации города
    _weatherProvider.onCityChanged = (city) {
      _ecologyProvider.changeCity(city);
    };
    
    // Двусторонняя синхронизация
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
        ChangeNotifierProvider<SettingsProvider>.value(value: _settingsProvider), // Изменить
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
    const AirScreen(),
    const MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle(_currentIndex))),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      drawer: const DrawerMenu(),
    );
  }

  String _getTitle(int index) {
    const titles = ["Погода", "Прогноз", "Экология", "Карта"];
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
          icon: Icon(Icons.eco),
          label: 'Экология',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Карта',
        ),
      ],
    );
  }
}