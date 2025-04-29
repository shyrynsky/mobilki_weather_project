import 'package:flutter/material.dart';

import '../screens/map_screen.dart';

class LocationDrawer extends StatelessWidget {
  const LocationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Мои места', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Добавить по названию'),
            onTap: () => _showAddLocationDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Добавить на карте'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen())),
          ),
          const Divider(),
          _buildLocationItem('Дом', '+2°C'),
          _buildLocationItem('Минск', '14°C'),
          _buildLocationItem('Текущее местоположение', '12°C'),
        ],
      ),
    );
  }

  Widget _buildLocationItem(String name, String temp) => ListTile(
    title: Text(name),
    subtitle: Text(temp),
    trailing: IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => _showEditDialog(name),
    ),
  );

  void _showAddLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить место'),
        content: TextField(decoration: const InputDecoration(hintText: 'Название')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String currentName) {
    // Логика редактирования
  }
}