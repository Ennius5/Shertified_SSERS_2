import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

class ContactStorage {
  static const String key = "emergency_contacts";

  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        contacts.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(key, data);
  }

  Future<List<EmergencyContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    return data
        .map((e) => EmergencyContact.fromJson(jsonDecode(e)))
        .toList();
  }
}