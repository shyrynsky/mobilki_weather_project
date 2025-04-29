import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ecology_model.dart';
import '../config/api_keys.dart';

class EcologyService {
  // Используем тот же API-ключ, что и для погоды
  final String apiKey = ApiKeys.weatherApiKey;
  final String baseUrl = 'https://api.weatherapi.com/v1';
  
  // Получение данных о качестве воздуха
  Future<EcologyData> getEcologyData(String city) async {
    try {
      // Используем тот же API weatherapi.com с параметром aqi=yes для получения данных о качестве воздуха
      final response = await http.get(
        Uri.parse('$baseUrl/current.json?key=$apiKey&q=$city&aqi=yes')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EcologyData.fromJson(data);
      } else {
        final errorMsg = response.body.isNotEmpty 
            ? jsonDecode(response.body)['error']['message'] ?? 'Ошибка API'
            : 'Ошибка ${response.statusCode}';
        throw Exception('Ошибка при запросе экологических данных: $errorMsg');
      }
    } catch (e) {
      throw Exception('Не удалось загрузить экологические данные: $e');
    }
  }
  
  // Заглушки для будущих методов, когда появятся соответствующие API
  
  // Получение данных о качестве воды (пока заглушка)
  Future<WaterQuality?> getWaterQuality(String city) async {
    // В будущем здесь будет реальный API запрос
    await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
    return WaterQuality.mock();
  }
  
  // Получение данных о радиации (пока заглушка)
  Future<RadiationData?> getRadiationData(String city) async {
    // В будущем здесь будет реальный API запрос
    await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
    return RadiationData.mock();
  }
} 