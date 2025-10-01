import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:retry/retry.dart';

class ApiService {
  static const String baseUrl = 'https://chambea.lat';
  static const int timeoutSeconds = 30;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  /// Returns headers with Firebase ID token for authenticated requests
  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    String? token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to retrieve Firebase ID token');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Returns headers for multipart requests
  static Future<Map<String, String>> _getMultipartHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    String? token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to retrieve Firebase ID token');
    }
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  /// Performs a GET request with retry logic
  static Future<Map<String, dynamic>> get(String endpoint) async {
    return _retryRequest(() async {
      final headers = await _getHeaders();
      print('DEBUG: GET request to $baseUrl$endpoint with headers: $headers');

      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      return _handleResponse(response, endpoint, 'GET');
    });
  }

  /// Performs a POST request with retry logic
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _retryRequest(() async {
      final headers = await _getHeaders();
      print(
        'DEBUG: POST request to $baseUrl$endpoint with headers: $headers, body: $body',
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      return _handleResponse(response, endpoint, 'POST');
    });
  }

  /// Performs a PUT request with retry logic
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _retryRequest(() async {
      final headers = await _getHeaders();
      print(
        'DEBUG: PUT request to $baseUrl$endpoint with headers: $headers, body: $body',
      );

      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      return _handleResponse(response, endpoint, 'PUT');
    });
  }

  /// Uploads a file without additional form fields
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String fieldName,
    File file,
  ) async {
    return _retryRequest(() async {
      final headers = await _getMultipartHeaders();
      print('DEBUG: File upload to $baseUrl$endpoint with headers: $headers');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      final response = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );
      final responseBody = await response.stream.bytesToString();

      print(
        'DEBUG: File upload response: ${response.statusCode} - $responseBody',
      );

      return _handleResponse(
        http.Response(responseBody, response.statusCode),
        endpoint,
        'POST',
      );
    });
  }

  /// Uploads a file with additional form fields
  static Future<Map<String, dynamic>> uploadFileWithFields(
    String endpoint,
    String fieldName,
    File file,
    Map<String, dynamic> fields,
  ) async {
    return _retryRequest(() async {
      final headers = await _getMultipartHeaders();
      print(
        'DEBUG: File upload to $baseUrl$endpoint with headers: $headers, fields: $fields',
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(headers);
      request.fields.addAll(
        fields.map((key, value) => MapEntry(key, value?.toString() ?? '')),
      );
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      final response = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );
      final responseBody = await response.stream.bytesToString();

      print(
        'DEBUG: File upload response: ${response.statusCode} - $responseBody',
      );

      return _handleResponse(
        http.Response(responseBody, response.statusCode),
        endpoint,
        'POST',
      );
    });
  }

  /// Uploads identity card with retry logic
  static Future<Map<String, dynamic>> uploadIdentityCard(
    String endpoint,
    String idNumber,
    File frontImage,
    File backImage,
  ) async {
    return _retryRequest(() async {
      final headers = await _getMultipartHeaders();
      print(
        'DEBUG: Identity card upload to $baseUrl$endpoint with headers: $headers, idNumber: $idNumber',
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(headers);
      request.fields['id_number'] = idNumber;
      request.files.add(
        await http.MultipartFile.fromPath('front_image', frontImage.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('back_image', backImage.path),
      );

      final response = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );
      final responseBody = await response.stream.bytesToString();

      print(
        'DEBUG: Identity card upload response: ${response.statusCode} - $responseBody',
      );

      return _handleResponse(
        http.Response(responseBody, response.statusCode),
        endpoint,
        'POST',
      );
    });
  }

  /// Fetches the account type for the authenticated user
  static Future<String> getAccountType() async {
    return _retryRequest(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final headers = await _getHeaders();
      final endpoint = '/api/account-type/${user.uid}';
      print('DEBUG: GET request to $baseUrl$endpoint with headers: $headers');

      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      final body = _handleResponse(response, endpoint, 'GET');
      return body['data']['account_type']?.toString() ?? 'unknown';
    });
  }

  /// Fetches chats for the authenticated user, filtered by account type
  static Future<List<Map<String, dynamic>>> getChats() async {
    return _retryRequest(() async {
      final headers = await _getHeaders();
      print('DEBUG: GET request to $baseUrl/api/chats with headers: $headers');

      final response = await http
          .get(Uri.parse('$baseUrl/api/chats'), headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      final body = _handleResponse(response, '/api/chats', 'GET');
      return List<Map<String, dynamic>>.from(body['data'] ?? []);
    });
  }

  /// Retries the request on transient errors
  static Future<T> _retryRequest<T>(Future<T> Function() request) async {
    return retry(
      request,
      maxAttempts: maxRetries,
      delayFactor: retryDelay,
      randomizationFactor: 0.5,
      onRetry: (e) {
        print('DEBUG: Retrying request due to error: $e');
      },
      retryIf: (e) => e is http.ClientException || e is TimeoutException,
    );
  }

  /// Handles HTTP responses and returns the response body
  static Map<String, dynamic> _handleResponse(
    http.Response response,
    String endpoint,
    String method,
  ) {
    print(
      'DEBUG: Response from $method $baseUrl$endpoint: ${response.statusCode} - ${response.body}',
    );

    if (response.body.startsWith('<!DOCTYPE html')) {
      throw Exception(
        'Server returned HTML instead of JSON for $method $endpoint: ${response.statusCode} - ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...',
      );
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body; // Return the response body for all status codes
    } catch (e) {
      throw Exception(
        'Invalid JSON format for $method $endpoint: ${response.body}',
      );
    }
  }
}
