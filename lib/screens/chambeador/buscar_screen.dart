import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/chambeador/propuesta_screen.dart';
import 'package:chambea/screens/chambeador/home_screen.dart';
import 'package:chambea/blocs/chambeador/jobs_bloc.dart';
import 'package:chambea/blocs/chambeador/jobs_event.dart';
import 'package:chambea/blocs/chambeador/jobs_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class BuscarScreen extends StatelessWidget {
  // Normalize image path to ensure correct URL formatting
  String _normalizeImagePath(String? imagePath, {bool isProfilePhoto = false}) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      print('DEBUG: Image path is null or empty');
      return '';
    }

    String normalized = imagePath.trim();

    // Remove duplicate or incorrect prefixes
    normalized = normalized.replaceAll(
      RegExp(r'^https://chambea\.lat/https://chambea\.lat/'),
      'https://chambea.lat/',
    );

    // Remove 'storage/' prefix
    normalized = normalized.replaceFirst(RegExp(r'^storage/'), '');

    // Normalize case for prefix checks
    String lowerCasePath = normalized.toLowerCase();

    // Define expected prefixes
    const profilePrefix = 'uploads/profile_photos/';
    const jobPrefix = 'uploads/service_requests/';

    // Remove existing prefix if present to avoid duplication
    if (isProfilePhoto && lowerCasePath.contains(profilePrefix.toLowerCase())) {
      normalized = normalized.substring(
        normalized.toLowerCase().indexOf(profilePrefix.toLowerCase()) +
            profilePrefix.length,
      );
    } else if (!isProfilePhoto &&
        lowerCasePath.contains(jobPrefix.toLowerCase())) {
      normalized = normalized.substring(
        normalized.toLowerCase().indexOf(jobPrefix.toLowerCase()) +
            jobPrefix.length,
      );
    } else if (isProfilePhoto &&
        (lowerCasePath.contains('uploads/user_profiles/') ||
            lowerCasePath.contains('uploads/chambeador_profiles/'))) {
      print('WARNING: Unexpected profile photo path: $normalized');
      normalized = normalized.substring(normalized.lastIndexOf('/') + 1);
    } else if (!isProfilePhoto && lowerCasePath.contains('service_requests/')) {
      print('WARNING: Unexpected job image path: $normalized');
      normalized = normalized.substring(normalized.lastIndexOf('/') + 1);
    }

    // Add correct prefix
    normalized = isProfilePhoto
        ? 'uploads/profile_photos/$normalized'
        : 'uploads/service_requests/$normalized';

    // Prepend base URL for relative paths
    if (!normalized.startsWith('http')) {
      normalized = 'https://chambea.lat/$normalized';
    }

    // Convert 'Uploads/' to 'uploads/' for consistency
    normalized = normalized.replaceAll('Uploads/', 'uploads/');

    // Validate URL
    try {
      final uri = Uri.parse(normalized);
      if (!uri.isAbsolute || uri.host.isEmpty) {
        print('ERROR: Invalid URL format: $normalized');
        return '';
      }
      print('DEBUG: Normalized image path: $normalized');
      return normalized;
    } catch (e, stackTrace) {
      print(
        'ERROR: Failed to parse URL $normalized: $e\nStack Trace: $stackTrace',
      );
      return '';
    }
  }

  // Check balance before submitting proposal
  Future<bool> _checkBalance(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: No authenticated user found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, inicia sesión.')),
        );
        return false;
      }

      final token = await user.getIdToken();
      final uid = user.uid;
      final response = await http.post(
        Uri.parse('https://chambea.lat/api/chambeador/check-balance'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'uid': uid}),
      );

      print('DEBUG: Balance check response status: ${response.statusCode}');
      print('DEBUG: Balance check response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print('DEBUG: Balance sufficient: ${data['data']['balance']}');
          return true;
        } else {
          print('DEBUG: Balance check failed: ${data['message']}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));
          return false;
        }
      } else {
        final data = jsonDecode(response.body);
        print('DEBUG: Balance check error: ${data['message']}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
        return false;
      }
    } catch (e, stackTrace) {
      print('ERROR: Failed to check balance: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al verificar saldo: $e')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JobsBloc()..add(FetchJobs()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () {
              // Navigate to HomeScreen and replace the current screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          title: const Text(
            'Buscar trabajo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<JobsBloc, JobsState>(
          builder: (context, state) {
            if (state is JobsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is JobsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is JobsLoaded) {
              if (state.jobs.isEmpty) {
                return Center(
                  child: Image.asset(
                    'assets/images/empty.jpg',
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('ERROR: Failed to load empty.jpg: $error');
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.black54,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: state.jobs.length,
                itemBuilder: (context, index) {
                  final job = state.jobs[index];
                  return _buildTrabajoCard(context, job);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTrabajoCard(BuildContext context, Map<String, dynamic> job) {
    final normalizedImagePath = _normalizeImagePath(job['image']);
    final hasImage = normalizedImagePath.isNotEmpty;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay label
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey.shade300,
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: normalizedImagePath,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 150,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print(
                              'ERROR: Image load failed for URL $normalizedImagePath: $error',
                            );
                            return ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/empty.jpg',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                    'ERROR: Failed to load empty.jpg: $error',
                                  );
                                  return Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/empty.jpg',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('ERROR: Failed to load empty.jpg: $error');
                            return Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Consultar',
                    style: TextStyle(color: Colors.green[800], fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTimeAgo(job['created_at']),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job['category'] ?? 'Servicio'} - ${job['subcategory'] ?? 'General'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  job['description'] ?? 'Sin descripción disponible',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Tags
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTagChip(job['category']?.toUpperCase() ?? 'SERVICIO'),
                    _buildTagChip(
                      job['subcategory']?.toUpperCase() ?? 'GENERAL',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Time and Budget Row
                Row(
                  children: [
                    const Icon(Icons.today, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['is_time_undefined'] == 1
                            ? '${job['date'] ?? 'Hoy'} · Flexible'
                            : '${job['date'] ?? 'Hoy'} · ${job['start_time'] ?? 'Sin horario'}',
                        style: const TextStyle(color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['budget'] != null &&
                                double.tryParse(job['budget'].toString()) !=
                                    null
                            ? 'BOB: ${job['budget']}'
                            : 'BOB: No especificado',
                        style: const TextStyle(color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Location and Payment Method Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${job['location'] ?? 'Sin ubicación'}${job['location_details'] != null ? ', ${job['location_details']}' : ''}',
                        style: const TextStyle(color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.qr_code, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['payment_method'] ?? 'No especificado',
                        style: const TextStyle(color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // User info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: job['worker_image'] != null
                          ? NetworkImage(job['worker_image'])
                          : const NetworkImage(
                              'https://i.pravatar.cc/150?img=12',
                            ),
                      onBackgroundImageError: (error, stackTrace) => const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['worker_name'] ??
                                'Usuario ${job['created_by'] ?? 'Desconocido'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                job['worker_rating']?.toString() ?? '0.0',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    print(
                      'DEBUG: Enviar propuesta button pressed for jobId: ${job['id']}',
                    );
                    bool canApply = await _checkBalance(context);
                    if (canApply) {
                      print(
                        'DEBUG: Navigating to PropuestaScreen for jobId: ${job['id']}',
                      );
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropuestaScreen(requestId: job['id']),
                          ),
                        );
                      } catch (e, stackTrace) {
                        print(
                          'ERROR: Failed to navigate to PropuestaScreen for jobId: ${job['id']}, Error: $e',
                        );
                        print('Stack trace: $stackTrace');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error de navegación: $e')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Enviar propuesta',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey.shade200,
      shape: const StadiumBorder(),
    );
  }

  String _formatTimeAgo(String? createdAt) {
    if (createdAt == null) return 'Hace un momento';
    final now = DateTime.now();
    final created = DateTime.parse(createdAt);
    final difference = now.difference(created);
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    }
  }
}
