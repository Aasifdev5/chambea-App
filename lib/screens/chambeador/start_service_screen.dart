import 'package:flutter/material.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/review_service_screen.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StartServiceScreen extends StatefulWidget {
  final Job job;

  const StartServiceScreen({super.key, required this.job});

  @override
  _StartServiceScreenState createState() => _StartServiceScreenState();
}

class _StartServiceScreenState extends State<StartServiceScreen> {
  final GlobalKey<SlideActionState> _sliderKey = GlobalKey();
  bool _hasContractOffer = false;
  bool _hasContractInProgress = false;
  bool _isLoading = true;
  bool _hasSubmitted = false; // New flag to prevent multiple submissions
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkContractStatus();
  }

  Color getStatusColor() {
    switch (widget.job.status) {
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

  Future<void> _checkContractStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Debe iniciar sesión';
        _isLoading = false;
      });
      return;
    }

    try {
      final token = await user.getIdToken();

      final offerResponse = await http
          .get(
            Uri.parse(
              'https://chambea.lat/api/contracts/offer/${widget.job.id}',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      final statusResponse = await http
          .get(
            Uri.parse(
              'https://chambea.lat/api/contracts/status/${widget.job.id}',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (offerResponse.statusCode == 200 && statusResponse.statusCode == 200) {
        final offerData = json.decode(offerResponse.body);
        final statusData = json.decode(statusResponse.body);
        final contracts = offerData['data'] as List<dynamic>;
        final hasContractInProgress =
            statusData['data']['has_contract_in_progress'] as bool;

        setState(() {
          _hasContractOffer = contracts.isNotEmpty;
          _hasContractInProgress = hasContractInProgress;
          _isLoading = false;
        });
      } else {
        final error =
            json.decode(offerResponse.body)['message'] ??
            json.decode(statusResponse.body)['message'] ??
            'Error desconocido';
        setState(() {
          _errorMessage = 'Error al verificar contrato: $error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptAndStartService(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debe iniciar sesión')));
      return;
    }

    try {
      final token = await user.getIdToken();

      // Aceptar contrato
      final acceptResponse = await http
          .post(
            Uri.parse(
              'https://chambea.lat/api/service-requests/${widget.job.id}/accept',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (acceptResponse.statusCode != 200) {
        final error =
            json.decode(acceptResponse.body)['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al aceptar contrato: $error')),
        );
        return;
      }

      // Iniciar servicio
      final startResponse = await http
          .post(
            Uri.parse(
              'https://chambea.lat/api/service-requests/${widget.job.id}/start',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (startResponse.statusCode == 200) {
        final updatedJob = Job.fromJson(
          json.decode(startResponse.body)['data'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio iniciado exitosamente')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StartServiceScreen(job: updatedJob),
          ),
        );
      } else {
        final error =
            json.decode(startResponse.body)['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar servicio: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _completeService(BuildContext context) async {
    if (_isLoading || _hasSubmitted) return; // Prevent multiple submissions
    setState(() {
      _isLoading = true;
      _hasSubmitted = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debe iniciar sesión')));
      _sliderKey.currentState?.reset();
      setState(() {
        _isLoading = false;
        _hasSubmitted = false;
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
          _hasSubmitted = false;
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
        _hasSubmitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String date = widget.job.date ?? 'Hoy';
    final String time = widget.job.startTime ?? '16:00';
    final String paymentType = widget.job.paymentMethod ?? 'Efectivo';
    final String budget = widget.job.priceRange;
    const String estimatedTime = '1 día';
    final String proposalSent = widget.job.timeAgo;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkContractStatus,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  Row(
                    children: [
                      const Spacer(),
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
                          widget.job.status,
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

                  // Job details card
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
                          widget.job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: widget.job.categories
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
                              widget.job.location,
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
                            Text(budget),
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
                              widget.job.clientName ?? 'Usuario Desconocido',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (widget.job.clientRating ?? 0.0).toStringAsFixed(
                                1,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Proposal card
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
                          'Hola ${widget.job.clientName ?? 'Usuario Desconocido'}, '
                          'soy ${widget.job.workerName ?? 'Trabajador'}, técnico eléctrico. '
                          'Puedo estar en ${widget.job.location} hoy a las 18:00 como pediste.',
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

                  // Info card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Disponibilidad', 'Inmediato'),
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

                  // Iniciar slider
                  if (_hasContractOffer) ...[
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
                      onSubmit: () => _acceptAndStartService(context),
                    ),
                  ],

                  // Terminar slider
                  if (_hasContractInProgress &&
                      widget.job.status == 'En curso') ...[
                    IgnorePointer(
                      ignoring: _isLoading || _hasSubmitted,
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
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                        text: 'Deslizar para Terminar servicio',
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        onSubmit: () => _completeService(context),
                      ),
                    ),
                  ],
                ],
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
