import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:retry/retry.dart';
import 'package:chambea/models/review.dart';

class ReviewService {
  static const String baseUrl = 'https://chambea.lat/api';

  /// Fetches reviews for a given worker ID.
  Future<List<Review>> fetchWorkerReviews(String workerId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final token = await user.getIdToken();
      final response = await retry(
        () async {
          final response = await http.get(
            Uri.parse('$baseUrl/reviews/worker/$workerId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'Request to $baseUrl/reviews/worker/$workerId timed out',
              );
            },
          );
          return {
            'statusCode': response.statusCode,
            'body': response.body.isNotEmpty ? jsonDecode(response.body) : {},
          };
        },
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
        onRetry: (e) {
          print('Retrying review fetch for workerId $workerId due to error: $e');
        },
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
      );

      if (response['statusCode'] == 200) {
        final responseData = response['body'] as Map<String, dynamic>;
        if (responseData['status'] == 'success') {
          final reviewsData = responseData['data'] as List<dynamic>? ?? [];
          return reviewsData
              .map((json) => Review.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'API error: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch reviews: ${response['statusCode']} - ${response['body']['message'] ?? response['body']}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  /// Creates a new review with the specified parameters.
  Future<Review> createReview({
    required int serviceRequestId,
    required String workerId,
    required String clientId,
    required double rating,
    String? comment,
    required String reviewType,
  }) async {
    try {
      if (!['client_to_worker', 'worker_to_client'].contains(reviewType)) {
        throw Exception(
          'Invalid review_type: must be "client_to_worker" or "worker_to_client"',
        );
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final token = await user.getIdToken();
      final payload = {
        'service_request_id': serviceRequestId,
        'worker_id': workerId,
        'client_id': clientId,
        'rating': rating,
        'comment': comment ?? 'Sin comentario',
        'review_type': reviewType,
      };
      print('DEBUG: Sending review payload: ${jsonEncode(payload)}');
      final response = await retry(
        () async {
          final response = await http.post(
            Uri.parse('$baseUrl/reviews'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request to $baseUrl/reviews timed out');
            },
          );
          return {
            'statusCode': response.statusCode,
            'body': response.body.isNotEmpty ? jsonDecode(response.body) : {},
          };
        },
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
        onRetry: (e) {
          print('Retrying review creation for serviceRequestId $serviceRequestId due to error: $e');
        },
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
      );

      print('DEBUG: Create Review Response: ${response['body']}');
      if (response['statusCode'] == 201) {
        final responseData = response['body'] as Map<String, dynamic>;
        if (responseData['status'] == 'success') {
          return Review.fromJson(responseData['data'] as Map<String, dynamic>);
        } else {
          throw Exception(
            'API error: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to create review: ${response['statusCode']} - ${response['body']['message'] ?? response['body']}',
        );
      }
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }
}