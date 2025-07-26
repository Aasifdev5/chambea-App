class Review {
  final String id;
  final String clientName;
  final double rating;
  final String timeAgo;
  final String comment;
  final String reviewType; // Added to support bidirectional reviews

  const Review({
    required this.id,
    required this.clientName,
    required this.rating,
    required this.timeAgo,
    required this.comment,
    required this.reviewType,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Calculate time_ago from created_at
    String timeAgo;
    try {
      final createdAt = DateTime.tryParse(json['created_at'] ?? '');
      if (createdAt != null) {
        final now = DateTime.now();
        final difference = now.difference(createdAt);
        if (difference.inDays > 0) {
          timeAgo =
              'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
        } else if (difference.inHours > 0) {
          timeAgo =
              'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
        } else {
          timeAgo =
              'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
        }
      } else {
        timeAgo = 'Desconocido';
      }
    } catch (e) {
      print(
        'ERROR: Failed to parse created_at: ${json['created_at']}, Error: $e',
      );
      timeAgo = 'Desconocido';
    }

    return Review(
      id: json['id']?.toString() ?? '0',
      clientName:
          json['client_name'] ??
          json['client']?['name'] ??
          'Usuario Desconocido',
      rating:
          (json['rating'] is String
              ? double.tryParse(json['rating']) ?? 0.0
              : json['rating']?.toDouble()) ??
          0.0,
      timeAgo: timeAgo,
      comment: json['comment'] ?? 'Sin comentario',
      reviewType:
          json['review_type'] ??
          'worker_to_client', // Default to worker_to_client for backward compatibility
    );
  }
}
