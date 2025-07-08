import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/contratado_screen.dart';
import 'package:chambea/screens/client/propuestas_screen.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';
import 'package:chambea/services/fcm_service.dart';

class BandejaScreen extends StatefulWidget {
  @override
  _BandejaScreenState createState() => _BandejaScreenState();
}

class _BandejaScreenState extends State<BandejaScreen> {
  @override
  void initState() {
    super.initState();
    FcmService.initialize(context); // Initialize FCM for notifications
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProposalsBloc()..add(FetchServiceRequests()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Bandeja'),
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
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Lista de propuestas'),
            ),
            Expanded(
              child: BlocBuilder<ProposalsBloc, ProposalsState>(
                builder: (context, state) {
                  if (state is ProposalsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProposalsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is ProposalsLoaded) {
                    if (state.proposals.isEmpty) {
                      return const Center(
                        child: Text('No hay propuestas disponibles'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.proposals.length,
                      itemBuilder: (context, index) {
                        final request = state.proposals[index];
                        final proposals = List<Map<String, dynamic>>.from(
                          request['proposals'] ?? [],
                        );
                        final contract =
                            request['contract'] as Map<String, dynamic>?;
                        final workerId = contract != null
                            ? contract['worker_id']
                            : (proposals.isNotEmpty
                                  ? proposals[0]['worker_id']
                                  : null);
                        return _buildJobCard(
                          context,
                          request['status'] ?? 'Pendiente',
                          '${request['category'] ?? 'Servicio'} - ${request['subcategory'] ?? 'General'}',
                          request['location'] ?? 'Sin ubicación',
                          request['budget'] != null &&
                                  double.tryParse(
                                        request['budget'].toString(),
                                      ) !=
                                      null
                              ? 'BOB: ${request['budget']}'
                              : 'BOB: No especificado',
                          request['is_time_undefined'] == true
                              ? 'Horario flexible'
                              : (request['start_time'] ?? 'Sin horario'),
                          'No especificado', // Duration not provided in API response
                          'Usuario ${request['client_name'] ?? request['created_by'] ?? 'Desconocido'}',
                          request['client_rating']?.toDouble() ?? 0.0,
                          request['id'],
                          request['subcategory'] ?? 'General',
                          proposals,
                          workerId,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    String status,
    String title,
    String location,
    String price,
    String time,
    String duration,
    String client,
    double rating,
    int requestId,
    String subcategory,
    List<Map<String, dynamic>> proposals,
    dynamic workerId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Pendiente'
                        ? Colors.yellow.shade100
                        : status == 'En curso'
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Pendiente'
                          ? Colors.yellow.shade800
                          : status == 'En curso'
                          ? Colors.blue.shade800
                          : Colors.green.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
                Flexible(child: Text(price, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(location, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '$time ($duration)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client, overflow: TextOverflow.ellipsis),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.yellow.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(rating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'El precio de $price es mi servicio por hora',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: proposals.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropuestasScreen(
                                  requestId: requestId,
                                  subcategory: subcategory,
                                ),
                              ),
                            );
                          },
                    child: Text('Propuestas (${proposals.length})'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      context.read<ProposalsBloc>().add(
                        RejectServiceRequest(requestId),
                      );
                    },
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: workerId == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContratadoScreen(
                                  requestId: requestId,
                                  workerId: workerId,
                                ),
                              ),
                            );
                          },
                    child: const Text('Contratar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
