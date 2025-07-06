import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/screens/client/contratado_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chambea/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FcmService {
  static Future<void> initialize(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await messaging.getToken();
      if (token != null) {
        try {
          final idToken = await user.getIdToken();
          await http.post(
            Uri.parse('https://chambea.lat/api/update-fcm-token'),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'fcm_token': token}),
          );
        } catch (e) {
          print('Error updating FCM token: $e');
        }
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;
      if (notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification.title}: ${notification.body}'),
          ),
        );
      }
      _handleNotificationData(context, data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationData(context, message.data);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationData(context, initialMessage.data);
    }
  }

  static void _handleNotificationData(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final type = data['type'];
    final requestId = int.tryParse(data['service_request_id'] ?? '');
    final workerId = int.tryParse(data['worker_id'] ?? '');
    final accountType = await ApiService.getAccountType();

    if (requestId != null && workerId != null) {
      if (type == 'contract_accepted' || type == 'service_started') {
        if (accountType == 'Client') {
          context.read<ProposalsBloc>().add(FetchServiceRequests());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ContratadoScreen(requestId: requestId, workerId: workerId),
            ),
          );
        }
      } else if (type == 'new_message') {
        if (accountType == 'Client' || accountType == 'Chambeador') {
          context.read<ProposalsBloc>().add(FetchProposals(requestId));
        }
      }
    }
  }
}
