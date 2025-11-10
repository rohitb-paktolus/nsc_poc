import 'package:flutter/material.dart';

import '../../utils/route.dart';
import '../../widgets/custom_text.dart';

class LoginOptionScreen extends StatefulWidget {
  const LoginOptionScreen({super.key});

  @override
  State<LoginOptionScreen> createState() => _LoginOptionScreenState();
}

class _LoginOptionScreenState extends State<LoginOptionScreen> {
  void _onLoginEmailButton() async {
    Navigator.pushReplacementNamed(context, ROUT_LOGIN_EMAIL);
  }
  void _onLoginMobileButton() async {
    Navigator.pushReplacementNamed(context, ROUT_LOGIN_MOBILE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF2986CC),
                ),
                child: TextButton(
                  onPressed: _onLoginEmailButton,
                  child: const CustomText(
                      text: 'Login with Email and Password',
                      fontSize: 16,
                      desiredLineHeight: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF2986CC),
                ),
                child: TextButton(
                  onPressed: _onLoginMobileButton,
                  child: const CustomText(
                      text: 'Login with Mobile Number',
                      fontSize: 16,
                      desiredLineHeight: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
