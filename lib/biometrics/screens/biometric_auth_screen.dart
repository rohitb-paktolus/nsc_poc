import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frequent_flow/widgets/custom_alert.dart';
import 'package:local_auth/local_auth.dart';

import '../../widgets/custom_text.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticate() async {
    try {
      // Check if the device supports biometrics
      bool canAuthenticate =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (!canAuthenticate) {
        _showAlert("Error",
            "Biometric authentication is not available on this device.");
        return;
      }

      if (availableBiometrics.isNotEmpty) {
        // Attempt to authenticate using biometrics
        bool isAuthenticated = await auth.authenticate(
          localizedReason: 'Authenticate to access the app',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (isAuthenticated) {
          _showAlert("Success", "You have successfully authenticated!");
        } else {
          _showAlert("Failed", "Authentication failed. Please try again.");
        }
      } else {
        _showAlert("Alert", "No biometrics available");
      }
    } on PlatformException catch (e) {
      _showAlert("Failed", "Authentication failed. Please try again.");
    } catch (e) {
      _showAlert("Error", "An error occurred: $e");
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlert(
        title: title,
        message: message,
        buttonText: "OK",
        onButtonTap: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biometric Authentication"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF2986CC),
            ),
            child: TextButton(
              onPressed: _authenticate,
              child: const CustomText(
                  text: 'Authenticate with Biometrics',
                  fontSize: 16,
                  desiredLineHeight: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
      ),
    );
  }
}
