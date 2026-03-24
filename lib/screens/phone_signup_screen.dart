import 'package:flutter/material.dart';

class PhoneSignupScreen extends StatefulWidget {
  const PhoneSignupScreen({super.key});

  @override
  State<PhoneSignupScreen> createState() => _PhoneSignupScreenState();
}

class _PhoneSignupScreenState extends State<PhoneSignupScreen> {
  bool isChecked = false;
  final TextEditingController _phoneController = TextEditingController();

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
                    "Enter your phone number to verify one. After that, help will be just one tap away.",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Phone Number",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 5),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "e.g., 09123456789",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                        activeColor: Colors.white,
                        checkColor: Colors.red,
                      ),
                      const Text(
                        "Agree with Terms and Conditions",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
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
                      onPressed: () {
                        // Navigate to OTP screen
                        Navigator.pushNamed(context, '/otp');
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
