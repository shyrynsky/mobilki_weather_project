// Модель для экологических данных
class EcologyData {
  final AirQuality airQuality;
  final WaterQuality? waterQuality;
  final RadiationData? radiationData;

  EcologyData({
    required this.airQuality,
    this.waterQuality,
    this.radiationData,
  });

  factory EcologyData.fromJson(Map<String, dynamic> json) {
    return EcologyData(
      airQuality: AirQuality.fromJson(json),
      // Для воды и радиации потребуются отдельные запросы или другие источники данных
      waterQuality: null,
      radiationData: null,
    );
  }
}

// Модель для качества воздуха (основана на данных из API weatherapi.com с полем aqi)
class AirQuality {
  final double co;          // Монооксид углерода (CO)
  final double no2;         // Диоксид азота (NO2)
  final double o3;          // Озон (O3)
  final double so2;         // Диоксид серы (SO2)
  final double pm2_5;       // Частицы PM2.5
  final double pm10;        // Частицы PM10
  final int usEpaIndex;     // Индекс EPA США (1-6)
  final int gbDefraIndex;   // Индекс DEFRA (1-10)

  AirQuality({
    required this.co,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.usEpaIndex,
    required this.gbDefraIndex,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final airData = json['current']['air_quality'] ?? {};
    
    return AirQuality(
      co: airData['co']?.toDouble() ?? 0.0,
      no2: airData['no2']?.toDouble() ?? 0.0,
      o3: airData['o3']?.toDouble() ?? 0.0,
      so2: airData['so2']?.toDouble() ?? 0.0,
      pm2_5: airData['pm2_5']?.toDouble() ?? 0.0,
      pm10: airData['pm10']?.toDouble() ?? 0.0,
      usEpaIndex: airData['us-epa-index']?.toInt() ?? 1,
      gbDefraIndex: airData['gb-defra-index']?.toInt() ?? 1,
    );
  }

  // Получение текстовой оценки качества воздуха по индексу EPA
  String getAirQualityText() {
    switch (usEpaIndex) {
      case 1:
        return 'Хорошее';
      case 2:
        return 'Умеренное';
      case 3:
        return 'Нездоровое для чувствительных групп';
      case 4:
        return 'Нездоровое';
      case 5:
        return 'Очень нездоровое';
      case 6:
        return 'Опасное';
      default:
        return 'Нет данных';
    }
  }

  // Получение цвета для индикации качества воздуха
  int getAirQualityColor() {
    switch (usEpaIndex) {
      case 1:
        return 0xFF00E400; // Зеленый
      case 2:
        return 0xFFFFFF00; // Желтый
      case 3:
        return 0xFFFF7E00; // Оранжевый
      case 4:
        return 0xFFFF0000; // Красный
      case 5:
        return 0xFF99004C; // Пурпурный
      case 6:
        return 0xFF7E0023; // Темно-красный
      default:
        return 0xFF808080; // Серый
    }
  }
}

// Модель для качества воды (заготовка для будущего использования с реальным API)
class WaterQuality {
  final double pH;
  final double dissolvedOxygen;
  final double turbidity;
  final double temperature;
  final double conductivity;

  WaterQuality({
    required this.pH,
    required this.dissolvedOxygen,
    required this.turbidity,
    required this.temperature,
    required this.conductivity,
  });

  // В будущем можно будет добавить метод fromJson, когда будет доступен API для данных о качестве воды
  factory WaterQuality.mock() {
    return WaterQuality(
      pH: 7.2,
      dissolvedOxygen: 8.5,
      turbidity: 5.0,
      temperature: 15.0,
      conductivity: 500.0,
    );
  }

  String getWaterQualityText() {
    // Примерная оценка качества воды на основе растворенного кислорода
    if (dissolvedOxygen > 8.0) return 'Отличное';
    if (dissolvedOxygen > 6.0) return 'Хорошее';
    if (dissolvedOxygen > 4.0) return 'Среднее';
    if (dissolvedOxygen > 2.0) return 'Плохое';
    return 'Очень плохое';
  }
}

// Модель для радиационных данных (заготовка для будущего использования с реальным API)
class RadiationData {
  final double backgroundLevel;  // мкЗв/ч
  final String status;

  RadiationData({
    required this.backgroundLevel,
    required this.status,
  });

  // В будущем можно будет добавить метод fromJson, когда будет доступен API для радиационных данных
  factory RadiationData.mock() {
    return RadiationData(
      backgroundLevel: 0.12,
      status: 'Нормальный',
    );
  }
} 