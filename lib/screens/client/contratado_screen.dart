import 'package:flutter/material.dart';
import 'package:chambea/screens/client/chat_detail_screen.dart';
import 'package:chambea/services/api_service.dart';

class ContratadoScreen extends StatefulWidget {
  final int requestId;

  const ContratadoScreen({required this.requestId, super.key});

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

  @override
  void initState() {
    super.initState();
    _fetchServiceRequest();
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
      final data = response['data'];
      // Placeholder for worker details (fetch from proposals or user API)
      String workerName = 'Usuario ${data['created_by'] ?? 'Desconocido'}';
      String workerRole = data['subcategory'] ?? 'Trabajador';
      double workerRating = 0.0;

      // If proposals exist, use the first proposal's worker details (adjust as needed)
      if (data['proposals']?.isNotEmpty ?? false) {
        final proposal = data['proposals'][0];
        workerName = proposal['worker_name'] ?? workerName;
        workerRole = proposal['worker_role'] ?? workerRole;
        workerRating = (proposal['worker_rating'] ?? 0.0).toDouble();
      }

      setState(() {
        _serviceRequest = data;
        _workerName = workerName;
        _workerRole = workerRole;
        _workerRating = workerRating;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
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
          : Padding(
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
                          Icon(Icons.star, color: const Color(0xFFFFC107)),
                          const SizedBox(width: 4),
                          Text((_workerRating ?? 0.0).toString()),
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
                                ? 'BOB: ${_serviceRequest!['budget']}'
                                : 'BOB: No especificado',
                          ),
                          _buildDetailRow(
                            'Categoría',
                            '${_serviceRequest!['category'] ?? 'Servicio'} - ${_serviceRequest!['subcategory'] ?? 'General'}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
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
