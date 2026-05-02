import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/biometric_lock_screen.dart';
import 'data/services/offline_service.dart';
import 'data/services/notification_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

  runApp(GlobalNotificationListener(child: AutodemyApp(showBiometrics: showBiometrics)));
}

class GlobalNotificationListener extends StatefulWidget {
  final Widget child;
  const GlobalNotificationListener({super.key, required this.child});

  @override
  State<GlobalNotificationListener> createState() => _GlobalNotificationListenerState();
}

class _GlobalNotificationListenerState extends State<GlobalNotificationListener> {
  StreamSubscription? _notifSub;

  @override
  void initState() {
    super.initState();
    _notifSub = NotificationService.notifications.listen((notif) {
      _showGlobalOverlay(notif);
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  void _showGlobalOverlay(Map<String, dynamic> notif) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif['title'] ?? 'New Announcement', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(notif['body'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: AppTheme.accent,
          onPressed: () => scaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AutodemyApp extends StatelessWidget {
  final bool showBiometrics;
  const AutodemyApp({super.key, this.showBiometrics = false});

  @override
  Widget build(BuildContext context) {
    Widget homeScreen = const SplashScreen();
    
    // Only wrap with BiometricLockScreen if enabled in profile
    if (showBiometrics) {
      homeScreen = BiometricLockScreen(child: const SplashScreen());
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Autodemy',
      theme: AppTheme.lightTheme,
      home: homeScreen,
    );
  }
}