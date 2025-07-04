import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/chat_detail_screen.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/services/fcm_service.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Map<String, dynamic>> _proposals = [];

  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
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
      String workerName = 'Usuario Desconocido';
      String workerRole = data['subcategory'] ?? 'Trabajador';
      double workerRating = 0.0;
      List<Map<String, dynamic>> proposals = List<Map<String, dynamic>>.from(
        data['proposals'] ?? [],
      );

      if (widget.proposalId != null || widget.workerId != null) {
        Map<String, dynamic> selectedProposal = {};
        if (widget.proposalId != null) {
          selectedProposal = proposals.firstWhere(
            (proposal) => proposal['id'] == widget.proposalId,
            orElse: () => {},
          );
        }

        final targetWorkerId = widget.proposalId != null
            ? selectedProposal.isNotEmpty
                  ? selectedProposal['worker_id']
                  : widget.workerId
            : widget.workerId;

        if (targetWorkerId != null) {
          try {
            final userResponse = await ApiService.get('/api/profile');
            if (userResponse['status'] == 'error') {
              throw Exception(userResponse['message'] ?? 'User not found');
            }
            final userData = userResponse['data'] ?? {};
            workerName = userData['name'] ?? 'Usuario $targetWorkerId';
            workerRole = data['subcategory'] ?? 'Trabajador';
            workerRating = userData['rating']?.toDouble() ?? 0.0;
          } catch (e) {
            print('Error fetching worker profile: $e');
            if (selectedProposal.isNotEmpty) {
              workerName =
                  selectedProposal['worker_name'] ?? 'Usuario $targetWorkerId';
              workerRole = data['subcategory'] ?? 'Trabajador';
              workerRating =
                  selectedProposal['worker_rating']?.toDouble() ?? 0.0;
            } else {
              workerName = 'Usuario $targetWorkerId';
            }
          }
        }
      }

      setState(() {
        _serviceRequest = data;
        _workerName = workerName;
        _workerRole = workerRole;
        _workerRating = workerRating;
        _proposals = proposals;
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

  Future<void> _hireWorker({
    int? proposalId,
    int? workerId,
    required double budget,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debe iniciar sesión')));
      return;
    }

    if (budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un presupuesto válido')),
      );
      return;
    }

    context.read<ProposalsBloc>().add(
      HireWorker(
        requestId: widget.requestId,
        proposalId: proposalId ?? widget.proposalId,
        workerId: workerId ?? widget.workerId,
        budget: budget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
      body: BlocListener<ProposalsBloc, ProposalsState>(
        listener: (context, state) {
          if (state is ProposalsActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            _fetchServiceRequest(); // Refresh to update status and worker
          } else if (state is ProposalsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: _isLoading
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
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _serviceRequest!['status'] == 'accepted'
                            ? Colors.green.shade100
                            : _serviceRequest!['status'] == 'En curso'
                            ? Colors.blue.shade100
                            : _serviceRequest!['status'] == 'completed'
                            ? Colors.purple.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _serviceRequest!['status'] == 'accepted'
                              ? Colors.green.shade700
                              : _serviceRequest!['status'] == 'En curso'
                              ? Colors.blue.shade700
                              : _serviceRequest!['status'] == 'completed'
                              ? Colors.purple.shade700
                              : Colors.grey.shade700,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _serviceRequest!['status'] == 'accepted'
                                ? Icons.check_circle
                                : _serviceRequest!['status'] == 'En curso'
                                ? Icons.play_circle
                                : _serviceRequest!['status'] == 'completed'
                                ? Icons.done_all
                                : Icons.hourglass_empty,
                            size: 18,
                            color: _serviceRequest!['status'] == 'accepted'
                                ? Colors.green.shade800
                                : _serviceRequest!['status'] == 'En curso'
                                ? Colors.blue.shade800
                                : _serviceRequest!['status'] == 'completed'
                                ? Colors.purple.shade800
                                : Colors.grey.shade800,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _serviceRequest!['status'] == 'accepted'
                                ? 'Contratado'
                                : _serviceRequest!['status'] == 'En curso'
                                ? 'En curso'
                                : _serviceRequest!['status'] == 'completed'
                                ? 'Completado'
                                : _serviceRequest!['status'] ?? 'Pendiente',
                            style: TextStyle(
                              color: _serviceRequest!['status'] == 'accepted'
                                  ? Colors.green.shade800
                                  : _serviceRequest!['status'] == 'En curso'
                                  ? Colors.blue.shade800
                                  : _serviceRequest!['status'] == 'completed'
                                  ? Colors.purple.shade800
                                  : Colors.grey.shade800,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _serviceRequest!['status'] == 'completed'
                          ? '¡Servicio completado con éxito!'
                          : 'Gracias por elegir nuestro servicio y confiar en nuestro trabajador para ayudarte a realizar su trabajo',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
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
                    // Proposals List (only for pending status)
                    if (_serviceRequest!['status'] == null ||
                        _serviceRequest!['status'] == 'pending')
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Otras Propuestas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _proposals.isEmpty
                                  ? const Text(
                                      'No hay otras propuestas disponibles',
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _proposals.length,
                                      itemBuilder: (context, index) {
                                        final proposal = _proposals[index];
                                        final isSelected =
                                            proposal['id'] == widget.proposalId;
                                        return ListTile(
                                          title: Text(
                                            proposal['worker_name'] ??
                                                'Usuario ${proposal['worker_id']}',
                                          ),
                                          subtitle: Text(
                                            'Presupuesto: BOB ${proposal['budget'] ?? 'No especificado'}',
                                          ),
                                          trailing: isSelected
                                              ? const Text(
                                                  'Seleccionado',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        final budgetController =
                                                            TextEditingController();
                                                        return AlertDialog(
                                                          title: const Text(
                                                            'Confirmar Nueva Propuesta',
                                                          ),
                                                          content: TextField(
                                                            controller:
                                                                budgetController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                const InputDecoration(
                                                                  labelText:
                                                                      'Presupuesto acordado (BOB)',
                                                                ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                'Cancelar',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                final budget =
                                                                    double.tryParse(
                                                                      budgetController
                                                                          .text,
                                                                    );
                                                                if (budget !=
                                                                        null &&
                                                                    budget >
                                                                        0) {
                                                                  _hireWorker(
                                                                    proposalId:
                                                                        proposal['id'],
                                                                    workerId:
                                                                        proposal['worker_id'],
                                                                    budget:
                                                                        budget,
                                                                  );
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                        'Ingrese un presupuesto válido',
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: const Text(
                                                                'Confirmar',
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: const Text('Aceptar'),
                                                ),
                                        );
                                      },
                                    ),
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
                              'Estado',
                              _serviceRequest!['status'] ?? 'Pendiente',
                            ),
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
                                            _serviceRequest!['budget']
                                                .toString(),
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
                    if (_serviceRequest!['status'] != 'accepted' &&
                        _serviceRequest!['status'] != 'En curso' &&
                        _serviceRequest!['status'] != 'completed')
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Presupuesto acordado (BOB)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_serviceRequest!['status'] != 'accepted' &&
                        _serviceRequest!['status'] != 'En curso' &&
                        _serviceRequest!['status'] != 'completed')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () => _hireWorker(
                          budget: double.tryParse(_budgetController.text) ?? 0,
                        ),
                        child: const Text('Confirmar Contratación'),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: widget.workerId == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    workerId: widget.workerId!,
                                    requestId: widget.requestId,
                                  ),
                                ),
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
                    const SizedBox(height: 16),
                  ],
                ),
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
