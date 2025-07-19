import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:chambea/screens/chambeador/propuesta_screen.dart';
import 'package:chambea/screens/chambeador/chat_detail_screen.dart';
import 'package:chambea/blocs/chambeador/job_detail_bloc.dart';
import 'package:chambea/blocs/chambeador/job_detail_event.dart';
import 'package:chambea/blocs/chambeador/job_detail_state.dart';
import 'package:chambea/models/job.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobDetailScreen extends StatelessWidget {
  final int requestId;

  const JobDetailScreen({required this.requestId, Key? key}) : super(key: key);

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
                if (state is JobDetailLoaded && state.job.image != null) {
                  try {
                    image = NetworkImage(state.job.image!);
                  } catch (e, stackTrace) {
                    print(
                      'ERROR: Failed to load job image for requestId: $requestId, Error: $e',
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
                        SnackBar(content: Text('Navigation error: $e')),
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
                      return Center(child: Text('Error: ${state.message}'));
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
                                          ? 'BOB ${job.budget!.toStringAsFixed(2)}/Hora'
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
                            // Buttons (Show only for Pendiente status)
                            if (job.status == 'Pendiente')
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
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
                                      onPressed: () {
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
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Navigation error: $e',
                                              ),
                                            ),
                                          );
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
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.green,
                                          width: 1.5,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        final user =
                                            FirebaseAuth.instance.currentUser;
                                        if (user != null &&
                                            job.clientId != null) {
                                          print(
                                            'DEBUG: Navigating to ChatDetailScreen for clientId: ${job.clientId}, requestId: $requestId',
                                          );
                                          try {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatDetailScreen(
                                                      clientId: job.clientId!
                                                          .toString(),
                                                      requestId: job.id,
                                                    ),
                                              ),
                                            );
                                          } catch (e, stackTrace) {
                                            print(
                                              'ERROR: Failed to navigate to ChatDetailScreen: $e',
                                            );
                                            print('Stack trace: $stackTrace');
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Navigation error: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          print(
                                            'ERROR: Missing clientId or user not authenticated for requestId: $requestId',
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Error: No se encontró el ID del cliente o usuario no autenticado',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Consultar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }
                    return const Center(child: Text('Unknown state'));
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
