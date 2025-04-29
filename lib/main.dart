import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/ecology/air_screen.dart';
import 'screens/map_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/drawer_menu.dart';
import 'providers/weather_provider.dart';
import 'providers/ecology_provider.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => EcologyProvider()),
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
        home: MainNavigation(toggleTheme: _toggleTheme),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final Function(bool) toggleTheme;

  const MainNavigation({super.key, required this.toggleTheme});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Убраны const для SettingsScreen, так как колбэк не может быть константой
  late final List<Widget> _screens = [
    const HomeScreen(),
    const ForecastScreen(),
    const AirScreen(),
    const MapScreen(),
    SettingsScreen(onThemeChanged: widget.toggleTheme), // Колбэк передаётся напрямую
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
    const titles = ["Погода", "Прогноз", "Экология", "Карта", "Тема"];
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
          label: 'Погода', // Добавлена метка
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Прогноз', // Добавлена метка
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco),
          label: 'Экология', // Добавлена метка
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Карта', // Добавлена метка
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.palette),
          label: 'Тема', // Добавлена метка
        ),
      ],
    );
  }
}