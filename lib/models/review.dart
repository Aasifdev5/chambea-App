class Review {
  final String id;
  final String clientName;
  final double rating;
  final String timeAgo;
  final String comment;

  const Review({
    required this.id,
    required this.clientName,
    required this.rating,
    required this.timeAgo,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      clientName: json['client_name'] ?? 'Usuario Desconocido',
      rating: json['rating']?.toDouble() ?? 0.0,
      timeAgo: json['time_ago'] ?? 'Desconocido',
      comment: json['comment'] ?? 'Sin comentario',
    );
  }
}
