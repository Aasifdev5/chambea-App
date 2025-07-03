import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class FcmService {
  static Future<void> initialize(BuildContext? context) async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else {
      print('Notification permission denied');
    }

    // Get and update FCM token
    String? token = await messaging.getToken();
    if (token != null) {
      await _updateFcmToken(token);
    }

    // Handle token refresh
    messaging.onTokenRefresh.listen((newToken) async {
      await _updateFcmToken(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${message.notification?.title ?? 'Notificación'}: ${message.notification?.body ?? ''}',
            ),
          ),
        );
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _updateFcmToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user for FCM token update');
      return;
    }

    final idToken = await user.getIdToken();
    final response = await http.post(
      Uri.parse('https://chambea.lat/api/update-fcm-token'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'fcm_token': token}),
    );

    if (response.statusCode == 200) {
      print('FCM token updated successfully');
    } else {
      print('Failed to update FCM token: ${response.body}');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
  }
}
