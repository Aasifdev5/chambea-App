import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/contratado_screen.dart';
import 'package:chambea/screens/client/review.dart';
import 'package:chambea/screens/client/worker_reviews_screen.dart';
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
  final Map<int, Map<String, String>> _workerCache = {};
  int? _newRequestId;

  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
    _workerCache.clear();
  }

  Future<Map<String, String>> _fetchWorkerDetails(int workerId) async {
    if (_workerCache.containsKey(workerId)) {
      print(
        'DEBUG: Using cached worker details for workerId $workerId: ${_workerCache[workerId]}',
      );
      return _workerCache[workerId]!;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('ERROR: No authenticated user for workerId $workerId');
        _workerCache[workerId] = {
          'name': 'Usuario $workerId',
          'photo': '',
        };
        return _workerCache[workerId]!;
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
        _workerCache[workerId] = {
          'name': 'Usuario $workerId',
          'photo': '',
        };
        return _workerCache[workerId]!;
      }

      final userResponse = await ApiService.get(
        '/api/users/$workerFirebaseUid',
      );
      print('DEBUG: User response for UID $workerFirebaseUid: $userResponse');

      final photoResponse = await ApiService.get(
        '/api/profile-photo/$workerFirebaseUid',
      );
      print('DEBUG: Photo response for UID $workerFirebaseUid: $photoResponse');

      String workerName = 'Usuario $workerId';
      String profilePhotoUrl = '';

      if (userResponse['status'] == 'success' && userResponse['data'] != null) {
        final userData = userResponse['data'] as Map<String, dynamic>;
        workerName = userData['name']?.toString().trim() ?? 'Usuario $workerId';
      } else {
        print(
          'ERROR: User API failed for UID $workerFirebaseUid: ${userResponse['message'] ?? 'No message'}',
        );
      }

      if (photoResponse['status'] == 'success' && photoResponse['data'] != null) {
        profilePhotoUrl = photoResponse['data']['profile_photo_url']?.toString() ?? '';
        if (profilePhotoUrl.isNotEmpty && !Uri.parse(profilePhotoUrl).isAbsolute) {
          print('ERROR: Invalid profile photo URL for workerId $workerId: $profilePhotoUrl');
          profilePhotoUrl = '';
        }
      } else {
        print(
          'ERROR: Photo API failed for UID $workerFirebaseUid: ${photoResponse['message'] ?? 'No message'}',
        );
      }

      _workerCache[workerId] = {
        'name': workerName,
        'photo': profilePhotoUrl,
      };
      print('DEBUG: Worker details for workerId $workerId: ${_workerCache[workerId]}');
      return _workerCache[workerId]!;
    } catch (e) {
      print('ERROR: Failed to fetch worker details for workerId $workerId: $e');
      if (e.toString().contains('404')) {
        print('ERROR: User not found for workerId $workerId');
      } else if (e.toString().contains('401')) {
        print('ERROR: Unauthorized request for workerId $workerId');
      }
      _workerCache[workerId] = {
        'name': 'Usuario $workerId',
        'photo': '',
      };
      return _workerCache[workerId]!;
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
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ProposalsActionSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              if (state.message == 'Recontratación iniciada exitosamente') {
                setState(() {
                  _newRequestId = null;
                });
              }
            } else if (state is ProposalsLoaded && _newRequestId == null) {
              if (state.serviceRequest['id'] != widget.requestId) {
                setState(() {
                  _newRequestId = state.serviceRequest['id'];
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContratadoScreen(
                      requestId: state.serviceRequest['id'],
                      proposalId: null,
                      workerId: null,
                    ),
                  ),
                );
              }
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
                    return FutureBuilder<Map<String, String>>(
                      future: _fetchWorkerDetails(proposal['worker_id']),
                      builder: (context, snapshot) {
                        final workerName =
                            snapshot.connectionState == ConnectionState.done
                                ? (snapshot.data?['name'] ??
                                    'Usuario ${proposal['worker_id']}')
                                : (proposal['worker_name']
                                          ?.toString()
                                          .trim()
                                          .isNotEmpty ??
                                      false)
                                    ? proposal['worker_name']
                                    : 'Cargando...';
                        final profilePhotoUrl =
                            snapshot.connectionState == ConnectionState.done
                                ? (snapshot.data?['photo'] ?? '')
                                : '';
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
                                              color: proposal['status'] ==
                                                      'pending'
                                                  ? Colors.yellow.shade800
                                                  : proposal['status'] ==
                                                          'accepted'
                                                      ? Colors.blue.shade800
                                                      : Colors.red.shade800,
                                              fontSize: 12,
                                              fontWeight: proposal['status'] ==
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
                                GestureDetector(
                                  onTap: proposal['worker_id'] == null
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WorkerReviewsScreen(
                                                workerId: proposal['worker_id'],
                                                workerName: workerName,
                                              ),
                                            ),
                                          );
                                        },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.grey.shade300,
                                        child: profilePhotoUrl.isNotEmpty
                                            ? ClipOval(
                                                child: CachedNetworkImage(
                                                  imageUrl: profilePhotoUrl,
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 20,
                                              ),
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
                                              decoration: TextDecoration.underline,
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
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF22c55e),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                                      proposalId: proposal['id'],
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
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF22c55e),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
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
                                                    workerId: proposal[
                                                            'worker_id']
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
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1e40af),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Confirmar Recontratación',
                                                  ),
                                                  content: const Text(
                                                    '¿Desea recontratar a este trabajador?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        print(
                                                          'DEBUG: Initiating recontract for workerId: ${proposal['worker_id']}, type: ${proposal['worker_id'].runtimeType}, requestId: ${widget.requestId}',
                                                        );
                                                        context
                                                            .read<ProposalsBloc>()
                                                            .add(
                                                              RecontractWorker(
                                                                workerId:
                                                                    proposal[
                                                                        'worker_id'],
                                                                requestId: widget
                                                                    .requestId,
                                                                subcategory: widget
                                                                    .subcategory,
                                                              ),
                                                            );
                                                      },
                                                      child: const Text(
                                                        'Confirmar',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Recontratar',
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