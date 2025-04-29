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

void main() => runApp(const WeatherApp());

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => WeatherAppState();
}

class WeatherAppState extends State<WeatherApp> {
  bool _isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() => _isDarkMode = value);
  }

  // Add a public accessor method
  static WeatherAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<WeatherAppState>();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => EcologyProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
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