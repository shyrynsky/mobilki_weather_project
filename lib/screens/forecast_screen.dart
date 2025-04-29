import 'package:flutter/material.dart';
import '../widgets/forecast_tab_bar.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          ForecastTabBar(),
          Expanded(
            child: TabBarView(
              children: [
                DailyForecastTab(),
                Every6HoursForecastTab(),
                HourlyForecastTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
