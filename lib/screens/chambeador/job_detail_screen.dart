import 'package:cached_network_image/cached_network_image.dart';
import 'package:chambea/blocs/chambeador/job_detail_bloc.dart';
import 'package:chambea/blocs/chambeador/job_detail_event.dart';
import 'package:chambea/blocs/chambeador/job_detail_state.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/propuesta_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JobDetailScreen extends StatelessWidget {
  final int requestId;

  const JobDetailScreen({required this.requestId, super.key});

  // Normalize image URL to remove /storage/ and handle case sensitivity
  String _normalizeImagePath(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
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
      return 'https://chambea.lat/$normalized';
    }
    return normalized;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          return false;
        }
      } else {
        final data = jsonDecode(response.body);
        print('DEBUG: Balance check error: ${data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        return false;
      }
    } catch (e, stackTrace) {
      print('ERROR: Failed to check balance: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar saldo: $e')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JobDetailBloc()..add(FetchJobDetail(requestId)),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image with Gradient Overlay
            BlocBuilder<JobDetailBloc, JobDetailState>(
              builder: (context, state) {
                ImageProvider image = const AssetImage(
                  'assets/images/led_installation.jpg',
                );
                if (state is JobDetailLoaded &&
                    state.job.image != null &&
                    state.job.image!.isNotEmpty) {
                  String imagePath = _normalizeImagePath(state.job.image);
                  print(
                    'DEBUG: Normalized job image for requestId: $requestId, URL: $imagePath',
                  );
                  try {
                    image = CachedNetworkImageProvider(imagePath);
                  } catch (e, stackTrace) {
                    print(
                      'ERROR: Failed to load job image for requestId: $requestId, URL: $imagePath, Error: $e',
                    );
                    print('Stack trace: $stackTrace');
                  }
                }
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: image, fit: BoxFit.cover),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Transparent AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    print('DEBUG: Navigating back from JobDetailScreen');
                    try {
                      Navigator.pop(context);
                    } catch (e, stackTrace) {
                      print('ERROR: Failed to navigate back: $e');
                      print('Stack trace: $stackTrace');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error de navegación: $e')),
                      );
                    }
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      print(
                        'DEBUG: Favorite button pressed in JobDetailScreen',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Añadido a favoritos')),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Main Content
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: BlocBuilder<JobDetailBloc, JobDetailState>(
                  builder: (context, state) {
                    if (state is JobDetailLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is JobDetailError) {
                      print(
                        'ERROR: Failed to load job details for requestId: $requestId, Error: ${state.message}',
                      );
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${state.message}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                print(
                                  'DEBUG: Retrying fetch job details for requestId: $requestId',
                                );
                                context.read<JobDetailBloc>().add(
                                  FetchJobDetail(requestId),
                                );
                              },
                              child: const Text(
                                'Reintentar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is JobDetailLoaded) {
                      final job = state.job;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              job.title ?? 'Sin título',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Description
                            Text(
                              job.description ?? 'Sin descripción disponible',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Tags
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  (job.categories.isNotEmpty
                                          ? job.categories
                                          : ['SERVICIO', 'GENERAL'])
                                      .map(
                                        (category) => Chip(
                                          label: Text(
                                            category.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          backgroundColor: Colors.grey.shade200,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                            const SizedBox(height: 20),
                            // Client Info
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${job.location ?? 'Sin ubicación'}${job.locationDetails != null ? ', ${job.locationDetails}' : ''}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        job.clientName ?? 'Usuario Desconocido',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating:
                                              job.clientRating?.toDouble() ??
                                              0.0,
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                                Icons.star,
                                                color: Colors.yellowAccent,
                                              ),
                                          itemCount: 5,
                                          itemSize: 18.0,
                                          direction: Axis.horizontal,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          (job.clientRating ?? 0.0)
                                              .toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      job.budget != null
                                          ? 'BOB ${job.budget!.toStringAsFixed(2)}'
                                          : 'BOB No especificado',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Payment Method Note
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Forma de pago: ${job.paymentMethod ?? 'No especificado'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Application Status
                            if (job.status == 'Pendiente')
                              job.hasApplied
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.blue.shade600,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Aplicado',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 3,
                                        shadowColor: Colors.green.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      onPressed: () async {
                                        print(
                                          'DEBUG: Enviar propuesta button pressed for requestId: $requestId',
                                        );
                                        bool canApply = await _checkBalance(context);
                                        if (canApply) {
                                          print(
                                            'DEBUG: Navigating to PropuestaScreen for requestId: $requestId',
                                          );
                                          try {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PropuestaScreen(
                                                      requestId: requestId,
                                                    ),
                                              ),
                                            );
                                          } catch (e, stackTrace) {
                                            print(
                                              'ERROR: Failed to navigate to PropuestaScreen for requestId: $requestId, Error: $e',
                                            );
                                            print('Stack trace: $stackTrace');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error de navegación: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Enviar propuesta',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                          ],
                        ),
                      );
                    }
                    return const Center(child: Text('Estado desconocido'));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}