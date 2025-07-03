import 'package:flutter/material.dart';
import 'package:chambea/screens/client/chat_detail_screen.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/services/fcm_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ContratadoScreen extends StatefulWidget {
  final int requestId;
  final int? proposalId;
  final int? workerId;

  const ContratadoScreen({
    required this.requestId,
    this.proposalId,
    this.workerId,
    super.key,
  });

  @override
  _ContratadoScreenState createState() => _ContratadoScreenState();
}

class _ContratadoScreenState extends State<ContratadoScreen> {
  Map<String, dynamic>? _serviceRequest;
  bool _isLoading = true;
  String? _error;
  String? _workerName;
  String? _workerRole;
  double? _workerRating;
  TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FcmService.initialize(
      context,
    ); // Initialize FCM for foreground notifications
    _fetchServiceRequest();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _fetchServiceRequest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get(
        '/api/service-requests/${widget.requestId}',
      );
      final data = Map<String, dynamic>.from(response['data'] ?? {});
      String workerName = data['client_name'] ?? 'Usuario Desconocido';
      String workerRole = data['subcategory'] ?? 'Trabajador';
      double workerRating = data['client_rating']?.toDouble() ?? 0.0;

      if (widget.proposalId != null || widget.workerId != null) {
        final proposals = List<Map<String, dynamic>>.from(
          data['proposals'] ?? [],
        );
        int? targetWorkerId;
        Map<String, dynamic> selectedProposal = {};

        if (widget.proposalId != null) {
          selectedProposal = proposals.firstWhere(
            (proposal) => proposal['id'] == widget.proposalId,
            orElse: () => {},
          );
          targetWorkerId = selectedProposal.isNotEmpty
              ? selectedProposal['worker_id']
              : null;
        } else {
          targetWorkerId = widget.workerId;
        }

        if (targetWorkerId != null) {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) throw Exception('Usuario no autenticado');
            final token = await user.getIdToken();
            final userResponse = await http.get(
              Uri.parse('https://chambea.lat/api/profile'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            );

            if (userResponse.statusCode == 200) {
              final userData = json.decode(userResponse.body)['data'];
              workerName = userData['name'] ?? workerName;
              workerRole = userData['account_type'] ?? workerRole;
              workerRating =
                  0.0; // No rating field in /api/profile, default to 0.0
            } else {
              print(
                'Error fetching profile: ${userResponse.statusCode} - ${userResponse.body}',
              );
              if (selectedProposal.isNotEmpty) {
                workerName =
                    selectedProposal['worker_name'] ??
                    'Usuario $targetWorkerId';
                workerRole = selectedProposal['worker_role'] ?? workerRole;
                workerRating =
                    selectedProposal['worker_rating']?.toDouble() ?? 0.0;
              }
            }
          } catch (e) {
            print('Error fetching worker profile: $e');
            if (selectedProposal.isNotEmpty) {
              workerName =
                  selectedProposal['worker_name'] ?? 'Usuario $targetWorkerId';
              workerRole = selectedProposal['worker_role'] ?? workerRole;
              workerRating =
                  selectedProposal['worker_rating']?.toDouble() ?? 0.0;
            }
          }
        }
      }

      setState(() {
        _serviceRequest = data;
        _workerName = workerName;
        _workerRole = workerRole;
        _workerRating = workerRating;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching service request: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _hireWorker() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debe iniciar sesión')));
      return;
    }

    final budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un presupuesto válido')),
      );
      return;
    }

    try {
      final token = await user.getIdToken();
      final url = Uri.parse(
        'https://chambea.lat/api/service-requests/${widget.requestId}/hire',
      );
      final body = {
        'agreed_budget': budget,
        if (widget.proposalId != null) 'proposal_id': widget.proposalId,
        if (widget.workerId != null) 'worker_id': widget.workerId,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrato creado exitosamente')),
        );
        Navigator.pop(context);
      } else {
        final error =
            json.decode(response.body)['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Contratado #${widget.requestId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _serviceRequest == null
          ? const Center(child: Text('No se encontraron detalles'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 80, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Gracias por elegir nuestro servicio y confiar en nuestro trabajador para ayudarte a realizar su trabajo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(_workerName ?? 'Cargando...'),
                      subtitle: Text(_workerRole ?? 'Cargando...'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFC107)),
                          const SizedBox(width: 4),
                          Text((_workerRating ?? 0.0).toStringAsFixed(1)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            'Fecha',
                            _serviceRequest!['date'] ?? 'No especificada',
                          ),
                          _buildDetailRow(
                            'Ubicación',
                            '${_serviceRequest!['location'] ?? 'Sin ubicación'}, ${_serviceRequest!['location_details'] ?? ''}',
                          ),
                          _buildDetailRow(
                            'Forma de pago',
                            _serviceRequest!['payment_method'] == 'Código QR'
                                ? 'El pago puede realizar mediante Código QR o con efectivo después de finalizar el servicio.'
                                : 'El pago puede realizar con efectivo después de finalizar el servicio.',
                          ),
                          _buildDetailRow(
                            'Presupuesto',
                            _serviceRequest!['budget'] != null &&
                                    double.tryParse(
                                          _serviceRequest!['budget'].toString(),
                                        ) !=
                                        null
                                ? 'BOB ${_serviceRequest!['budget']}'
                                : 'BOB No especificado',
                          ),
                          _buildDetailRow(
                            'Categoría',
                            _serviceRequest!['title'] ??
                                '${_serviceRequest!['category'] ?? 'Servicio'} - ${_serviceRequest!['subcategory'] ?? 'General'}',
                          ),
                          _buildDetailRow(
                            'Descripción',
                            _serviceRequest!['description'] ??
                                'Sin descripción',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Presupuesto acordado (BOB)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _hireWorker,
                    child: const Text('Confirmar Contratación'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatDetailScreen()),
                      );
                    },
                    child: const Text('Ir al chat'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver al inicio'),
                  ),
                  const SizedBox(height: 16), // Extra padding to prevent cutoff
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
