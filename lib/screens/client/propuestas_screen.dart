import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/contratado_screen.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';
import 'package:chambea/services/fcm_service.dart';

class PropuestasScreen extends StatefulWidget {
  final int requestId;
  final String subcategory;

  const PropuestasScreen({
    super.key,
    required this.requestId,
    required this.subcategory,
  });

  @override
  _PropuestasScreenState createState() => _PropuestasScreenState();
}

class _PropuestasScreenState extends State<PropuestasScreen> {
  @override
  void initState() {
    super.initState();
    FcmService.initialize(context); // Initialize FCM for notifications
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProposalsBloc()..add(FetchProposals(widget.requestId)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Propuestas - ${widget.subcategory}',
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
                                        : proposal['status'] == 'accepted'
                                        ? Colors
                                              .blue
                                              .shade100 // Changed for hired badge
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: proposal['status'] == 'accepted'
                                        ? Border.all(
                                            color: Colors.blue.shade700,
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      if (proposal['status'] == 'accepted')
                                        const Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      if (proposal['status'] == 'accepted')
                                        const SizedBox(width: 4),
                                      Text(
                                        proposal['status'] == 'pending'
                                            ? 'Pendiente'
                                            : proposal['status'] == 'accepted'
                                            ? 'Contratado'
                                            : 'Rechazada',
                                        style: TextStyle(
                                          color: proposal['status'] == 'pending'
                                              ? Colors.yellow.shade800
                                              : proposal['status'] == 'accepted'
                                              ? Colors.blue.shade800
                                              : Colors.red.shade800,
                                          fontSize: 12,
                                          fontWeight:
                                              proposal['status'] == 'accepted'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
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
                              '${widget.subcategory} - Propuesta #${proposal['id']}',
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
                                    onPressed: proposal['status'] == 'accepted'
                                        ? null
                                        : () {
                                            context.read<ProposalsBloc>().add(
                                              RejectProposal(
                                                proposal['id'],
                                                requestId: widget.requestId,
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
                                    onPressed: proposal['status'] == 'accepted'
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ContratadoScreen(
                                                      requestId:
                                                          widget.requestId,
                                                      proposalId:
                                                          proposal['id'],
                                                      workerId:
                                                          proposal['worker_id'],
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
