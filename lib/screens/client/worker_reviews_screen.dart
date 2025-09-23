import 'package:flutter/material.dart';
import 'package:chambea/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkerReviewsScreen extends StatefulWidget {
  final String workerId; // String to match users.id
  final String workerName;

  const WorkerReviewsScreen({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  @override
  _WorkerReviewsScreenState createState() => _WorkerReviewsScreenState();
}

class _WorkerReviewsScreenState extends State<WorkerReviewsScreen> {
  String _normalizeImagePath(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      print('DEBUG: Image path is null or empty, using default avatar');
      return '';
    }
    String normalized = imagePath
        .replaceAll('https://chambea.lat/storage/', 'https://chambea.lat/')
        .replaceAll(
          'https://chambea.lat/Uploads/',
          'https://chambea.lat/uploads/',
        )
        .replaceAll(
          'https://chambea.lat/https://chambea.lat/',
          'https://chambea.lat/',
        );
    if (!normalized.startsWith('http')) {
      normalized = 'https://chambea.lat/$normalized';
    }
    print('DEBUG: Normalized image path: $normalized');
    return normalized;
  }

  Future<Map<String, dynamic>> _fetchWorkerReviews() async {
    try {
      final response = await ApiService.get(
        '/api/reviews/worker/${widget.workerId}',
      );
      print(
        'DEBUG: Reviews response for workerId ${widget.workerId}: $response',
      );
      if (response['status'] == 'success' && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception(
          'Failed to load reviews: ${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print(
        'ERROR: Failed to fetch reviews for workerId ${widget.workerId}: $e',
      );
      rethrow;
    }
  }

  double _calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(
      0.0,
      (sum, review) => sum + (review['rating']?.toDouble() ?? 0.0),
    );
    return total / reviews.length;
  }

  String _formatTimestamp(String? createdAt) {
    if (createdAt == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays < 1) {
        return 'Hace ${difference.inHours} horas';
      } else if (difference.inDays < 30) {
        return 'Hace ${difference.inDays} días';
      } else if (difference.inDays < 365) {
        return 'Hace ${(difference.inDays / 30).floor()} meses';
      } else {
        return DateFormat.yMMMd().format(date);
      }
    } catch (e) {
      print('DEBUG: Error formatting timestamp: $e');
      return 'Fecha desconocida';
    }
  }

  String _formatServiceDate(String? serviceDate) {
    if (serviceDate == null) return 'Fecha desconocida';
    try {
      final date = DateFormat('dd/MM/yyyy').parse(serviceDate);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      print('DEBUG: Error formatting service date: $e');
      return serviceDate ?? 'Fecha desconocida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (mounted) Navigator.pop(context);
          },
        ),
        title: Text(
          '${widget.workerName} - Historial',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchWorkerReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('DEBUG: Error in FutureBuilder: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error al cargar historial',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  Text(
                    'Detalles: ${snapshot.error}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) setState(() {});
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final reviews = List<Map<String, dynamic>>.from(
            data['reviews'] ?? [],
          );
          final profile = data['profile'] as Map<String, dynamic>?;

          // Log when profile is null
          if (profile == null) {
            print(
              'DEBUG: Profile data is null for workerId ${widget.workerId}',
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Detalles del perfil del trabajador no están disponibles',
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            });
          }

          final averageRating = _calculateAverageRating(reviews);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with worker profile and average rating
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  profile != null &&
                                      profile['profile_image'] != null
                                  ? CachedNetworkImageProvider(
                                      _normalizeImagePath(
                                        profile['profile_image'],
                                      ),
                                    )
                                  : null,
                              backgroundColor: Colors.grey.shade300,
                              child:
                                  profile == null ||
                                      profile['profile_image'] == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile != null && profile['name'] != null
                                        ? profile['name']
                                        : widget.workerName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        Icon(
                                          i < averageRating.floor()
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.yellow.shade700,
                                          size: 20,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        averageRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${reviews.length} reseñas)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sobre mí',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile != null && profile['about_me'] != null
                                  ? profile['about_me']
                                  : 'No hay biografía disponible',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Habilidades',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            profile != null &&
                                    profile['skills'] != null &&
                                    (profile['skills'] as List).isNotEmpty
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children:
                                        (profile['skills'] as List<dynamic>)
                                            .map(
                                              (skill) => Chip(
                                                label: Text(
                                                  skill.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.grey.shade100,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                  )
                                : const Text(
                                    'No hay habilidades listadas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Servicio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile != null && profile['category'] != null
                                  ? profile['category']
                                  : 'No hay categoría de servicio disponible',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subcategorías',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            profile != null &&
                                    profile['subcategories'] != null &&
                                    (profile['subcategories'] as List)
                                        .isNotEmpty
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children:
                                        (profile['subcategories']
                                                as List<dynamic>)
                                            .map(
                                              (subcategory) => Chip(
                                                label: Text(
                                                  subcategory.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.grey.shade100,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                  )
                                : const Text(
                                    'No hay subcategorías listadas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (reviews.isEmpty)
                  const Center(
                    child: Text(
                      'No hay reseñas disponibles para este trabajador',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reseñas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Review list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          review['client_name'] ??
                                              'Usuario Desconocido',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        _formatTimestamp(review['created_at']),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        Icon(
                                          i <
                                                  (review['rating']
                                                              ?.toDouble() ??
                                                          0.0)
                                                      .floor()
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.yellow.shade700,
                                          size: 20,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        (review['rating']?.toDouble() ?? 0.0)
                                            .toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${review['service_category'] ?? 'Desconocido'} - ${review['service_subcategory'] ?? 'Desconocido'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Fecha: ${_formatServiceDate(review['service_date'])}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review['comment'] ??
                                        'No hay comentario proporcionado',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
