import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frequent_flow/utils/pref_key.dart';
import 'package:frequent_flow/utils/prefs.dart';
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
  bool isBiometricsOn = false;
  bool isBiometricsAvailable = false;

  @override
  void initState() {
    _checkBiometricsAvailability();
    _loadBiometricState();
    super.initState();
  }

  Future<void> _checkBiometricsAvailability() async {
    bool canCheckBiometrics =
        await auth.isDeviceSupported() || await auth.canCheckBiometrics;
    setState(() {
      isBiometricsAvailable = canCheckBiometrics;
    });
  }

  void _loadBiometricState() {
    setState(() {
      isBiometricsOn = Prefs.getBool(BIOMETRIC_FLAG);
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() {
      isBiometricsOn = value;
    });
    await Prefs.setBool(BIOMETRIC_FLAG, value);
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
        title: const Text("Biometrics"),
      ),
      body: ListView(
        children: [
          if (!isBiometricsAvailable)
            const Center(
              child: Text("Biometrics feature not available on this device"),
            ),
          if (isBiometricsAvailable)
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Turn on Biometrics"),
                  Switch(
                    value: isBiometricsOn,
                    onChanged: _toggleBiometric,
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
