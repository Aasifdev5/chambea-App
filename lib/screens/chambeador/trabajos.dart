import 'package:flutter/material.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/start_service_screen.dart';

class TrabajosContent extends StatelessWidget {
  const TrabajosContent({super.key});

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
      body: DefaultTabController(
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
                    TrabajosPendientes(
                      jobs:
                          mockJobs
                              .where((job) => job.status == 'Pendiente')
                              .toList(),
                    ),
                    TrabajosEnCurso(
                      jobs:
                          mockJobs
                              .where((job) => job.status == 'En curso')
                              .toList(),
                    ),
                    TrabajosCompletados(
                      jobs:
                          mockJobs
                              .where((job) => job.status == 'Completado')
                              .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrabajosPendientes extends StatelessWidget {
  final List<Job> jobs;

  const TrabajosPendientes({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    print('TrabajosPendientes jobs: ${jobs.map((job) => job.title).toList()}');
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'No hay trabajos pendientes',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
            );
          },
        );
      },
    );
  }
}

class TrabajosEnCurso extends StatelessWidget {
  final List<Job> jobs;

  const TrabajosEnCurso({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    print('TrabajosEnCurso jobs: ${jobs.map((job) => job.title).toList()}');
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'No hay trabajos en curso',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
            );
          },
        );
      },
    );
  }
}

class TrabajosCompletados extends StatelessWidget {
  final List<Job> jobs;

  const TrabajosCompletados({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    print('TrabajosCompletados jobs: ${jobs.map((job) => job.title).toList()}');
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'No hay trabajos completados',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
            );
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
            // Status pill
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

            // Job title
            Text(
              job.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Tags
            Wrap(
              spacing: 8,
              children:
                  job.categories
                      .map((category) => _TagChip(label: category))
                      .toList(),
            ),
            const SizedBox(height: 12),

            // Metadata rows
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(job.location, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 10),
                const Icon(Icons.today_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job.timeAgo, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 10),
                const Icon(
                  Icons.access_time_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                const Text('16:00', style: TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.attach_money_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(job.priceRange, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 10),
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                const Text('Efectivo', style: TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 14),

            // Worker info
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  job.clientName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(
                  job.clientRating.toString(),
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
