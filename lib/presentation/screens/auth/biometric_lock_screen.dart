import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_theme.dart';

class BiometricLockScreen extends StatefulWidget {
  final Widget child; // The screen to show after successful auth
  const BiometricLockScreen({super.key, required this.child});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  String _errorMessage = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
    
    // Automatically trigger auth on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      // biometricOnly: false allows the OS to fallback to PIN/Pattern/Password automatically
      final didAuth = await _auth.authenticate(
        localizedReason: 'Please verify your identity to access Autodemy',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (didAuth) {
        setState(() => _isAuthenticated = true);
      } else {
        setState(() => _errorMessage = 'Authentication cancelled or failed.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Security error: Your device might not have a lock set up.';
      });
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) return widget.child;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Vault Icon with pulsating effect (simulated by design)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: AppTheme.accent.withOpacity(0.1), blurRadius: 30, spreadRadius: 5)
                    ],
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    size: 80,
                    color: AppTheme.accent,
                  ),
                ),

                const SizedBox(height: 48),

                const Text(
                  'SYSTEM LOCKED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'AUTODEMY SECURITY PORTAL',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const Spacer(),

                // Main Unlock Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _isAuthenticating ? null : _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 20,
                        shadowColor: AppTheme.accent.withOpacity(0.4),
                      ),
                      icon: _isAuthenticating 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.primary))
                        : const Icon(Icons.lock_open_rounded, size: 28),
                      label: Text(
                        _isAuthenticating ? 'VERIFYING...' : 'UNLOCK SYSTEM',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                Text(
                  'Uses your phone\'s PIN, Pattern, or Biometrics',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),

                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],

                const Spacer(flex: 2),

                // Branding at bottom
                Opacity(
                  opacity: 0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      const Text('SECURED BY AUTODEMY', style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
