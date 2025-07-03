import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/contratado_screen.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';

class PropuestasScreen extends StatelessWidget {
  final int requestId;
  final String subcategory;

  const PropuestasScreen({
    super.key,
    required this.requestId,
    required this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProposalsBloc()..add(FetchProposals(requestId)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Propuestas - $subcategory',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          ],
        ),
        body: BlocListener<ProposalsBloc, ProposalsState>(
          listener: (context, state) {
            if (state is ProposalsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ProposalsActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<ProposalsBloc, ProposalsState>(
            builder: (context, state) {
              if (state is ProposalsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProposalsError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is ProposalsLoaded) {
                if (state.proposals.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay propuestas disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: state.proposals.length,
                  itemBuilder: (context, index) {
                    final proposal = state.proposals[index];
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
                                    color: proposal['status'] == 'pending'
                                        ? Colors.yellow.shade100
                                        : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    proposal['status'] == 'pending'
                                        ? 'Pendiente'
                                        : 'En revisión',
                                    style: TextStyle(
                                      color: proposal['status'] == 'pending'
                                          ? Colors.yellow.shade800
                                          : Colors.green.shade800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  proposal['proposed_budget'] != null
                                      ? 'BOB: ${proposal['proposed_budget']}'
                                      : 'BOB: No especificado',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$subcategory - Propuesta #${proposal['id']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
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
                                  '${state.serviceRequest['location'] ?? 'Sin ubicación'}, ${state.serviceRequest['location_details'] ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${proposal['availability'] ?? 'No especificado'} (${proposal['time_to_complete'] ?? '0'} días)',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
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
                                  backgroundImage:
                                      proposal['worker_image'] != null
                                      ? NetworkImage(proposal['worker_image'])
                                      : null,
                                  child: proposal['worker_image'] == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      proposal['worker_name'] ??
                                          'Usuario ${proposal['worker_id']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.yellow.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          (proposal['worker_rating'] ?? 0.0)
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              proposal['message'] ?? 'Sin comentarios',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.green,
                                      ),
                                      foregroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<ProposalsBloc>().add(
                                        RejectProposal(
                                          proposal['id'],
                                          requestId,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Rechazar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ContratadoScreen(
                                                requestId: requestId,
                                                proposalId: proposal['id'],
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Contratar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
