// lib/screens/trusted_contacts_screen.dart
import 'package:flutter/material.dart';
import '../widgets/haven_wordmark.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  // Hardcoded contacts
  final List<Contact> _contacts = [
    Contact(name: "Maria Santos", isSelected: false),
    Contact(name: "Juan Dela Cruz", isSelected: false),
    Contact(name: "Ana Reyes", isSelected: false),
    Contact(name: "Carlos Mendoza", isSelected: false),
    Contact(name: "Rosa Fernandez", isSelected: false),
  ];

  int _selectedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Trusted Contacts",
          style: TextStyle(color: Colors.red),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Spacer(),
          // Logo
          const HavenWordmark(height: 45),
          const SizedBox(height: 5),
          const Text(
            "A Space for Safety",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          const Spacer(),
          // Bottom Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Trusted Contacts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Select 2-5 people who will be notified instantly in an emergency.",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 350,
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red[100],
                            child: const Icon(
                              Icons.person,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            _contacts[index].name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Checkbox(
                            value: _contacts[index].isSelected,
                            onChanged: (value) {
                              setState(() {
                                _contacts[index].isSelected = value ?? false;
                                _selectedCount += value == true ? 1 : -1;
                              });
                            },
                            activeColor: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Show selected count
                Center(
                  child: Text(
                    "Selected: $_selectedCount / 5",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _selectedCount >= 2 && _selectedCount <= 5
                        ? () {
                            // Save selected contacts and navigate to complete screen
                            Navigator.pushReplacementNamed(
                              context,
                              '/complete',
                            );
                          }
                        : null,
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Contact {
  String name;
  bool isSelected;

  Contact({required this.name, required this.isSelected});
}
