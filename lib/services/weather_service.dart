import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../config/api_keys.dart';

class WeatherService {
  // Получаем API ключ из конфигурационного файла
  final String apiKey = ApiKeys.weatherApiKey;
  final String baseUrl = 'https://api.weatherapi.com/v1';
  
  // Получение текущей погоды
  Future<Weather> getCurrentWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current.json?key=$apiKey&q=$city&aqi=no')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        final errorMsg = response.body.isNotEmpty 
            ? jsonDecode(response.body)['error']['message'] ?? 'Ошибка API'
            : 'Ошибка ${response.statusCode}';
        throw Exception('Ошибка при запросе погоды: $errorMsg');
      }
    } catch (e) {
      throw Exception('Не удалось загрузить данные о погоде: $e');
    }
  }
  
  // Получение прогноза на несколько дней
  Future<List<Forecast>> getForecast(String city, {int days = 7}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$city&days=$days&aqi=no')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List forecastData = data['forecast']['forecastday'];
        
        return forecastData.map((day) => Forecast.fromJson(day)).toList();
      } else {
        final errorMsg = response.body.isNotEmpty 
            ? jsonDecode(response.body)['error']['message'] ?? 'Ошибка API'
            : 'Ошибка ${response.statusCode}';
        throw Exception('Ошибка при запросе прогноза: $errorMsg');
      }
    } catch (e) {
      throw Exception('Не удалось загрузить прогноз погоды: $e');
    }
  }
} 