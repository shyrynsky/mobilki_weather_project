import 'package:flutter/material.dart';

class ForecastTabBar extends StatelessWidget {
  const ForecastTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      tabs: [
        Tab(text: "Сутки"),
        Tab(text: "6 часов"),
        Tab(text: "Час"),
      ],
    );
  }
}

class DailyForecastTab extends StatelessWidget {
  const DailyForecastTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(5, (index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text("День ${index + 1}"),
            subtitle: const Text("Температура: 10–15°C\nОблачно"),
            trailing: const Icon(Icons.wb_cloudy),
            onTap: () {
              debugPrint('Нажат день $index');
            },
          ),
        );
      }),
    );
  }
}

class Every6HoursForecastTab extends StatelessWidget {
  const Every6HoursForecastTab({super.key});

  @override
  Widget build(BuildContext context) {
    final periods = ['00:00', '06:00', '12:00', '18:00'];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.access_time),
            title: Text("Период: ${periods[index]}"),
            subtitle: const Text("Температура: 12°C\nПеременная облачность"),
            trailing: const Icon(Icons.wb_sunny),
            onTap: () {
              debugPrint('Нажат период ${periods[index]}');
            },
          ),
        );
      },
    );
  }
}

class HourlyForecastTab extends StatelessWidget {
  const HourlyForecastTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 12,
      itemBuilder: (context, index) {
        final hour = (index + 6) % 24;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: Text("Час: $hour:00"),
            subtitle: const Text("Температура: 11°C\nЯсно"),
            trailing: const Icon(Icons.wb_sunny_outlined),
            onTap: () {
              debugPrint('Нажат час $hour:00');
            },
          ),
        );
      },
    );
  }
}
