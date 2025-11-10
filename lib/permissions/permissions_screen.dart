import 'package:flutter/material.dart';
import 'package:flutter_permissions/flutter_permissions.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permissions"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Location"),
            onTap: () {
              print("Requesting location permission");
              PermissionManager.requestPermission(PermissionType.location);
            },
          ),
          ListTile(
            title: Text("Notifications"),
            onTap: () {
              print("Requesting Notifications permission");
              PermissionManager.requestPermission(PermissionType.notifications);
            },
          ),
          ListTile(
            title: Text("Camera"),
            onTap: () {
              print("Requesting Camera permission");
              PermissionManager.requestPermission(PermissionType.camera);
            },
          ),
          ListTile(
            title: Text("Microphone"),
            onTap: () {
              print("Requesting Microphone permission");
              PermissionManager.requestPermission(PermissionType.microphone);
            },
          ),
          ListTile(
            title: Text("Contacts"),
            onTap: () {
              print("Requesting Contacts permission");
              PermissionManager.requestPermission(PermissionType.contacts);
            },
          ),
        ],
      ),
    );
  }
}
