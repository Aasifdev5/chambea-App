import 'package:flutter/material.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/start_service_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrabajosContent extends StatefulWidget {
  const TrabajosContent({super.key});

  @override
  _TrabajosContentState createState() => _TrabajosContentState();
}

class _TrabajosContentState extends State<TrabajosContent> {
  Future<List<Job>> fetchJobs() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse(
          'https://chambea.lat/api/service-requests?worker_id=${user.uid}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((json) => Job.fromJson(json)).toList();
      } else {
        String errorMessage;
        switch (response.statusCode) {
          case 401:
            errorMessage =
                'Sesión expirada. Por favor, inicia sesión nuevamente.';
            break;
          case 403:
            errorMessage = 'No tienes permiso para ver estos trabajos.';
            break;
          case 404:
            errorMessage = 'No se encontraron trabajos.';
            break;
          default:
            errorMessage = 'Error al cargar trabajos: ${response.body}';
        }
        print('Error fetching jobs: ${response.statusCode} - ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Exception in fetchJobs: $e');
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  void refreshJobs() {
    setState(() {}); // Trigger rebuild to refresh job list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mis trabajos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Job>>(
        future: fetchJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => refreshJobs(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final jobs = snapshot.data ?? [];
          return DefaultTabController(
            length: 3,
            child: SafeArea(
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(text: 'Pendiente'),
                      Tab(text: 'En curso'),
                      Tab(text: 'Completado'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        JobList(
                          jobs: jobs
                              .where((job) => job.status == 'Pendiente')
                              .toList(),
                          onRefresh: refreshJobs,
                          emptyMessage: 'No hay trabajos pendientes',
                        ),
                        JobList(
                          jobs: jobs
                              .where((job) => job.status == 'En curso')
                              .toList(),
                          onRefresh: refreshJobs,
                          emptyMessage: 'No hay trabajos en curso',
                        ),
                        JobList(
                          jobs: jobs
                              .where((job) => job.status == 'Completado')
                              .toList(),
                          onRefresh: refreshJobs,
                          emptyMessage: 'No hay trabajos completados',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class JobList extends StatelessWidget {
  final List<Job> jobs;
  final VoidCallback onRefresh;
  final String emptyMessage;

  const JobList({
    super.key,
    required this.jobs,
    required this.onRefresh,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    print('JobList jobs: ${jobs.map((job) => job.title).toList()}');
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return TrabajoCard(
          job: job,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StartServiceScreen(job: job)),
            ).then((_) => onRefresh());
          },
        );
      },
    );
  }
}

class TrabajoCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const TrabajoCard({super.key, required this.job, required this.onTap});

  Color getStatusColor() {
    switch (job.status) {
      case 'Pendiente':
        return Colors.orange;
      case 'En curso':
        return Colors.blue;
      case 'Completado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                job.status,
                style: TextStyle(
                  color: getStatusColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              job.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: job.categories
                  .map((category) => _TagChip(label: category))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.today_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job.timeAgo, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  job.startTime ?? 'No especificado',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.attach_money_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(job.priceRange, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  job.paymentMethod ?? 'No especificado',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.clientName ?? 'Usuario Desconocido',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(
                  (job.clientRating ?? 0.0).toStringAsFixed(1),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: const Color(0xFFF3F3F3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
