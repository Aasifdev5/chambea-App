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
  final Map<int, Map<String, dynamic>> _workerCache = {};
  int? _newRequestId;

  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
    _workerCache.clear();
  }

  Future<Map<String, dynamic>> _fetchWorkerDetails(int workerId) async {
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
          'review_count': 0,
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
          'review_count': 0,
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

      final reviewsResponse = await ApiService.get(
        '/api/reviews/worker/$workerId',
      );
      print('DEBUG: Reviews response for workerId $workerId: $reviewsResponse');

      String workerName = 'Usuario $workerId';
      String profilePhotoUrl = '';
      int reviewCount = 0;

      if (userResponse['status'] == 'success' && userResponse['data'] != null) {
        final userData = userResponse['data'] as Map<String, dynamic>;
        workerName = userData['name']?.toString().trim() ?? 'Usuario $workerId';
      } else {
        print(
          'ERROR: User API failed for UID $workerFirebaseUid: ${userResponse['message'] ?? 'No message'}',
        );
      }

      if (photoResponse['status'] == 'success' &&
          photoResponse['data'] != null) {
        profilePhotoUrl =
            photoResponse['data']['profile_photo_url']?.toString() ?? '';
        if (profilePhotoUrl.isNotEmpty &&
            !Uri.parse(profilePhotoUrl).isAbsolute) {
          print(
            'ERROR: Invalid profile photo URL for workerId $workerId: $profilePhotoUrl',
          );
          profilePhotoUrl = '';
        }
      } else {
        print(
          'ERROR: Photo API failed for UID $workerFirebaseUid: ${photoResponse['message'] ?? 'No message'}',
        );
      }

      if (reviewsResponse['status'] == 'success' &&
          reviewsResponse['data'] != null &&
          reviewsResponse['data']['reviews'] != null) {
        reviewCount = (reviewsResponse['data']['reviews'] as List).length;
      } else {
        print(
          'ERROR: Reviews API failed for workerId $workerId: ${reviewsResponse['message'] ?? 'No message'}',
        );
      }

      _workerCache[workerId] = {
        'name': workerName,
        'photo': profilePhotoUrl,
        'review_count': reviewCount,
      };
      print(
        'DEBUG: Worker details for workerId $workerId: ${_workerCache[workerId]}',
      );
      return _workerCache[workerId]!;
    } catch (e, stackTrace) {
      print('ERROR: Failed to fetch worker details for workerId $workerId: $e');
      print('Stack Trace: $stackTrace');
      if (e.toString().contains('404')) {
        print('ERROR: User not found for workerId $workerId');
      } else if (e.toString().contains('401')) {
        print('ERROR: Unauthorized request for workerId $workerId');
      }
      _workerCache[workerId] = {
        'name': 'Usuario $workerId',
        'photo': '',
        'review_count': 0,
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ProposalsActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
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
                      proposalId:
                          state.proposals is List && state.proposals.isNotEmpty
                          ? state.proposals[0]['id']
                          : state.proposals is Map
                          ? (state.proposals as Map<String, dynamic>)['id']
                          : null,
                      workerId:
                          state.proposals is List && state.proposals.isNotEmpty
                          ? state.proposals[0]['worker_id']
                          : state.proposals is Map
                          ? (state.proposals
                                as Map<String, dynamic>)['worker_id']
                          : null,
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
                // Access contractStatus safely
                final contractStatus =
                    state.serviceRequest.containsKey('contract_status')
                    ? state.serviceRequest['contract_status'] as String?
                    : null;
                print('DEBUG: Contract status: $contractStatus');

                // Convert single proposal to list for consistent handling
                final List<Map<String, dynamic>> proposalsList =
                    state.proposals is List
                    ? List<Map<String, dynamic>>.from(state.proposals)
                    : state.proposals is Map
                    ? [state.proposals as Map<String, dynamic>]
                    : [];

                if (proposalsList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay propuestas disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                // Check if any proposal is accepted
                final hasAcceptedProposal = proposalsList.any(
                  (p) => p['status'] == 'accepted',
                );
                // Filter proposals: Show only accepted proposal if one exists, otherwise show non-rejected and non-cancelled proposals
                final filteredProposals = hasAcceptedProposal
                    ? proposalsList
                          .where((p) => p['status'] == 'accepted')
                          .toList()
                    : proposalsList
                          .where(
                            (p) =>
                                p['status'] != 'rejected' &&
                                p['status'] != 'cancelled',
                          )
                          .toList();

                if (filteredProposals.isEmpty) {
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
                  itemCount: filteredProposals.length,
                  itemBuilder: (context, index) {
                    final proposal = filteredProposals[index];
                    print(
                      'DEBUG: Proposal ${proposal['id']}: status=${proposal['status']}, worker_id=${proposal['worker_id']}, contract_status=$contractStatus',
                    );
                    final isCompleted =
                        contractStatus == 'completed' &&
                        proposal['status'] == 'accepted';
                    return FutureBuilder<Map<String, dynamic>>(
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
                            : proposal['worker_image'] ?? '';
                        final reviewCount =
                            snapshot.connectionState == ConnectionState.done
                            ? (snapshot.data?['review_count'] ?? 0)
                            : 0;
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
                                            : Colors.blue.shade100,
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
                                                : 'Contratado',
                                            style: TextStyle(
                                              color:
                                                  proposal['status'] ==
                                                      'pending'
                                                  ? Colors.yellow.shade800
                                                  : Colors.blue.shade800,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
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
                                                              color:
                                                                  Colors.white,
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
                                            Row(
                                              children: [
                                                Text(
                                                  workerName,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap:
                                                      proposal['worker_id'] ==
                                                          null
                                                      ? null
                                                      : () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  WorkerReviewsScreen(
                                                                    workerId:
                                                                        proposal['worker_id']
                                                                            .toString(),
                                                                    workerName:
                                                                        workerName,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                  child: const Text(
                                                    'Ver perfil',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF1e40af),
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                                                  (proposal['worker_rating'] ??
                                                          0.0)
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '($reviewCount ${reviewCount == 1 ? 'reseña' : 'reseñas'})',
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
                                          'Ver detalles',
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
                                              backgroundColor: const Color(
                                                0xFF1e40af,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                        requestId:
                                                            widget.requestId,
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
