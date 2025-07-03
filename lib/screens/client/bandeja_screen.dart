import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/contratado_screen.dart';
import 'package:chambea/screens/client/propuestas_screen.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';

class BandejaScreen extends StatelessWidget {
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
                        return _buildJobCard(
                          context,
                          proposals.isEmpty
                              ? 'Pendiente'
                              : 'Propuesta Recibida',
                          '${request['category'] ?? 'Servicio'} - ${request['subcategory'] ?? 'General'}',
                          request['location'] ?? 'Sin ubicación',
                          request['budget'] != null &&
                                  double.tryParse(
                                        request['budget'].toString(),
                                      ) !=
                                      null
                              ? 'BOB: ${request['budget']}'
                              : 'BOB: No especificado',
                          request['is_time_undefined'] == 1
                              ? 'Horario flexible'
                              : request['start_time'] ?? 'Sin horario',
                          'No especificado',
                          'Usuario ${request['created_by'] ?? 'Desconocido'}',
                          0.0,
                          request['id'],
                          request['subcategory'] ?? 'General',
                          proposals,
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
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Pendiente'
                          ? Colors.yellow.shade800
                          : Colors.green.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(price),
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
                Text(location),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text('$time ($duration)'),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.yellow.shade700,
                        ),
                        Text(rating.toString()),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('El precio de $price es mi servicio por hora'),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ContratadoScreen(requestId: requestId),
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
