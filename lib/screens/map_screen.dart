import 'package:flutter/material.dart';
import '../widgets/right_drawer_menu.dart';
import '../widgets/drawer_menu.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Удалите ручное управление состоянием для правого меню
  // Используйте стандартный Scaffold.endDrawer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(), // Левое меню
      endDrawer: RightDrawerMenu(), // Правое меню
      appBar: AppBar(title: const Text("Карта")),
      body: GestureDetector(
        onTap: () => Scaffold.of(context).openEndDrawer(), // Открыть правое меню
        child: Container(
          color: Colors.lightBlue[100],
          child: const Center(
            child: Text(
              "Здесь могла быть карта",
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ),
    );
  }
}
