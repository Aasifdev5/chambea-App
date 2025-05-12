import 'package:flutter/material.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/terminate_service_screen.dart';
import 'package:chambea/screens/chambeador/review_service_screen.dart';
import 'package:slide_to_act/slide_to_act.dart';

class StartServiceScreen extends StatelessWidget {
  final Job job;

  const StartServiceScreen({super.key, required this.job});

  // Method to get status color based on job status
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
    // Hardcode missing fields to match the image
    const String date = 'Hoy';
    const String time = '16:00';
    const String paymentType = 'Efectivo';
    const String budget = 'BOB: 180';
    const String estimatedTime = '1 día';
    const String availability = 'Inmediato';
    const String proposalSent = 'Hace 5 horas';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Propuesta',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status label aligned to the right
              Row(
                children: [
                  const Spacer(), // Pushes the status label to the right
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.status, // Dynamically display the job status
                      style: TextStyle(
                        color: getStatusColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Job Title & Tags
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          job.categories
                              .map(
                                (category) => Chip(
                                  label: Text(category),
                                  backgroundColor: Colors.grey.shade200,
                                  labelStyle: const TextStyle(fontSize: 12),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.location,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(date, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(time, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text('$budget / Hora'),
                        const Spacer(),
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(paymentType),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          job.clientName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          job.clientRating.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Proposal Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Propuesta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hola ${job.clientName}, soy ${job.workerName}, técnico eléctrico. '
                      'Puedo estar en ${job.location} hoy a las 18:00 como pediste.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Details table-style
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Disponibilidad', availability),
                    _buildDivider(),
                    _buildInfoRow('Presupuesto', budget),
                    _buildDivider(),
                    _buildInfoRow('Tiempo estimado', estimatedTime),
                    _buildDivider(),
                    _buildInfoRow('Propuesta enviada', proposalSent),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Conditional SlideAction Buttons
              if (job.status == 'Pendiente') ...[
                SlideAction(
                  borderRadius: 12,
                  elevation: 0,
                  innerColor: const Color(0xFF4CAF50),
                  outerColor: const Color(0xFF4CAF50).withOpacity(0.2),
                  sliderButtonIcon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  text: 'Deslizar para iniciar servicio',
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  onSubmit: () {
                    final updatedJob = job.copyWith(status: 'En curso');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TerminateServiceScreen(job: updatedJob),
                      ),
                    );
                  },
                ),
              ] else if (job.status == 'En curso') ...[
                SlideAction(
                  borderRadius: 12,
                  elevation: 0,
                  innerColor: Colors.red.shade600,
                  outerColor: Colors.red.shade100,
                  sliderButtonIcon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  text: 'Deslizar para Terminar servicio',
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  onSubmit: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewServiceScreen(job: job),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
  }
}
