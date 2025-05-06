import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ecology_provider.dart';
import '../../widgets/error_handler.dart';
import '../../models/ecology_model.dart';

class AirScreen extends StatelessWidget {
  const AirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AirContent();
  }
}

class AirContent extends StatelessWidget {
  const AirContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EcologyProvider>(
      builder: (context, ecologyProvider, child) {
        final ecologyData = ecologyProvider.ecologyData;
        final isLoading = ecologyProvider.isLoading;
        final error = ecologyProvider.error;
        
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ErrorHandler.showError(context, error);
            ecologyProvider.clearError();
          });
        }
        
        if (ecologyData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Нет данных о качестве воздуха",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ecologyProvider.fetchEcologyData(ecologyProvider.currentCity),
                  child: const Text("Обновить"),
                ),
              ],
            ),
          );
        }

        final airQuality = ecologyData.airQuality;
        final qualityText = airQuality.getAirQualityText();
        final qualityColor = Color(airQuality.getAirQualityColor());
        
        return RefreshIndicator(
          onRefresh: () => ecologyProvider.refreshAllData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Качество воздуха в ${ecologyProvider.currentCity}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ecologyProvider.refreshAllData(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            airQuality.usEpaIndex <= 2 ? Icons.check_circle : Icons.warning,
                            color: qualityColor,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              qualityText,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: qualityColor,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("Индекс EPA: ${airQuality.usEpaIndex} (из 6)"),
                      Text("Индекс DEFRA: ${airQuality.gbDefraIndex} (из 10)"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Подробные данные",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              _buildPollutantCard(
                "PM2.5", 
                "${airQuality.pm2_5.toStringAsFixed(1)} µg/m³", 
                "Мелкодисперсные частицы",
                _getPollutantIcon(airQuality.pm2_5, 15, 35),
              ),
              
              _buildPollutantCard(
                "PM10", 
                "${airQuality.pm10.toStringAsFixed(1)} µg/m³", 
                "Твердые частицы",
                _getPollutantIcon(airQuality.pm10, 50, 150),
              ),
              
              _buildPollutantCard(
                "CO", 
                "${airQuality.co.toStringAsFixed(1)} µg/m³", 
                "Монооксид углерода",
                _getPollutantIcon(airQuality.co, 4000, 9000),
              ),
              
              _buildPollutantCard(
                "NO₂", 
                "${airQuality.no2.toStringAsFixed(1)} µg/m³", 
                "Диоксид азота",
                _getPollutantIcon(airQuality.no2, 70, 200),
              ),
              
              _buildPollutantCard(
                "O₃", 
                "${airQuality.o3.toStringAsFixed(1)} µg/m³", 
                "Озон",
                _getPollutantIcon(airQuality.o3, 100, 140),
              ),
              
              _buildPollutantCard(
                "SO₂", 
                "${airQuality.so2.toStringAsFixed(1)} µg/m³", 
                "Диоксид серы",
                _getPollutantIcon(airQuality.so2, 100, 350),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPollutantCard(String name, String value, String description, Widget icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: icon,
        title: Text(name),
        subtitle: Text(description),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  Widget _getPollutantIcon(double value, double goodThreshold, double badThreshold) {
    if (value < goodThreshold) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (value < badThreshold) {
      return const Icon(Icons.warning, color: Colors.orange);
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }
}
