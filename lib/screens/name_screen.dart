// lib/screens/name_screen.dart
import 'package:flutter/material.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = true; // name validation disabled

  void _validateName(String value) {
    // name validation disabled, keep handler for compatibility
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // LOGO
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "HA",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.shield_outlined, color: Colors.red, size: 40),
                SizedBox(width: 5),
                Text(
                  "EN",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "A Space for Safety",
              style: TextStyle(color: Colors.red),
            ),

            const Spacer(),

            // RED CONTAINER (BOTTOM CARD)
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
                    "Enter your full name for verification purposes.",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Full Name",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 5),

                  TextField(
                    controller: _nameController,
                    onChanged: _validateName,
                    decoration: InputDecoration(
                      hintText: "Write your full name",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                      onPressed: () {
                        // Navigate to trusted contacts
                        Navigator.pushReplacementNamed(
                          context,
                          '/trusted_contacts',
                        );
                      },
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
