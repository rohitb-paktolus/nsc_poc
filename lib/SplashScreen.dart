import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frequent_flow/utils/pref_key.dart';
import 'package:frequent_flow/utils/prefs.dart';
import 'package:local_auth/local_auth.dart';

import '../../utils/route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final auth = LocalAuthentication();
  bool biometricFailedOrCancelled = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _initFlow();
    super.initState();
  }

  Future<void> _initFlow() async {
    // Check if user is logged in
    if (Prefs.getBool(LOGIN_FLAG)) {
      try {
        // Check if biometrics available
        final List<BiometricType> availableBiometrics =
            await auth.getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty) {
          // Check if biometrics enabled
          bool isBiometricEnabled = Prefs.getBool(BIOMETRIC_FLAG);
          if (isBiometricEnabled) {
            await _authenticate();
          } else {
            _navigateToDashboard();
          }
        } else {
          _navigateToDashboard();
        }
      } catch (e) {
        _navigateToLogin();
        debugPrint("Error: ${e.toString()}");
      }
    } else {
      _navigateToLogin();
    }
  }

  Future<void> _authenticate() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access the app',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      debugPrint("isAuthenticated: $isAuthenticated");
    } on LocalAuthException catch (e) {
      debugPrint("LocalAuthError: ${e.code}");
      setState(() {
        biometricFailedOrCancelled = true;
      });
    } on PlatformException catch (e) {
      debugPrint("Authentication failed");
      isAuthenticated = false;
    } catch (e) {
      debugPrint("An error occurred: $e");
      isAuthenticated = false;
    }

    if (isAuthenticated) {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, ROUT_DASHBOARD);
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, ROUT_LOGIN_EMAIL);
  }

  @override
  Widget build(BuildContext context) {
    if (biometricFailedOrCancelled) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("App is locked!"),
              ElevatedButton(
                  onPressed: () {
                    _authenticate();
                  },
                  child: const Text("Unlock Now"))
            ],
          ),
        ),
      );
    }
    return Scaffold(
        body: Center(
      child: Image.asset(
        'assets/images/Splashscreen.png',
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
    ));
  }
}
