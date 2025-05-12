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
}

// Mock data for reviews
final List<Review> mockReviews = [
  const Review(
    id: '1',
    clientName: 'Julio Sequeira',
    rating: 4,
    timeAgo: 'Hace 2 horas',
    comment:
        'Andrés realizó un excelente trabajo instalando el sistema de iluminación de mi casa. Fue puntual, muy profesional y todo funcionó perfectamente. ¡Muy recomendable!',
  ),
  const Review(
    id: '2',
    clientName: 'Julio Sequeira',
    rating: 4,
    timeAgo: 'Hace 2 horas',
    comment:
        'Andrés realizó un excelente trabajo instalando el sistema de iluminación de mi casa. Fue puntual, muy profesional y todo funcionó perfectamente. ¡Muy recomendable!',
  ),
  const Review(
    id: '3',
    clientName: 'Julio Sequeira',
    rating: 4,
    timeAgo: 'Hace 2 horas',
    comment:
        'Andrés realizó un excelente trabajo instalando el sistema de iluminación de mi casa. Fue puntual, muy profesional y todo funcionó perfectamente. ¡Muy recomendable!',
  ),
];