import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:chambea/screens/chambeador/propuesta_screen.dart';
import 'package:chambea/screens/chambeador/chat_detail_screen.dart';
import 'package:chambea/blocs/chambeador/job_detail_bloc.dart';
import 'package:chambea/blocs/chambeador/job_detail_event.dart';
import 'package:chambea/blocs/chambeador/job_detail_state.dart';

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
                if (state is JobDetailLoaded && state.job['image'] != null) {
                  image = NetworkImage(state.job['image']);
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
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
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
                              '${job['category'] ?? 'Servicio'} - ${job['subcategory'] ?? 'General'}',
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
                              job['description'] ??
                                  'Sin descripción disponible',
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
                              children: [
                                Chip(
                                  label: Text(
                                    job['category']?.toUpperCase() ??
                                        'SERVICIO',
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
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    job['subcategory']?.toUpperCase() ??
                                        'GENERAL',
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
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Worker Info
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
                                        '${job['location'] ?? 'Sin ubicación'}, ${job['location_details'] ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        job['worker_name'] ??
                                            'Usuario ${job['created_by'] ?? 'Desconocido'}',
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
                                              job['worker_rating']
                                                  ?.toDouble() ??
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
                                          job['worker_rating']?.toString() ??
                                              '0.0',
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
                                      job['budget'] != null &&
                                              double.tryParse(
                                                    job['budget'].toString(),
                                                  ) !=
                                                  null
                                          ? 'BOB ${job['budget']}/Hora'
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
                                'Forma de pago: ${job['payment_method'] ?? 'No especificado'}',
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
                            // Buttons
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 3,
                                      shadowColor: Colors.green.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PropuestaScreen(
                                            requestId: requestId,
                                          ),
                                        ),
                                      );
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatDetailScreen(),
                                        ),
                                      );
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
                    return const SizedBox.shrink();
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
