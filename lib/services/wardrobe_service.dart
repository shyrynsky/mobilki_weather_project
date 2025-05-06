import '../models/weather_model.dart';
import '../models/wardrobe_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WardrobeService {
  String _determineClothingType(double temperature) {
    if (temperature >= 25) {
      return "light";
    } else if (temperature >= 18) {
      return "medium-light";
    } else if (temperature >= 10) {
      return "medium";
    } else if (temperature >= 0) {
      return "warm";
    } else {
      return "very warm";
    }
  }

  bool _needUmbrella(Weather weather) {
    final condition = weather.condition.toLowerCase();
    return condition.contains('дождь') || 
           condition.contains('ливень') || 
           condition.contains('осадки') ||
           condition.contains('rain') ||
           condition.contains('shower');
  }

  IconData _getClothingIcon(String clothingType) {
    switch (clothingType) {
      case "light":
        return Icons.wb_sunny;
      case "medium-light":
        return Icons.wb_cloudy;
      case "medium":
        return Icons.cloud;
      case "warm":
        return Icons.ac_unit;
      case "very warm":
        return Icons.snowing;
      default:
        return Icons.help_outline;
    }
  }

  Map<String, dynamic> _getClothingDetails(String clothingType, bool needUmbrella) {
    String description;
    List<String> items;
    
    switch (clothingType) {
      case "light":
        description = "Очень тепло! Легкая одежда подойдет идеально.";
        items = ["Футболка/майка", "Шорты/легкие брюки/юбка/платье", "Легкая обувь/сандалии"];
        break;
      case "medium-light":
        description = "Тепло. Легкая одежда, но с собой возьмите что-то на вечер.";
        items = ["Футболка/рубашка", "Легкие брюки/джинсы/юбка", "Легкая кофта/свитер", "Легкая обувь"];
        break;
      case "medium":
        description = "Прохладно. Лучше одеться в несколько слоев.";
        items = ["Футболка/рубашка", "Свитер/кофта", "Джинсы/брюки", "Легкая куртка/ветровка", "Закрытая обувь"];
        break;
      case "warm":
        description = "Холодно. Нужна теплая одежда.";
        items = ["Термобелье/теплая кофта", "Свитер/толстовка", "Теплая куртка/пальто", "Шапка/перчатки", "Теплая обувь"];
        break;
      case "very warm":
        description = "Очень холодно! Одевайтесь максимально тепло.";
        items = ["Термобелье", "Свитер/толстовка", "Зимняя куртка/пуховик", "Шапка/перчатки", "Шарф", "Теплая обувь"];
        break;
      default:
        description = "Проверьте прогноз погоды.";
        items = ["Универсальная одежда по сезону"];
    }
    
    if (needUmbrella) {
      items.add("Зонт");
      description += " Не забудьте зонт, возможны осадки!";
    }
    
    return {
      'description': description,
      'items': items,
    };
  }

  ClothingRecommendation getDailyRecommendationWithForecast(Weather currentWeather, List<HourForecast> hourlyForecasts) {
    final now = DateTime.now();
    final currentHour = now.hour;

    final Map<String, DayPeriodRecommendation> dayPeriods = {};

    const periods = {
      'morning': {'start': 6, 'end': 11, 'label': 'Утро'},
      'afternoon': {'start': 12, 'end': 17, 'label': 'День'},
      'evening': {'start': 18, 'end': 23, 'label': 'Вечер'},
    };

    String currentPeriod = 'morning';
    for (var entry in periods.entries) {
      final start = entry.value['start'] as int;
      final end = entry.value['end'] as int;
      if (currentHour >= start && currentHour <= end) {
        currentPeriod = entry.key;
        break;
      }
    }

    for (var periodKey in periods.keys) {
      final periodStart = periods[periodKey]!['start'] as int;
      final periodEnd = periods[periodKey]!['end'] as int;
      final periodLabel = periods[periodKey]!['label'] as String;

      final periodForecasts = hourlyForecasts.where(
        (forecast) => forecast.hour >= periodStart && 
                     forecast.hour <= periodEnd
      ).toList();
      
      if (periodForecasts.isEmpty) continue;

      double sumTemp = 0;
      bool needUmbrella = false;
      for (var forecast in periodForecasts) {
        sumTemp += forecast.temp;
        needUmbrella = needUmbrella || forecast.chanceOfRain > 30;
      }
      final avgTemp = sumTemp / periodForecasts.length;

      final clothingType = _determineClothingType(avgTemp);
      final icon = _getClothingIcon(clothingType);
      final iconPath = icon.codePoint.toString();

      final details = _getClothingDetails(clothingType, needUmbrella);

      String periodDescription = "$periodLabel: ${details['description']}";

      dayPeriods[periodKey] = DayPeriodRecommendation(
        period: periodLabel,
        clothingType: clothingType,
        description: periodDescription,
        items: details['items'],
        needUmbrella: needUmbrella,
        temperature: avgTemp,
        iconPath: iconPath,
      );
    }

    if (dayPeriods.isEmpty) {
      return getDailyRecommendation(currentWeather);
    }

    final currentClothingType = _determineClothingType(currentWeather.temperature);
    final needUmbrella = _needUmbrella(currentWeather);
    final icon = _getClothingIcon(currentClothingType);
    final iconPath = icon.codePoint.toString();
    final details = _getClothingDetails(currentClothingType, needUmbrella);

    String description = details['description'];
    if (dayPeriods.length > 1) {
      bool tempChanges = false;
      String firstType = "";

      for (var period in dayPeriods.values) {
        if (firstType.isEmpty) {
          firstType = period.clothingType;
        } else if (firstType != period.clothingType) {
          tempChanges = true;
          break;
        }
      }
      
      if (tempChanges) {
        description += "\n\nВ течение дня ожидается изменение погоды:";
        for (var period in dayPeriods.values) {
          description += "\n• ${period.period}: ";
          if (period.temperature < 10) {
            description += "холодно (${period.temperature.round()}°C)";
          } else if (period.temperature < 18) {
            description += "прохладно (${period.temperature.round()}°C)";
          } else if (period.temperature < 25) {
            description += "тепло (${period.temperature.round()}°C)";
          } else {
            description += "жарко (${period.temperature.round()}°C)";
          }
          
          if (period.needUmbrella) {
            description += ", возможен дождь";
          }
        }
      }
    }
    
    return ClothingRecommendation(
      clothingType: currentClothingType,
      description: description,
      items: details['items'],
      needUmbrella: needUmbrella,
      iconPath: iconPath,
      dayPeriods: dayPeriods,
      hasDayPeriods: dayPeriods.isNotEmpty,
    );
  }

  ClothingRecommendation getDailyRecommendation(Weather weather) {
    final clothingType = _determineClothingType(weather.temperature);
    final needUmbrella = _needUmbrella(weather);

    final icon = _getClothingIcon(clothingType);
    final iconPath = icon.codePoint.toString();

    final details = _getClothingDetails(clothingType, needUmbrella);
    
    return ClothingRecommendation(
      clothingType: clothingType,
      description: details['description'],
      items: details['items'],
      needUmbrella: needUmbrella,
      iconPath: iconPath,
    );
  }

  TravelPackingList calculateTravelPacking(List<TravelPlan> travelPlans) {
    Map<String, int> clothingCounts = {};
    bool needUmbrella = false;
    Set<String> essentialItems = {"Документы", "Зарядные устройства", "Туалетные принадлежности"};

    for (var plan in travelPlans) {
      final recommendation = plan.recommendation;

      if (recommendation.needUmbrella) {
        needUmbrella = true;
      }

      for (var item in recommendation.items) {
        if (item != "Зонт") {
          clothingCounts[item] = (clothingCounts[item] ?? 0) + 1;
        }
      }
    }

    Map<String, int> optimizedCounts = {};
    clothingCounts.forEach((item, count) {
      if (item.contains("куртка") || item.contains("пальто") || item.contains("пуховик") ||
          item.contains("Шапка") || item.contains("обувь") || item.contains("Шарф") ) {
        optimizedCounts[item] = 1;
      }
      else if (item.contains("Футболка") || item.contains("майка") ) {
        optimizedCounts[item] = (count / 2).ceil();
      }
      else {
        optimizedCounts[item] = (count / 3).ceil();
      }
    });

    String recommendation = "Для вашего путешествия ";
    if (needUmbrella) {
      recommendation += "не забудьте взять зонт. ";
      essentialItems.add("Зонт");
    }
    
    if (travelPlans.any((plan) => plan.recommendation.clothingType == "very warm")) {
      recommendation += "Будет очень холодно в некоторые дни, возьмите теплую одежду.";
    } else if (travelPlans.any((plan) => plan.recommendation.clothingType == "warm")) {
      recommendation += "Будет прохладно в некоторые дни, возьмите теплую одежду.";
    } else if (travelPlans.any((plan) => plan.recommendation.clothingType == "light")) {
      recommendation += "Будет тепло, возьмите легкую одежду.";
    } else {
      recommendation += "Погода будет умеренной, возьмите универсальную одежду.";
    }
    
    return TravelPackingList(
      essentialItems: essentialItems.toList(),
      clothingCounts: optimizedCounts,
      needUmbrella: needUmbrella,
      recommendation: recommendation,
    );
  }
} 