import 'package:cloud_firestore/cloud_firestore.dart';

class SosService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendSOS({
    required List<String> contacts,
    required String message,
    required double latitude,
    required double longitude,
  }) async {
    try {
await firestore.collection("sos_events").add({
  "contacts": contacts,
  "message": message,
  "timestamp": FieldValue.serverTimestamp(),
  "status": "pending",
  "lat": latitude,
  "lng": longitude,
  "resolvedAt": null,
});
    } catch (e) {
      throw Exception("Failed to send SOS: $e");
    }
  }
}