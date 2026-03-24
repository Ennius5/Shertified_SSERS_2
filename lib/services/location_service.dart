import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> getLocationLink() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition();

    return "https://maps.google.com/?q=${position.latitude},${position.longitude}";
  }
}