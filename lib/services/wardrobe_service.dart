import '../models/weather_model.dart';
import '../models/wardrobe_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WardrobeService {
  // Метод для определения типа одежды по температуре
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

  // Метод для определения нужен ли зонт
  bool _needUmbrella(Weather weather) {
    final condition = weather.condition.toLowerCase();
    return condition.contains('дождь') || 
           condition.contains('ливень') || 
           condition.contains('осадки') ||
           condition.contains('rain') ||
           condition.contains('shower');
  }

  // Получение иконки для типа одежды (использующая материальные иконки вместо assets)
  IconData _getClothingIcon(String clothingType) {
    switch (clothingType) {
      case "light":
        return Icons.wb_sunny; // Солнце для легкой одежды
      case "medium-light":
        return Icons.wb_cloudy; // Облачно для средне-легкой одежды
      case "medium":
        return Icons.cloud; // Облако для средней одежды
      case "warm":
        return Icons.ac_unit; // Снежинка для теплой одежды
      case "very warm":
        return Icons.snowing; // Снег для очень теплой одежды
      default:
        return Icons.help_outline; // По умолчанию
    }
  }

  // Метод для генерации описания и списка одежды на основе типа одежды
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

  // Получение рекомендации по одежде на основе текущей погоды и почасового прогноза
  ClothingRecommendation getDailyRecommendationWithForecast(Weather currentWeather, List<HourForecast> hourlyForecasts) {
    // Определяем текущий период дня и категорию одежды
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Разделяем день на периоды
    final Map<String, DayPeriodRecommendation> dayPeriods = {};
    
    // Периоды дня: утро (6-11), день (12-17), вечер (18-23)
    const periods = {
      'morning': {'start': 6, 'end': 11, 'label': 'Утро'},
      'afternoon': {'start': 12, 'end': 17, 'label': 'День'},
      'evening': {'start': 18, 'end': 23, 'label': 'Вечер'},
    };
    
    // Текущий период дня
    String currentPeriod = 'morning';
    for (var entry in periods.entries) {
      final start = entry.value['start'] as int;
      final end = entry.value['end'] as int;
      if (currentHour >= start && currentHour <= end) {
        currentPeriod = entry.key;
        break;
      }
    }
    
    // Обрабатываем почасовой прогноз, группируя по периодам дня
    for (var periodKey in periods.keys) {
      final periodStart = periods[periodKey]!['start'] as int;
      final periodEnd = periods[periodKey]!['end'] as int;
      final periodLabel = periods[periodKey]!['label'] as String;
      
      // Находим все прогнозы для этого периода дня (сегодняшний день)
      final periodForecasts = hourlyForecasts.where(
        (forecast) => forecast.hour >= periodStart && 
                     forecast.hour <= periodEnd
      ).toList();
      
      if (periodForecasts.isEmpty) continue;
      
      // Рассчитываем среднюю температуру для периода
      double sumTemp = 0;
      bool needUmbrella = false;
      for (var forecast in periodForecasts) {
        sumTemp += forecast.temp;
        needUmbrella = needUmbrella || forecast.chanceOfRain > 30;
      }
      final avgTemp = sumTemp / periodForecasts.length;
      
      // Определяем тип одежды для этого периода
      final clothingType = _determineClothingType(avgTemp);
      final icon = _getClothingIcon(clothingType);
      final iconPath = icon.codePoint.toString();
      
      // Получаем описание и список вещей
      final details = _getClothingDetails(clothingType, needUmbrella);
      
      // Формируем описание для периода
      String periodDescription = "$periodLabel: ${details['description']}";
      
      // Создаем рекомендацию для периода
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
    
    // Если не смогли получить прогноз по периодам, возвращаем обычную рекомендацию
    if (dayPeriods.isEmpty) {
      return getDailyRecommendation(currentWeather);
    }
    
    // Получаем общую рекомендацию на основе текущего периода дня
    final currentClothingType = _determineClothingType(currentWeather.temperature);
    final needUmbrella = _needUmbrella(currentWeather);
    final icon = _getClothingIcon(currentClothingType);
    final iconPath = icon.codePoint.toString();
    final details = _getClothingDetails(currentClothingType, needUmbrella);
    
    // Формируем общее описание с учетом изменений погоды в течение дня
    String description = details['description'];
    if (dayPeriods.length > 1) {
      bool tempChanges = false;
      String firstType = "";
      
      // Проверяем, меняется ли тип одежды в течение дня
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

  // Получение рекомендации по одежде на основе текущей погоды
  ClothingRecommendation getDailyRecommendation(Weather weather) {
    final clothingType = _determineClothingType(weather.temperature);
    final needUmbrella = _needUmbrella(weather);
    
    // Получаем иконку из метода
    final icon = _getClothingIcon(clothingType);
    // Преобразуем в строку для хранения в модели
    final iconPath = icon.codePoint.toString();
    
    // Получаем описание и список вещей
    final details = _getClothingDetails(clothingType, needUmbrella);
    
    return ClothingRecommendation(
      clothingType: clothingType,
      description: details['description'],
      items: details['items'],
      needUmbrella: needUmbrella,
      iconPath: iconPath,
    );
  }
  
  // Расчет списка вещей для путешествия на основе прогноза погоды в разных городах
  TravelPackingList calculateTravelPacking(List<TravelPlan> travelPlans) {
    // Счетчики для разных типов одежды
    Map<String, int> clothingCounts = {};
    bool needUmbrella = false;
    Set<String> essentialItems = {"Документы", "Зарядные устройства", "Туалетные принадлежности"};
    
    // Анализ всех дней путешествия
    for (var plan in travelPlans) {
      final recommendation = plan.recommendation;
      
      // Учет зонта
      if (recommendation.needUmbrella) {
        needUmbrella = true;
      }
      
      // Подсчет необходимой одежды
      for (var item in recommendation.items) {
        if (item != "Зонт") {
          clothingCounts[item] = (clothingCounts[item] ?? 0) + 1;
        }
      }
    }
    
    // Оптимизация количества (не нужно брать по одной вещи на каждый день)
    Map<String, int> optimizedCounts = {};
    clothingCounts.forEach((item, count) {
      // Для верхней одежды берем минимум вещей
      if (item.contains("куртка") || item.contains("пальто") || item.contains("пуховик") ||
          item.contains("Шапка") || item.contains("обувь") || item.contains("Шарф") ) {
        optimizedCounts[item] = 1;
      }
      // Для футболок и нижней одежды - более либерально
      else if (item.contains("Футболка") || item.contains("майка") ) {
        optimizedCounts[item] = (count / 2).ceil();
      }
      // Для остального - среднее количество
      else {
        optimizedCounts[item] = (count / 3).ceil();
      }
    });
    
    // Общая рекомендация
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