import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getPosition() async {
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

    return await Geolocator.getCurrentPosition();
  }

  /// Optional: still keep your link generator
  String buildMapLink(double lat, double lng) {
    return "https://maps.google.com/?q=$lat,$lng";
  }
}