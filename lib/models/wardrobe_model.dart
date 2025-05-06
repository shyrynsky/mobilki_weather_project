class ClothingRecommendation {
  final String clothingType;
  final String description;
  final List<String> items;
  final bool needUmbrella;
  final String iconPath;

  final Map<String, DayPeriodRecommendation>? dayPeriods;
  final bool hasDayPeriods;

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

class DayPeriodRecommendation {
  final String period;
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
  final Map<String, int> clothingCounts;
  final bool needUmbrella;
  final String recommendation;

  TravelPackingList({
    required this.essentialItems,
    required this.clothingCounts,
    required this.needUmbrella,
    required this.recommendation,
  });
} 