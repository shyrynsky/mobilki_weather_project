import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ecology_model.dart';
import '../config/api_keys.dart';

class EcologyService {
  final String apiKey = ApiKeys.weatherApiKey;
  final String baseUrl = 'https://api.weatherapi.com/v1';

  Future<EcologyData> getEcologyData(String city) async {
    try {
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

  Future<WaterQuality?> getWaterQuality(String city) async {
    await Future.delayed(const Duration(seconds: 1));
    return WaterQuality.mock();
  }

  Future<RadiationData?> getRadiationData(String city) async {
    await Future.delayed(const Duration(seconds: 1));
    return RadiationData.mock();
  }
} 