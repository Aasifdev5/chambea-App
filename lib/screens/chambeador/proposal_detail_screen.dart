import 'package:flutter/material.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/start_service_screen.dart';
import 'package:chambea/screens/chambeador/terminate_service_screen.dart';
import 'package:chambea/screens/chambeador/chat_detail_screen.dart';

class ProposalDetailScreen extends StatelessWidget {
  final Job job;

  const ProposalDetailScreen({super.key, required this.job});

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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detalles de la Propuesta',
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 16),
            // Status + Price
            Row(
              children: [
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
                    job.status,
                    style: TextStyle(
                      color: getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'BOB ${job.priceRange.split('-')[0].trim()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Worker Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/1.jpg',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.workerName ?? 'Andrés Villamontes',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          (job.workerRating ?? 4.5).toStringAsFixed(1),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '12 trabajos',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Proposal Details
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Detalles de la propuesta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hola ${job.clientName}, soy ${job.workerName ?? 'Andrés Villamontes'}, técnico eléctrico con 5 años de experiencia. '
              'Puedo estar en ${job.location} hoy a las 18:00 como pediste. El trabajo incluye materiales de primera calidad y garantía por 6 meses.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Detail Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            if (job.status == 'Pendiente') ...[
              _primaryButton(
                label: 'Aceptar Propuesta',
                color: Colors.green.shade700,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StartServiceScreen(job: job),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _outlinedButton(
                label: 'Enviar Mensaje',
                color: Colors.green.shade700,
                onTap: () {
                  if (job.workerId != null && job.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          clientId: job.workerId!
                              .toString(), // Fixed: Use workerId as clientId
                          requestId: job.id,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error: No se encontró el ID del trabajador o solicitud',
                        ),
                      ),
                    );
                  }
                },
              ),
            ] else if (job.status == 'En curso') ...[
              _primaryButton(
                label: 'Terminar Servicio',
                color: Colors.red.shade600,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TerminateServiceScreen(job: job),
                  ),
                ),
              ),
            ],
          ],
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

  Widget _primaryButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _outlinedButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
