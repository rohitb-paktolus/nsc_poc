import 'package:flutter/material.dart';
import 'package:multi_auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_text.dart';

class SocialLogin extends StatefulWidget {
  const SocialLogin({super.key});

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  final AuthService _authService = AuthService();
  String userName = "Anonymous";
  String userProvider = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Anonymous";
      userProvider = prefs.getString('userProvider') ?? "";
    });
  }

  Future<void> _saveUserInfo(String name, String provider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userProvider', provider);
  }

  Future<void> _clearUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userProvider');
  }

  Future<void> _handleSignIn(String provider) async {
    Map<String, String?>? user;
    switch (provider) {
      case 'Google':
        user = await _authService.signInWithGoogle();
        print(user);
        break;
      case 'Facebook':
        user = await _authService.signInWithFacebook();
        print(user);
        break;
    }

    if (user != null) {
      setState(() {
        userName = user?['name'] ?? "Anonymous";
        userProvider = user?['provider'] ?? provider;
      });
      await _saveUserInfo(userName, userProvider);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    await _clearUserInfo();
    setState(() {
      userName = "Anonymous";
      userProvider = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome, $userName!',
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            if (userProvider.isNotEmpty)
              Text(
                'Signed in with $userProvider',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            if (userName == "Anonymous")
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF2986CC),
                  ),
                  child: TextButton(
                    onPressed: () => _handleSignIn("Google"),
                    child: const CustomText(
                        text: 'Sign In with Google',
                        fontSize: 16,
                        desiredLineHeight: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (userName == "Anonymous")
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF2986CC),
                  ),
                  child: TextButton(
                    onPressed: () => _handleSignIn("Facebook"),
                    child: const CustomText(
                        text: 'Sign In with Facebook',
                        fontSize: 16,
                        desiredLineHeight: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
