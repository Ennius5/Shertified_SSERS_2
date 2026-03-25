// lib/screens/setup_message_screen.dart
import 'package:flutter/material.dart';
import '../widgets/haven_wordmark.dart';

class SetupMessageScreen extends StatefulWidget {
  const SetupMessageScreen({super.key});

  @override
  State<SetupMessageScreen> createState() => _SetupMessageScreenState();
}

class _SetupMessageScreenState extends State<SetupMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _selectedMessage = "";

  final List<String> _messageTemplates = [
    "Help! I'm in danger. My current location is:",
    "Emergency! Please come to my location immediately:",
    "I need assistance. Here's my location:",
    "SOS! Please send help to:",
  ];

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
        title: const Text("Setup Message", style: TextStyle(color: Colors.red)),
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
                  "Emergency Message",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Customize the message that will be sent to your trusted contacts.",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Message Templates
                const Text(
                  "Choose a template:",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 10),
                ..._messageTemplates.map((template) {
                  return RadioListTile<String>(
                    title: Text(
                      template,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    value: template,
                    groupValue: _selectedMessage,
                    activeColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        _selectedMessage = value!;
                        _messageController.text = value;
                      });
                    },
                  );
                }),

                const SizedBox(height: 15),

                const Text(
                  "Or write your own:",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 5),

                TextField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Write your emergency message...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedMessage = "";
                    });
                  },
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
                    onPressed: _messageController.text.isNotEmpty
                        ? () {
                            // Save message and navigate to permissions
                            Navigator.pushNamed(context, '/permissions');
                          }
                        : null,
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
    );
  }
}
