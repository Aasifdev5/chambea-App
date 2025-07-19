import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/contratado_screen.dart';
import 'package:chambea/screens/client/review.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';
import 'package:chambea/services/fcm_service.dart';
import 'package:chambea/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final Map<int, String> _workerNameCache = {};

  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
    _workerNameCache.clear();
  }

  Future<String> _fetchWorkerName(int workerId) async {
    if (_workerNameCache.containsKey(workerId)) {
      print(
        'DEBUG: Using cached worker name for workerId $workerId: ${_workerNameCache[workerId]}',
      );
      return _workerNameCache[workerId]!;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('ERROR: No authenticated user for workerId $workerId');
        _workerNameCache[workerId] = 'Usuario $workerId';
        return 'Usuario $workerId';
      }
      print('DEBUG: Authenticated user: ${user.uid}');

      final uidResponse = await ApiService.get(
        '/api/users/map-id-to-uid/$workerId',
      );
      print('DEBUG: UID response for workerId $workerId: $uidResponse');
      final workerFirebaseUid = uidResponse['data']?['uid'] as String?;

      if (workerFirebaseUid == null || workerFirebaseUid.trim().isEmpty) {
        print(
          'ERROR: No valid UID found for workerId $workerId in response: $uidResponse',
        );
        _workerNameCache[workerId] = 'Usuario $workerId';
        return 'Usuario $workerId';
      }

      final userResponse = await ApiService.get(
        '/api/users/$workerFirebaseUid',
      );
      print('DEBUG: User response for UID $workerFirebaseUid: $userResponse');

      if (userResponse['status'] == 'success' && userResponse['data'] != null) {
        final userData = userResponse['data'] as Map<String, dynamic>;
        final workerName = userData['name']?.toString().trim();
        if (workerName != null && workerName.isNotEmpty) {
          _workerNameCache[workerId] = workerName;
          print('DEBUG: Worker name for workerId $workerId: $workerName');
          return workerName;
        } else {
          print(
            'ERROR: Empty or null name for UID $workerFirebaseUid in response: $userResponse',
          );
          _workerNameCache[workerId] = 'Usuario $workerId';
          return 'Usuario $workerId';
        }
      } else {
        print(
          'ERROR: User API failed for UID $workerFirebaseUid: ${userResponse['message'] ?? 'No message'}',
        );
        _workerNameCache[workerId] = 'Usuario $workerId';
        return 'Usuario $workerId';
      }
    } catch (e) {
      print('ERROR: Failed to fetch worker name for workerId $workerId: $e');
      if (e.toString().contains('404')) {
        print('ERROR: User not found for workerId $workerId');
      } else if (e.toString().contains('401')) {
        print('ERROR: Unauthorized request for workerId $workerId');
      }
      _workerNameCache[workerId] = 'Usuario $workerId';
      return 'Usuario $workerId';
    }
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
                style: TextStyle(color: Color(0xFF22c55e), fontSize: 16),
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
                print('DEBUG: Proposals loaded: ${state.proposals}');
                print(
                  'DEBUG: Service request status: ${state.serviceRequest['status']}',
                );
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
                    print(
                      'DEBUG: Proposal ${proposal['id']}: status=${proposal['status']}, worker_id=${proposal['worker_id']}, service_status=${state.serviceRequest['status']}',
                    );
                    final isCompleted =
                        state.serviceRequest['status'] == 'Completado' &&
                        proposal['status'] == 'accepted';
                    return FutureBuilder<String>(
                      future: _fetchWorkerName(proposal['worker_id']),
                      builder: (context, snapshot) {
                        final workerName =
                            snapshot.connectionState == ConnectionState.done
                            ? (snapshot.data ??
                                  'Usuario ${proposal['worker_id']}')
                            : (proposal['worker_name']
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ??
                                  false)
                            ? proposal['worker_name']
                            : 'Cargando...';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            ? Colors.blue.shade100
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
                                                : proposal['status'] ==
                                                      'accepted'
                                                ? 'Contratado'
                                                : 'Rechazada',
                                            style: TextStyle(
                                              color:
                                                  proposal['status'] ==
                                                      'pending'
                                                  ? Colors.yellow.shade800
                                                  : proposal['status'] ==
                                                        'accepted'
                                                  ? Colors.blue.shade800
                                                  : Colors.red.shade800,
                                              fontSize: 12,
                                              fontWeight:
                                                  proposal['status'] ==
                                                      'accepted'
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${state.serviceRequest['location'] ?? 'Sin ubicación'}, ${state.serviceRequest['location_details'] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
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
                                          ? NetworkImage(
                                              proposal['worker_image'],
                                            )
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workerName,
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
                                            color: Color(0xFF22c55e),
                                          ),
                                          foregroundColor: const Color(
                                            0xFF22c55e,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            proposal['status'] == 'accepted'
                                            ? null
                                            : () {
                                                context
                                                    .read<ProposalsBloc>()
                                                    .add(
                                                      RejectProposal(
                                                        proposal['id'],
                                                        requestId:
                                                            widget.requestId,
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
                                          backgroundColor: const Color(
                                            0xFF22c55e,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        onPressed: proposal['worker_id'] == null
                                            ? null
                                            : () {
                                                print(
                                                  'DEBUG: Navigating to ContratadoScreen for workerId: ${proposal['worker_id']}',
                                                );
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
                                if (isCompleted)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF22c55e,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        print(
                                          'DEBUG: Navigating to ReviewServiceScreen for workerId: ${proposal['worker_id']}',
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReviewServiceScreen(
                                                  requestId: widget.requestId,
                                                  workerId:
                                                      proposal['worker_id']
                                                          .toString(),
                                                  workerName:
                                                      workerName !=
                                                          'Cargando...'
                                                      ? workerName
                                                      : null,
                                                ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Calificar',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
