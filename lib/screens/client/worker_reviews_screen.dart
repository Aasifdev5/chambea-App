import 'package:flutter/material.dart';
import 'package:chambea/services/api_service.dart';
import 'package:intl/intl.dart';

class WorkerReviewsScreen extends StatefulWidget {
  final int workerId;
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
  Future<List<Map<String, dynamic>>> _fetchWorkerReviews() async {
    try {
      final response = await ApiService.get('/api/reviews/worker/${widget.workerId}');
      print('DEBUG: Reviews response for workerId ${widget.workerId}: $response');
      if (response['status'] == 'success' && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Failed to load reviews: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('ERROR: Failed to fetch reviews for workerId ${widget.workerId}: $e');
      rethrow;
    }
  }

  double _calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0.0, (sum, review) => sum + (review['rating']?.toDouble() ?? 0.0));
    return total / reviews.length;
  }

  String _formatTimestamp(String? createdAt) {
    if (createdAt == null) return 'Unknown date';
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays < 1) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else {
        return DateFormat.yMMMd().format(date);
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _formatServiceDate(String? serviceDate) {
    if (serviceDate == null) return 'Unknown date';
    try {
      // Assuming service_date is in DD/MM/YYYY format based on service_requests table
      final date = DateFormat('dd/MM/yyyy').parse(serviceDate);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return serviceDate;
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.workerName} - Reviews',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchWorkerReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No reviews available for this worker',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final reviews = snapshot.data!;
          final averageRating = _calculateAverageRating(reviews);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with worker name and average rating
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
                        Text(
                          widget.workerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (int i = 0; i < 5; i++)
                              Icon(
                                i < averageRating.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.yellow.shade700,
                                size: 24,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${reviews.length} reviews)',
                              style: const TextStyle(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review['client_name'] ?? 'Usuario Desconocido',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
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
                                    i < (review['rating']?.toDouble() ?? 0.0).floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.yellow.shade700,
                                    size: 20,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  (review['rating']?.toDouble() ?? 0.0).toStringAsFixed(1),
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
                              '${review['service_category'] ?? 'Unknown'} - ${review['service_subcategory'] ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Date: ${_formatServiceDate(review['service_date'])}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['comment'] ?? 'No comment provided',
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
          );
        },
      ),
    );
  }
}