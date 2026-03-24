import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/location_service.dart';
import '../services/sos_service.dart';

class SosButton extends StatefulWidget {
  final List<EmergencyContact> contacts;

  const SosButton({super.key, required this.contacts});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  bool _isHolding = false;
  bool _triggered = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isHolding && !_triggered) {
        _triggered = true;
        _sendSOS();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() {
      _isHolding = true;
      _triggered = false;
    });

    _controller.forward(from: 0);
  }

  void _cancelHold() {
    setState(() {
      _isHolding = false;
    });

    _controller.reset();
  }

  Future<void> _sendSOS() async {
    _controller.reset();

    if (widget.contacts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No contacts set")));
      return;
    }

    try {
      final locationService = LocationService();
      final sosService = SosService();

      // ✅ Get raw position
      final position = await locationService.getPosition();

      // ✅ Build message with link
      String locationLink = locationService.buildMapLink(
        position.latitude,
        position.longitude,
      );

      String message = "🚨 SOS! I need help!\nLocation: $locationLink";

      List<String> numbers = widget.contacts.map((c) => c.phone).toList();

      // ✅ Send with latitude + longitude
      await sosService.sendSOS(
        contacts: numbers,
        message: message,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("SOS sent successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending SOS: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔵 Circular Progress Ring
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 6,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                );
              },
            ),

            // 🔴 Main Button
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: _isHolding ? Colors.red.shade700 : Colors.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                "HOLD\nSOS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
