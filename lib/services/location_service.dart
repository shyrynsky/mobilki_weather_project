import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static Future<String?> getCurrentCity() async {
    try {
      final status = await Permission.location.request();
      
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&accept-language=ru'
        ));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'];
          return address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'];
        }
      }
      return null;
    } catch (e) {
      print('Ошибка при получении местоположения: $e');
      return null;
    }
  }

  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
} 