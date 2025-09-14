import 'package:timeago/timeago.dart' as timeago;

class Review {
  final String id;
  final int serviceRequestId;
  final String workerId;
  final String clientId;
  final String clientName;
  final double rating;
  final String comment;
  final String reviewType;
  final DateTime? createdAt;
  final String timeAgo;

  const Review({
    required this.id,
    required this.serviceRequestId,
    required this.workerId,
    required this.clientId,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.reviewType,
    this.createdAt,
    required this.timeAgo,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Parse created_at and calculate time_ago
    DateTime? createdAt;
    String timeAgo;
    try {
      createdAt = json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null;
      if (createdAt != null) {
        timeago.setLocaleMessages('es', timeago.EsMessages());
        timeAgo = timeago.format(createdAt, locale: 'es');
      } else {
        timeAgo = 'Desconocido';
      }
    } catch (e) {
      print('ERROR: Failed to parse created_at: ${json['created_at']}, Error: $e');
      timeAgo = 'Desconocido';
    }

    return Review(
      id: json['id']?.toString() ?? '0',
      serviceRequestId: json['service_request_id'] is int
          ? json['service_request_id']
          : int.tryParse(json['service_request_id']?.toString() ?? '0') ?? 0,
      workerId: json['worker_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      clientName: json['client_name'] ??
          json['client']?['name'] ??
          'Usuario Desconocido',
      rating: (json['rating'] is num
              ? json['rating'].toDouble()
              : double.tryParse(json['rating']?.toString() ?? '0.0')) ??
          0.0,
      comment: json['comment']?.toString() ?? 'Sin comentario',
      reviewType: json['review_type']?.toString() ?? 'client_to_worker',
      createdAt: createdAt,
      timeAgo: timeAgo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_request_id': serviceRequestId,
      'worker_id': workerId,
      'client_id': clientId,
      'client_name': clientName,
      'rating': rating,
      'comment': comment,
      'review_type': reviewType,
      'created_at': createdAt?.toIso8601String(),
      'time_ago': timeAgo,
    };
  }
}