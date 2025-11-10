import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frequent_flow/main.dart';

import '../widgets/custom_text.dart';

class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  State<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final String serverUrl = "http://192.168.1.3:3000/send-notification";
  String? _fcmToken;

  Future<void> sendNotification(String fcmToken) async {
    final dio = Dio();

    try {
      final response = await dio.post(serverUrl,
          data: {
            'token': fcmToken,
            'title': 'Hello from Flutter',
            'body': "This is a test notification",
          },
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        print("Notification sent successfully");
        print("Response: ${response.data}");
      } else {
        print(
            "Failed to send notification. Status code: ${response.statusCode}");
        print("Error: ${response.data}");
      }
    } on DioException catch (error) {
      if (error.response != null) {
        print("DioException Response: ${error.response?.data}");
      } else {
        print("DioException: ${error.message}");
      }
    } catch (error) {
      print("Unexpected Error: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage event) {
        if (event.notification != null) {
          _showNotification(event.notification!);
        }
      },
    );
    _getToken();
  }

  Future<void> _showNotification(RemoteNotification notification) async {
    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails();
    const androidNotificationDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: "This channel is used for important notifications.",
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      notificationDetails,
    );
  }

  Future<void> _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    setState(() {
      _fcmToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Push notifications"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF2986CC),
            ),
            child: TextButton(
              onPressed: () {
                if (_fcmToken != null) {
                  sendNotification(_fcmToken!);
                }
              },
              child: const CustomText(
                  text: 'Send push notification',
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
