class ClothingRecommendation {
  final String clothingType; // "light", "medium", "warm", "very warm"
  final String description;
  final List<String> items;
  final bool needUmbrella;
  final String iconPath; // Path to the icon representing the clothing type
  
  // Новые поля для разных периодов дня
  final Map<String, DayPeriodRecommendation>? dayPeriods; // Опциональное поле для разных периодов дня
  final bool hasDayPeriods; // Флаг указывающий, что рекомендации разделены по периодам дня

  ClothingRecommendation({
    required this.clothingType,
    required this.description,
    required this.items,
    required this.needUmbrella,
    required this.iconPath,
    this.dayPeriods,
    this.hasDayPeriods = false,
  });
}

// Новый класс для хранения рекомендаций по периодам дня
class DayPeriodRecommendation {
  final String period; // "morning", "afternoon", "evening"
  final String clothingType;
  final String description;
  final List<String> items;
  final bool needUmbrella;
  final double temperature;
  final String iconPath;

  DayPeriodRecommendation({
    required this.period,
    required this.clothingType,
    required this.description,
    required this.items,
    required this.needUmbrella,
    required this.temperature,
    required this.iconPath,
  });
}

class TravelPlan {
  final String cityName;
  final DateTime date;
  final ClothingRecommendation recommendation;

  TravelPlan({
    required this.cityName,
    required this.date,
    required this.recommendation,
  });
}

class TravelPackingList {
  final List<String> essentialItems;
  final Map<String, int> clothingCounts; // Map of clothing item to count needed
  final bool needUmbrella;
  final String recommendation;

  TravelPackingList({
    required this.essentialItems,
    required this.clothingCounts,
    required this.needUmbrella,
    required this.recommendation,
  });
} 