import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/propuestas_screen.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';
import 'package:chambea/services/fcm_service.dart';

class BandejaScreen extends StatefulWidget {
  const BandejaScreen({super.key});

  @override
  _BandejaScreenState createState() => _BandejaScreenState();
}

class _BandejaScreenState extends State<BandejaScreen> {
  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
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
                style: TextStyle(color: Color(0xFF22c55e)),
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
                            ? contract['worker_id'] as int?
                            : (proposals.isNotEmpty
                                  ? proposals[0]['worker_id'] as int?
                                  : null);
                        final workerFirebaseUid = contract != null
                            ? contract['worker_firebase_uid'] as String?
                            : (proposals.isNotEmpty
                                  ? proposals[0]['worker_firebase_uid']
                                        as String?
                                  : null);
                        final workerName = contract != null
                            ? contract['worker_name'] as String?
                            : (proposals.isNotEmpty
                                  ? proposals[0]['worker_name'] as String?
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
                          'No especificado',
                          'Usuario ${request['client_name'] ?? request['created_by'] ?? 'Desconocido'}',
                          request['client_rating']?.toDouble() ?? 0.0,
                          request['id'],
                          request['subcategory'] ?? 'General',
                          proposals,
                          workerId,
                          workerFirebaseUid,
                          workerName,
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
    int? workerId,
    String? workerFirebaseUid,
    String? workerName,
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
                        : status == 'Completado'
                        ? Colors.purple.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: status == 'accepted' || status == 'Completado'
                        ? Border.all(
                            color: status == 'Completado'
                                ? Colors.purple.shade700
                                : Colors.green.shade700,
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (status == 'accepted' || status == 'Completado')
                        Icon(
                          status == 'Completado'
                              ? Icons.done_all
                              : Icons.check_circle,
                          size: 16,
                          color: status == 'Completado'
                              ? Colors.purple.shade800
                              : Colors.green.shade800,
                        ),
                      if (status == 'accepted' || status == 'Completado')
                        const SizedBox(width: 4),
                      Text(
                        status == 'Pendiente'
                            ? 'Pendiente'
                            : status == 'En curso'
                            ? 'En curso'
                            : status == 'Completado'
                            ? 'Completado'
                            : 'Contratado',
                        style: TextStyle(
                          color: status == 'Pendiente'
                              ? Colors.yellow.shade800
                              : status == 'En curso'
                              ? Colors.blue.shade800
                              : status == 'Completado'
                              ? Colors.purple.shade800
                              : Colors.green.shade800,
                          fontSize: 12,
                          fontWeight:
                              status == 'accepted' || status == 'Completado'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
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
                      backgroundColor: const Color(0xFF22c55e),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: proposals.isEmpty
                        ? null
                        : () {
                            print(
                              'DEBUG: Navigating to PropuestasScreen for requestId: $requestId',
                            );
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
          ],
        ),
      ),
    );
  }
}