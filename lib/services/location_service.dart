import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';

class LocationDetails {
  final double? latitude;
  final double? longitude;
  final String locationName;
  final String deviceName;

  LocationDetails({
    this.latitude,
    this.longitude,
    required this.locationName,
    required this.deviceName,
  });
}

class LocationService {
  static Future<LocationDetails> getCurrentLocationAndDevice() async {
    String deviceName = 'Mobile Device';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model} (Android)';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = '${iosInfo.name} (${iosInfo.systemName})';
      }
    } catch (_) {
      deviceName = Platform.isAndroid ? 'Android Phone' : 'Apple iPhone';
    }

    double? lat;
    double? lon;
    String locationName = 'Office / Remote';

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
          lat = position.latitude;
          lon = position.longitude;
          locationName = 'GPS ($lat, $lon)';
        }
      }
    } catch (_) {
      // Graceful fallback to default location string
    }

    return LocationDetails(
      latitude: lat,
      longitude: lon,
      locationName: locationName,
      deviceName: deviceName,
    );
  }
}
