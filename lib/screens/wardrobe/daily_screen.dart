import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/error_handler.dart';
import '../../models/wardrobe_model.dart';

class DailyWardrobeScreen extends StatefulWidget {
  const DailyWardrobeScreen({super.key});

  @override
  State<DailyWardrobeScreen> createState() => _DailyWardrobeScreenState();
}

class _DailyWardrobeScreenState extends State<DailyWardrobeScreen> with SingleTickerProviderStateMixin {
  bool _isInit = false;
  late TabController _periodTabController;
  final List<String> _periodTabs = ['Общее', 'Утро', 'День', 'Вечер'];

  @override
  void initState() {
    super.initState();
    _periodTabController = TabController(length: _periodTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _periodTabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final wardrobeProvider = Provider.of<WardrobeProvider>(context, listen: false);

      wardrobeProvider.getDailyRecommendation(weatherProvider.currentCity);
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  IconData _getIconFromCode(String iconPath) {
    try {
      final iconCode = int.parse(iconPath);
      return IconData(iconCode, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.checkroom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        if (wardrobeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wardrobeProvider.error != null) {
          return ErrorHandler.buildFullScreenError(
            wardrobeProvider.error!,
            onRetry: () {
              final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
              wardrobeProvider.getDailyRecommendation(weatherProvider.currentCity);
            },
          );
        }

        final recommendation = wardrobeProvider.currentRecommendation;
        if (recommendation == null) {
          return const Center(
            child: Text('Нет рекомендаций по одежде'),
          );
        }

        if (recommendation.hasDayPeriods) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildCurrentWeatherInfo(context),
              ),
              TabBar(
                controller: _periodTabController,
                tabs: _periodTabs.map((tab) => Tab(text: tab)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _periodTabController,
                  children: [
                    _buildMainRecommendation(recommendation),
                    _buildPeriodRecommendation(recommendation, 'morning'),
                    _buildPeriodRecommendation(recommendation, 'afternoon'),
                    _buildPeriodRecommendation(recommendation, 'evening'),
                  ],
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentWeatherInfo(context),
              const SizedBox(height: 24),
              _buildRecommendationCard(recommendation),
              const SizedBox(height: 24),
              _buildClothingItemsList(recommendation),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentWeatherInfo(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, _) {
        final weather = weatherProvider.currentWeather;
        if (weather == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сегодня в ${weather.cityName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.thermostat,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  weather.temperatureString,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 16),
                Text(
                  weather.condition,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainRecommendation(ClothingRecommendation recommendation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecommendationCard(recommendation),
          const SizedBox(height: 24),
          _buildClothingItemsList(recommendation),
        ],
      ),
    );
  }

  Widget _buildPeriodRecommendation(ClothingRecommendation recommendation, String periodKey) {
    final periodMap = {
      'morning': 'Утро',
      'afternoon': 'День',
      'evening': 'Вечер',
    };

    if (!recommendation.hasDayPeriods || recommendation.dayPeriods == null || 
        !recommendation.dayPeriods!.containsKey(periodKey)) {
      return Center(
        child: Text('Нет данных для периода "${periodMap[periodKey] ?? periodKey}"'),
      );
    }
    
    final periodRec = recommendation.dayPeriods![periodKey]!;
    final wardrodeIcon = _getIconFromCode(periodRec.iconPath);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        wardrodeIcon,
                        size: 32,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Рекомендация на ${periodRec.period}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Температура: ${periodRec.temperature.round()}°C',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    periodRec.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (periodRec.needUmbrella) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.umbrella,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 8),
                        const Text('Не забудьте зонт!'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Что надеть:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: periodRec.items.length,
            itemBuilder: (ctx, i) {
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(periodRec.items[i]),
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(ClothingRecommendation recommendation) {
    final wardrodeIcon = _getIconFromCode(recommendation.iconPath);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  wardrodeIcon,
                  size: 32,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.hasDayPeriods 
                        ? 'Рекомендация на сегодня' 
                        : 'Рекомендация по одежде',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              recommendation.description,
              style: const TextStyle(fontSize: 16),
            ),
            if (recommendation.needUmbrella) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.umbrella,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 8),
                  const Text('Не забудьте зонт!'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItemsList(ClothingRecommendation recommendation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Что надеть:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendation.items.length,
          itemBuilder: (ctx, i) {
            return ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(recommendation.items[i]),
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            );
          },
        ),
      ],
    );
  }
} 