import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<String?> getCurrentCity() async {
    try {
      // Запрашиваем разрешение на доступ к геолокации
      final status = await Permission.location.request();
      
      if (status.isGranted) {
        // Получаем текущую позицию
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Преобразуем координаты в адрес
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
          localeIdentifier: 'ru',
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          return placemark.locality ?? placemark.subAdministrativeArea;
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