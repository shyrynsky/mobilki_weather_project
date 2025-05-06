import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ecology_provider.dart';
import '../../widgets/error_handler.dart';
import '../../models/ecology_model.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EcologyProvider>(
      builder: (context, ecologyProvider, child) {
        final ecologyData = ecologyProvider.ecologyData;
        final waterQuality = ecologyData?.waterQuality;
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
        
        if (waterQuality == null) {
          if (ecologyData != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ecologyProvider.fetchWaterQuality(ecologyProvider.currentCity);
            });
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Нет данных о качестве воды",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ecologyProvider.fetchWaterQuality(ecologyProvider.currentCity),
                  child: const Text("Загрузить данные"),
                ),
              ],
            ),
          );
        }

        final qualityText = waterQuality.getWaterQualityText();

        Color statusColor;
        if (waterQuality.dissolvedOxygen > 8.0) {
          statusColor = Colors.green;
        } else if (waterQuality.dissolvedOxygen > 6.0) {
          statusColor = Colors.green[300]!;
        } else if (waterQuality.dissolvedOxygen > 4.0) {
          statusColor = Colors.orange;
        } else if (waterQuality.dissolvedOxygen > 2.0) {
          statusColor = Colors.deepOrange;
        } else {
          statusColor = Colors.red;
        }

        return RefreshIndicator(
          onRefresh: () => ecologyProvider.fetchWaterQuality(ecologyProvider.currentCity),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Качество воды в ${ecologyProvider.currentCity}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ecologyProvider.fetchWaterQuality(ecologyProvider.currentCity),
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
                            waterQuality.dissolvedOxygen > 6.0 ? Icons.check_circle : Icons.warning,
                            color: statusColor,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            qualityText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Примечание: Данные о качестве воды основаны на моделировании и могут отличаться от реальных показателей.",
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
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
              
              _buildWaterQualityCard(
                "pH", 
                waterQuality.pH.toString(), 
                "Кислотность воды",
                _getpHIcon(waterQuality.pH),
              ),
              
              _buildWaterQualityCard(
                "Растворенный кислород", 
                "${waterQuality.dissolvedOxygen} мг/л", 
                "Количество кислорода в воде",
                _getOxygenIcon(waterQuality.dissolvedOxygen),
              ),
              
              _buildWaterQualityCard(
                "Мутность", 
                "${waterQuality.turbidity} NTU", 
                "Прозрачность воды",
                _getTurbidityIcon(waterQuality.turbidity),
              ),
              
              _buildWaterQualityCard(
                "Температура", 
                "${waterQuality.temperature} °C", 
                "Температура воды",
                _getTemperatureIcon(waterQuality.temperature),
              ),
              
              _buildWaterQualityCard(
                "Электропроводность", 
                "${waterQuality.conductivity} µS/cm", 
                "Способность проводить электрический ток",
                _getConductivityIcon(waterQuality.conductivity),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildWaterQualityCard(String name, String value, String description, Widget icon) {
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
  
  Widget _getpHIcon(double value) {
    if (value >= 6.5 && value <= 8.5) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if ((value >= 6.0 && value < 6.5) || (value > 8.5 && value <= 9.0)) {
      return const Icon(Icons.warning, color: Colors.orange);
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }
  
  Widget _getOxygenIcon(double value) {
    if (value > 8.0) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (value > 6.0) {
      return const Icon(Icons.check_circle, color: Colors.lightGreen);
    } else if (value > 4.0) {
      return const Icon(Icons.warning, color: Colors.orange);
    } else if (value > 2.0) {
      return const Icon(Icons.warning, color: Colors.deepOrange);
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }
  
  Widget _getTurbidityIcon(double value) {
    if (value < 5.0) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (value < 10.0) {
      return const Icon(Icons.warning, color: Colors.orange);
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }
  
  Widget _getTemperatureIcon(double value) {
    if (value >= 10.0 && value <= 25.0) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if ((value >= 5.0 && value < 10.0) || (value > 25.0 && value <= 30.0)) {
      return const Icon(Icons.warning, color: Colors.orange);
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }
  
  Widget _getConductivityIcon(double value) {
    if (value < 800) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (value < 1500) {
      return const Icon(Icons.warning, color: Colors.orange);
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }
}
