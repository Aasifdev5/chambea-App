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
        return response['data'] ?? [];
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
