import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:chambea/services/api_service.dart';
import 'package:retry/retry.dart';

class UserService {
  Future<List<dynamic>> fetchClients() async {
    try {
      final response = await retry(
        () => ApiService.get('/api/clients'),
        maxAttempts: ApiService.maxRetries,
        delayFactor: ApiService.retryDelay,
        onRetry: (e) {
          print('DEBUG: Retrying client fetch due to error: $e');
        },
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
      );
      if (response['status'] == 'success') {
        final clients = response['data'] as List<dynamic>;
        // Strip /storage from profile_photo if present
        return clients.map((client) {
          if (client['profile_photo'] != null && client['profile_photo'] is String) {
            client['profile_photo'] = (client['profile_photo'] as String).replaceFirst('storage/', '');
          }
          return client;
        }).toList();
      } else {
        throw Exception(
          'API returned unsuccessful status: ${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('ERROR: Failed to fetch clients: $e');
      throw Exception('Error fetching clients: $e');
    }
  }
}