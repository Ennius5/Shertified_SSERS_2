import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'widgets/advanced_map.dart';
import 'screens/sos_screen.dart';
import 'screens/sos_monitor_screen.dart';
import 'widgets/sos_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/get_started_screen.dart';
import 'screens/phone_signup_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/name_screen.dart';
import 'screens/trusted_contacts_screen.dart';
import 'screens/complete_screen.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HAVEN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      // home: const HomeScreen(),
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedScreen(),
        '/phone_signup': (context) => const PhoneSignupScreen(),
        '/otp': (context) => const OTPScreen(),
        '/name': (context) => const NameScreen(),
        '/trusted_contacts': (context) => const TrustedContactsScreen(),
        '/complete': (context) => const CompleteScreen(),
        '/usersos': (context) => const HomeScreen(),
        '/falseLogout': (context) => const CompleteScreen(),
        '/lgusos': (context) => const SosMonitorScreen(),
      },
    );
  }
}
