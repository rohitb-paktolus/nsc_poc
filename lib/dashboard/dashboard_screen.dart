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
  final List<DashboardItem> features = [
    DashboardItem(
      title: "Map Integration",
      icon: Icons.map_rounded,
      color: Colors.blue,
      route: ROUT_MAP_INTEGRATION,
    ),
    DashboardItem(
      title: "Change Password",
      icon: Icons.lock_reset_rounded,
      color: Colors.orange,
      route: ROUT_CHANGE_PASSWORD,
    ),
    DashboardItem(
      title: "Video Player",
      icon: Icons.videocam_rounded,
      color: Colors.purple,
      route: ROUTE_VIDEO,
    ),
    DashboardItem(
      title: "Generate QR",
      icon: Icons.qr_code_2_rounded,
      color: Colors.green,
      route: ROUT_QR_CODE,
    ),
    DashboardItem(
      title: "Scan QR",
      icon: Icons.qr_code_scanner_rounded,
      color: Colors.red,
      route: ROUT_SCAN_QR_CODE,
    ),
  ];

  void _onLogOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Prefs.clear();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  ROUT_LOGIN_EMAIL,
                      (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: const Color(0xFF2986CC),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              // Profile or settings action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2986CC).withOpacity(0.9),
                  const Color(0xFF2986CC).withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: Color(0xFF2986CC),
                  ),
                ),
                const SizedBox(height: 16),
                const CustomText(
                  text: 'Welcome Back!',
                  fontSize: 18,
                  desiredLineHeight: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: 'Manage your features efficiently',
                  fontSize: 14,
                  desiredLineHeight: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),

          // Features Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return _FeatureCard(
                    title: feature.title,
                    icon: feature.icon,
                    color: feature.color,
                    onTap: () {
                      Navigator.of(context).pushNamed(feature.route);
                    },
                  );
                },
              ),
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _onLogOut,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 8),
                    CustomText(
                      text: 'Logout',
                      fontSize: 16,
                      desiredLineHeight: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              // Title
              CustomText(
                text: title,
                fontSize: 14,
                desiredLineHeight: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Colors.grey[800]!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Subtitle
              CustomText(
                text: 'Tap to open',
                fontSize: 10,
                desiredLineHeight: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: Colors.grey[500]!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}