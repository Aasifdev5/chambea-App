import 'package:flutter/material.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/review_service_screen.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TerminateServiceScreen extends StatefulWidget {
  final Job job;

  const TerminateServiceScreen({super.key, required this.job});

  @override
  State<TerminateServiceScreen> createState() => _TerminateServiceScreenState();
}

class _TerminateServiceScreenState extends State<TerminateServiceScreen> {
  final GlobalKey<SlideActionState> _sliderKey = GlobalKey();
  bool _isLoading = false;
  bool _hasSubmitted = false; // New flag to prevent multiple submissions

  Future<void> _completeService(BuildContext context) async {
    if (_isLoading || _hasSubmitted) return; // Prevent multiple submissions
    setState(() {
      _isLoading = true;
      _hasSubmitted = true; // Mark as submitted
    });

    if (widget.job.id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID del servicio inválido')),
      );
      _sliderKey.currentState?.reset();
      setState(() {
        _isLoading = false;
        _hasSubmitted = false; // Allow retry on failure
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debe iniciar sesión')));
      _sliderKey.currentState?.reset();
      setState(() {
        _isLoading = false;
        _hasSubmitted = false; // Allow retry on failure
      });
      return;
    }

    try {
      final token = await user.getIdToken();
      print('Sending complete service request for Job ID: ${widget.job.id}');
      final response = await http.post(
        Uri.parse(
          'https://chambea.lat/api/service-requests/${widget.job.id}/complete',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print(
        'Complete Service Response: ${response.statusCode} - ${response.body}',
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['data'] == null) {
          throw Exception('API response does not contain "data" field');
        }

        final updatedJob = Job.fromJson(responseData['data']);
        print(
          'Updated Job: ID=${updatedJob.id}, WorkerID=${updatedJob.workerId}, ClientID=${updatedJob.clientId}',
        );

        if (updatedJob.id == 0 ||
            updatedJob.workerId == null ||
            updatedJob.clientId == null) {
          throw Exception(
            'Invalid job data: Missing ID, workerId, or clientId',
          );
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio completado exitosamente')),
        );

        // Navigate to ReviewServiceScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewServiceScreen(job: updatedJob),
          ),
        );
      } else {
        final error = responseData['message'] ?? 'Error desconocido';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al completar servicio: $error')),
        );
        _sliderKey.currentState?.reset();
        setState(() {
          _isLoading = false;
          _hasSubmitted = false; // Allow retry on failure
        });
      }
    } catch (e) {
      print('Error completing service: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      _sliderKey.currentState?.reset();
      setState(() {
        _isLoading = false;
        _hasSubmitted = false; // Allow retry on failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                  image: job.image != null
                      ? DecorationImage(
                          image: NetworkImage(job.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
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
                        job.clientName ?? 'Usuario Desconocido',
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
                            (job.clientRating ?? 0.0).toStringAsFixed(1),
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detalles de la propuesta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hola ${job.clientName ?? 'Usuario Desconocido'}, soy ${job.workerName ?? 'Andrés Villamontes'}, técnico eléctrico con 5 años de experiencia. '
                'Puedo estar en ${job.location} hoy a las 18:00 como pediste. '
                'El trabajo incluye materiales de primera calidad y garantía por 6 meses.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
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
                job.paymentMethod ?? '50% adelanto, 50% al finalizar',
              ),
              const Divider(height: 24),
              _buildDetailRow(
                Icons.access_time,
                'Propuesta enviada',
                job.timeAgo,
              ),
              const SizedBox(height: 20),
              IgnorePointer(
                ignoring: _isLoading || _hasSubmitted, // Disable if submitted
                child: SizedBox(
                  width: double.infinity,
                  child: SlideAction(
                    key: _sliderKey,
                    borderRadius: 12,
                    elevation: 0,
                    innerColor: Colors.red.shade600,
                    outerColor: Colors.red.shade100,
                    sliderButtonIcon: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.arrow_forward, color: Colors.white),
                    text: 'Deslizar para terminar servicio',
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    onSubmit: () => _completeService(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
