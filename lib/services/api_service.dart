import 'dart:io';
import 'dart:async'; // Added for TimeoutException
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
  static Future<Map<String, String>> getHeaders() async {
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
  static Future<Map<String, String>> getMultipartHeaders() async {
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

  /// Checks if the user is logged in using Firebase Authentication
  static Future<bool> isLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await user.getIdToken();
    return token != null;
  }

  /// Performs a GET request with retry logic
  static Future<Map<String, dynamic>> get(String endpoint) async {
    return _retryRequest(() async {
      final headers = await getHeaders();
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
      final headers = await getHeaders();
      print(
        'DEBUG: POST request to $baseUrl$endpoint with headers: $headers, body: $body',
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: json.encode(body),
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
      final headers = await getHeaders();
      print(
        'DEBUG: PUT request to $baseUrl$endpoint with headers: $headers, body: $body',
      );

      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      return _handleResponse(response, endpoint, 'PUT');
    });
  }

  /// Performs a DELETE request with retry logic
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    return _retryRequest(() async {
      final headers = await getHeaders();
      print(
        'DEBUG: DELETE request to $baseUrl$endpoint with headers: $headers',
      );

      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      return _handleResponse(response, endpoint, 'DELETE');
    });
  }

  /// Uploads an image with retry logic
  static Future<Map<String, dynamic>> uploadImage(
    String endpoint,
    File image,
  ) async {
    return _retryRequest(() async {
      final headers = await getMultipartHeaders();
      print('DEBUG: Image upload to $baseUrl$endpoint with headers: $headers');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );
      final responseBody = await response.stream.bytesToString();

      print(
        'DEBUG: Image upload response: ${response.statusCode} - $responseBody',
      );

      return _handleResponse(
        http.Response(responseBody, response.statusCode),
        endpoint,
        'POST',
      );
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

  /// Handles HTTP responses and throws appropriate exceptions
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
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'statusCode': response.statusCode, 'body': body};
      } else if (response.statusCode == 401) {
        throw Exception(
          'Unauthorized: Invalid or missing authentication token',
        );
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found: $endpoint');
      } else if (response.statusCode == 405) {
        throw Exception(
          'Method Not Allowed: $method is not supported for $endpoint',
        );
      } else if (response.statusCode == 422) {
        throw Exception(
          'Validation error: ${body['message'] ?? response.body}',
        );
      } else {
        throw Exception(
          'Request failed: ${response.statusCode} - ${body['message'] ?? response.body}',
        );
      }
    } catch (e) {
      throw Exception('Invalid JSON format for $method $endpoint: $e');
    }
  }
}
