import 'package:flutter/material.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/review_service_screen.dart';
import 'package:slide_to_act/slide_to_act.dart';

class TerminateServiceScreen extends StatelessWidget {
  final Job job;

  const TerminateServiceScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Terminar servicio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        // Added SingleChildScrollView to prevent overflow
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top image or banner
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 16),

              // Title & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    job.priceRange,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Client Info
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.clientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            job.clientRating.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Proposal Message
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detalles de la propuesta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hola ${job.clientName}, soy Andrés Villamontes, técnico eléctrico con 5 años de experiencia. '
                'Puedo estar en ${job.location} hoy a las 18:00 como pediste. '
                'El trabajo incluye materiales de primera calidad y garantía por 6 meses.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Detail Rows
              _buildDetailRow(
                Icons.calendar_today,
                'Disponibilidad',
                'Inmediato',
              ),
              const Divider(height: 24),
              _buildDetailRow(Icons.av_timer, 'Tiempo estimado', '1 día'),
              const Divider(height: 24),
              _buildDetailRow(
                Icons.attach_money,
                'Forma de pago',
                '50% adelanto, 50% al finalizar',
              ),
              const Divider(height: 24),
              _buildDetailRow(
                Icons.access_time,
                'Propuesta enviada',
                job.timeAgo,
              ),

              const SizedBox(
                height: 20,
              ), // Replaced Spacer with SizedBox to avoid overflow
              // Slide to Terminate Button
              SizedBox(
                width: double.infinity,
                child: SlideAction(
                  borderRadius: 12,
                  elevation: 0,
                  innerColor: Colors.red.shade600,
                  outerColor: Colors.red.shade100,
                  sliderButtonIcon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  text: 'Deslizar para terminar servicio',
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  onSubmit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewServiceScreen(job: job),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
