import 'package:flutter/material.dart';
import 'package:frequent_flow/utils/prefs.dart';
import 'package:frequent_flow/utils/route.dart';

import '../widgets/custom_text.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> features = [
    "Map Integration",
    "Change Password",
    "Video",
    "Generate QR",
    "Scan QR"
  ];

  void _onLogOut() {
    Prefs.clear();
    Navigator.of(context).pushNamedAndRemoveUntil(
      ROUT_LOGIN_EMAIL,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(features[index]),
                  leading: const Icon(
                    Icons.label,
                    color: Color(0xFF2986CC),
                  ),
                  onTap: () {
                    switch (features[index]) {
                      case "Map Integration":
                        Navigator.of(context).pushNamed(ROUT_MAP_INTEGRATION);
                        break;
                      case "Change Password":
                        Navigator.of(context).pushNamed(ROUT_CHANGE_PASSWORD);
                        break;
                      case "Video":
                        Navigator.of(context).pushNamed(ROUTE_VIDEO);
                        break;
                      case "Generate QR":
                        Navigator.of(context).pushNamed(ROUT_QR_CODE);
                        break;
                      case "Scan QR":
                        Navigator.of(context).pushNamed(ROUT_SCAN_QR_CODE);
                        break;
                    }
                  },
                );
              },
            ),
          ),
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
                onPressed: _onLogOut,
                child: const CustomText(
                    text: 'Logout',
                    fontSize: 16,
                    desiredLineHeight: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
