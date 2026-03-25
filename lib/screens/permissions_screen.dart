// lib/screens/permissions_screen.dart
import 'package:flutter/material.dart';
import '../widgets/haven_wordmark.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _locationGranted = false;
  bool _smsGranted = false;
  bool _callGranted = false;
  bool _notificationGranted = false;

  void _simulatePermissionGrant(String type) {
    setState(() {
      switch (type) {
        case 'location':
          _locationGranted = true;
          break;
        case 'sms':
          _smsGranted = true;
          break;
        case 'call':
          _callGranted = true;
          break;
        case 'notification':
          _notificationGranted = true;
          break;
      }
    });
  }

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
          "Allow Permissions",
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
                  "Allow Permissions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Allow access so emergency help reaches you instantly.",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Location Permission
                _buildPermissionTile(
                  icon: Icons.location_on,
                  title: "Location",
                  description:
                      "Location helps your contacts and responders find you immediately in an emergency.",
                  isGranted: _locationGranted,
                  onTap: () => _simulatePermissionGrant('location'),
                ),
                const SizedBox(height: 12),

                // SMS Permission
                _buildPermissionTile(
                  icon: Icons.message,
                  title: "SMS",
                  description:
                      "SMS ensures your emergency message is sent even without internet.",
                  isGranted: _smsGranted,
                  onTap: () => _simulatePermissionGrant('sms'),
                ),
                const SizedBox(height: 12),

                // Call Permission
                _buildPermissionTile(
                  icon: Icons.phone,
                  title: "Call",
                  description: "Allow calls to emergency contacts.",
                  isGranted: _callGranted,
                  onTap: () => _simulatePermissionGrant('call'),
                ),
                const SizedBox(height: 12),

                // Notifications Permission
                _buildPermissionTile(
                  icon: Icons.notifications,
                  title: "Notifications",
                  description:
                      "Notifications let you know your alert has been sent successfully.",
                  isGranted: _notificationGranted,
                  onTap: () => _simulatePermissionGrant('notification'),
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
                    onPressed:
                        _locationGranted &&
                            _smsGranted &&
                            _callGranted &&
                            _notificationGranted
                        ? () {
                            Navigator.pushNamed(context, '/complete');
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

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isGranted)
            const Icon(Icons.check_circle, color: Colors.green, size: 24)
          else
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Allow",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
