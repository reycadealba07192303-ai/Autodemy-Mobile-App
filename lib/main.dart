import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/biometric_lock_screen.dart';
import 'data/services/offline_service.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Offline Queue
  await OfflineService.init();

  // Initialize Notifications
  await NotificationService.initialize();
  
  // Check Biometric Preference for the last user
  final prefs = await SharedPreferences.getInstance();
  final userDataStr = prefs.getString('user_data');
  bool showBiometrics = false;
  
  if (userDataStr != null) {
    try {
      final userData = jsonDecode(userDataStr);
      final userName = userData['name'];
      showBiometrics = prefs.getBool('biometric_enabled_$userName') ?? false;
    } catch (e) {
      debugPrint("Error parsing user data for biometrics: $e");
    }
  }
  
  // Initialize Firebase in the background
  Firebase.initializeApp().then((_) {
    debugPrint("AUTODEMY: Firebase initialized successfully.");
  }).catchError((e) {
    debugPrint("AUTODEMY: Firebase initialization error: $e");
  });

  runApp(AutodemyApp(showBiometrics: showBiometrics));
}

class AutodemyApp extends StatelessWidget {
  final bool showBiometrics;
  const AutodemyApp({super.key, required this.showBiometrics});

  @override
  Widget build(BuildContext context) {
    Widget homeScreen = const SplashScreen();
    
    // Only wrap with BiometricLockScreen if enabled in profile
    if (showBiometrics) {
      homeScreen = BiometricLockScreen(child: const SplashScreen());
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Autodemy',
      theme: AppTheme.lightTheme,
      home: homeScreen,
    );
  }
}