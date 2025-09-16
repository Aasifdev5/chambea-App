import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/chat_detail_screen.dart';
import 'package:chambea/screens/client/review.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/services/fcm_service.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chambea/screens/client/contract_confirmation_screen.dart';

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
  String? _workerFirebaseUid;
  TextEditingController _budgetController = TextEditingController();
  List<Map<String, dynamic>> _proposals = [];
  String? _accountType;

  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
    _checkAccountTypeAndFetch();
  }

  Future<void> _checkAccountTypeAndFetch() async {
    try {
      final accountType = await ApiService.getAccountType();
      setState(() {
        _accountType = accountType;
      });
      if (accountType != 'Client') {
        print('DEBUG: User is $accountType, not authorized for ContratadoScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solo los clientes pueden acceder a esta pantalla'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
        );
        return;
      }
      await _fetchServiceRequest();
    } catch (e) {
      print('DEBUG: Error checking account type: $e');
      setState(() {
        _isLoading = false;
        _error = 'Error al verificar el tipo de cuenta: $e';
      });
    }
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
      print('DEBUG: Full service request response: $response');
      final data = Map<String, dynamic>.from(response['data'] ?? {});
      String workerName = 'Usuario Desconocido';
      String workerRole = data['subcategory'] ?? 'Trabajador';
      double workerRating = 0.0;
      String? workerFirebaseUid;
      List<Map<String, dynamic>> proposals = List<Map<String, dynamic>>.from(
        data['proposals'] ?? [],
      );

      if (widget.workerId != null) {
        try {
          final uidResponse = await ApiService.get(
            '/api/users/map-id-to-uid/${widget.workerId}',
          );
          print('DEBUG: Map ID to UID response for workerId ${widget.workerId}: $uidResponse');
          workerFirebaseUid = uidResponse['data']['uid'];
          if (workerFirebaseUid != null) {
            final userResponse = await ApiService.get(
              '/api/users/$workerFirebaseUid',
            );
            print('DEBUG: User response for $workerFirebaseUid: $userResponse');
            if (userResponse['status'] == 'success') {
              final userData = userResponse['data'] ?? {};
              workerName = userData['name'] ?? 'Usuario $workerFirebaseUid';
              workerRole = userData['account_type'] == 'Chambeador'
                  ? data['subcategory'] ?? 'Trabajador'
                  : 'Trabajador';
              workerRating = userData['rating']?.toDouble() ?? 0.0;
            } else {
              print('User API returned error: ${userResponse['message']}');
            }
          } else {
            print('Failed to map worker_id ${widget.workerId} to Firebase UID');
          }
        } catch (e) {
          print('Error fetching worker profile for workerId ${widget.workerId}: $e');
        }
      }

      if (workerFirebaseUid == null) {
        if (widget.proposalId != null) {
          final selectedProposal = proposals.firstWhere(
            (proposal) => proposal['id'] == widget.proposalId,
            orElse: () => {},
          );
          workerFirebaseUid = selectedProposal['worker_firebase_uid'];
          workerName = selectedProposal['worker_name'] ?? 'Usuario Desconocido';
          workerRole = selectedProposal['worker_role'] ?? data['subcategory'] ?? 'Trabajador';
          workerRating = selectedProposal['worker_rating']?.toDouble() ?? 0.0;
        } else if (data['worker_firebase_uid'] != null && data['worker_id'] != null) {
          workerFirebaseUid = data['worker_firebase_uid'];
          try {
            final userResponse = await ApiService.get(
              '/api/users/$workerFirebaseUid',
            );
            print('DEBUG: User response for $workerFirebaseUid: $userResponse');
            if (userResponse['status'] == 'success') {
              final userData = userResponse['data'] ?? {};
              workerName = userData['name'] ?? 'Usuario $workerFirebaseUid';
              workerRole = userData['account_type'] == 'Chambeador'
                  ? data['subcategory'] ?? 'Trabajador'
                  : 'Trabajador';
              workerRating = userData['rating']?.toDouble() ?? 0.0;
            } else {
              print('User API returned error: ${userResponse['message']}');
            }
          } catch (e) {
            print('Error fetching worker from service request: $e');
          }
        }
      }

      // if (workerFirebaseUid != null) {
      //   try {
      //     final accountTypeResponse = await ApiService.get(
      //       '/api/account-type/$workerFirebaseUid',
      //     );
      //     print('DEBUG: Account type response for $workerFirebaseUid: $accountTypeResponse');
      //     if (accountTypeResponse['data']['account_type'] != 'Chambeador') {
      //       print('Worker is not a Chambeador: ${accountTypeResponse['data']['account_type']}');
      //       workerFirebaseUid = null;
      //     }
      //   } catch (e) {
      //     print('Error verifying account type: $e');
      //     workerFirebaseUid = null;
      //   }
      // }

      setState(() {
        _serviceRequest = data;
        _workerName = workerName;
        _workerRole = workerRole;
        _workerRating = workerRating;
        _workerFirebaseUid = workerFirebaseUid;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe iniciar sesión')),
      );
      return;
    }

    if (_accountType != 'Client') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo los clientes pueden contratar servicios')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
      );
      return;
    }

    if (budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un presupuesto válido')),
      );
      return;
    }

    String? workerFirebaseUid;
    if (workerId != null) {
      try {
        final uidResponse = await ApiService.get(
          '/api/users/map-id-to-uid/$workerId',
        );
        workerFirebaseUid = uidResponse['data']['uid'] ?? null;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener el trabajador: $e')),
        );
        return;
      }
    } else {
      workerFirebaseUid = _workerFirebaseUid;
    }

    // Removed conditions for "No se pudo obtener el ID del trabajador" and "No se ha seleccionado un trabajador válido"
    context.read<ProposalsBloc>().add(
          HireWorker(
            requestId: widget.requestId,
            proposalId: proposalId ?? widget.proposalId,
            workerId: workerFirebaseUid,
            budget: budget,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_accountType == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_accountType != 'Client') {
      return const Scaffold(
        body: Center(child: Text('Acceso denegado: Solo para clientes')),
      );
    }

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ContractConfirmationScreen(
                  requestId: widget.requestId,
                  workerId: _workerFirebaseUid,
                  workerName: _workerName,
                  workerRole: _workerRole,
                  workerRating: _workerRating,
                  date: _serviceRequest?['date'],
                  location:
                      '${_serviceRequest?['location'] ?? 'Sin ubicación'}, ${_serviceRequest?['location_details'] ?? ''}',
                  paymentMethod: _serviceRequest?['payment_method'] == 'Código QR'
                      ? 'El pago puede realizar mediante Código QR o con efectivo después de finalizar el servicio.'
                      : 'El pago puede realizar con efectivo después de finalizar el servicio.',
                  budget: _serviceRequest?['budget'] != null &&
                          double.tryParse(_serviceRequest!['budget'].toString()) != null
                      ? 'BOB ${_serviceRequest?['budget']}'
                      : 'BOB No especificado',
                ),
              ),
            );
          } else if (state is ProposalsError) {
            String errorMessage = state.message;
            if (errorMessage.contains('Ya has enviado una oferta o contratado a este trabajador')) {
              errorMessage = 'Ya has enviado una oferta o contratado a este trabajador para esta solicitud de servicio.';
            } else {
              errorMessage = 'Error al contratar el servicio: $errorMessage';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
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
                                        : _serviceRequest!['status'] == 'Completado'
                                            ? Colors.purple.shade100
                                            : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _serviceRequest!['status'] == 'accepted'
                                      ? Colors.green.shade700
                                      : _serviceRequest!['status'] == 'En curso'
                                          ? Colors.blue.shade700
                                          : _serviceRequest!['status'] == 'Completado'
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
                                            : _serviceRequest!['status'] == 'Completado'
                                                ? Icons.done_all
                                                : Icons.hourglass_empty,
                                    size: 18,
                                    color: _serviceRequest!['status'] == 'accepted'
                                        ? Colors.green.shade800
                                        : _serviceRequest!['status'] == 'En curso'
                                            ? Colors.blue.shade800
                                            : _serviceRequest!['status'] == 'Completado'
                                                ? Colors.purple.shade800
                                                : Colors.grey.shade800,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _serviceRequest!['status'] == 'accepted'
                                        ? 'Contratado'
                                        : _serviceRequest!['status'] == 'En curso'
                                            ? 'En curso'
                                            : _serviceRequest!['status'] == 'Completado'
                                                ? 'Completado'
                                                : 'Pendiente',
                                    style: TextStyle(
                                      color: _serviceRequest!['status'] == 'accepted'
                                          ? Colors.green.shade800
                                          : _serviceRequest!['status'] == 'En curso'
                                              ? Colors.blue.shade800
                                              : _serviceRequest!['status'] == 'Completado'
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
                              _serviceRequest!['status'] == 'Completado'
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
                                              double.tryParse(_serviceRequest!['budget'].toString()) != null
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
                                      _serviceRequest!['description'] ?? 'Sin descripción',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_serviceRequest!['status'] == null ||
                                _serviceRequest!['status'] == 'Pendiente')
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
                                _serviceRequest!['status'] != 'Completado')
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
                            if (_serviceRequest!['status'] == 'Completado')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: _workerFirebaseUid == null
                                    ? null
                                    : () {
                                        print('DEBUG: Navigating to ReviewServiceScreen for workerId: $_workerFirebaseUid');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReviewServiceScreen(
                                              requestId: widget.requestId,
                                              workerId: _workerFirebaseUid!,
                                              workerName: _workerName != 'Cargando...' ? _workerName : null,
                                            ),
                                          ),
                                        );
                                      },
                                child: const Text('Calificar Servicio'),
                              ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _workerFirebaseUid != null &&
                                        ['accepted', 'En curso', 'Completado'].contains(_serviceRequest!['status'])
                                    ? Colors.green
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: _workerFirebaseUid != null &&
                                      ['accepted', 'En curso', 'Completado'].contains(_serviceRequest!['status'])
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatDetailScreen(
                                            workerId: _workerFirebaseUid!,
                                            requestId: widget.requestId,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Text(
                                _workerFirebaseUid != null &&
                                        ['accepted', 'En curso', 'Completado'].contains(_serviceRequest!['status'])
                                    ? 'Chat with your worker'
                                    : 'Seleccione un trabajador para chatear',
                              ),
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

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
}