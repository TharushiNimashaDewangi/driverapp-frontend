import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart'; // Add the import for LoginScreen
import 'screens/dashboard.dart'; // Add the import for Dashboard
import 'pushNotificationSystem/push_notification_system.dart'; // Add the import for PushNotificationSystem

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
  await pushNotificationSystem.requestNotificationPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drivers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'MontserratRegular',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.white, // Text and icon color
          secondary: Colors.grey, // Accent color
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900], // Button color
            foregroundColor: Colors.white, // Text color
          ),
        ),
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : Dashboard(),
    );
  }
}
