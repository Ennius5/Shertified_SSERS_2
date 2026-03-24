import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_contact.dart';
import '../widgets/sos_button.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final CollectionReference contactsRef =
      FirebaseFirestore.instance.collection('contacts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("SOS Contacts"),
        backgroundColor: Colors.grey[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
  stream: contactsRef.snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final contacts = snapshot.data!.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return EmergencyContact(
        name: data['name'] ?? 'No Name',
        phone: data['phone'] ?? 'No Phone',
      );
    }).toList();

return Center(
  child: SosButton(contacts: contacts),
);
  },
),
    );
  }
}