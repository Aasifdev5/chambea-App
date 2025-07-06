import 'package:bloc/bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'proposals_event.dart';
import 'proposals_state.dart';

class ProposalsBloc extends Bloc<ProposalsEvent, ProposalsState> {
  ProposalsBloc() : super(ProposalsInitial()) {
    on<FetchServiceRequests>(_onFetchServiceRequests);
    on<FetchProposals>(_onFetchProposals);
    on<RejectServiceRequest>(_onRejectServiceRequest);
    on<RejectProposal>(_onRejectProposal);
    on<HireWorker>(_onHireWorker);
  }

  Future<void> _onFetchServiceRequests(
    FetchServiceRequests event,
    Emitter<ProposalsState> emit,
  ) async {
    emit(ProposalsLoading());
    try {
      final response = await ApiService.get('/api/service-requests');
      final requests = List<Map<String, dynamic>>.from(response['data'] ?? []);
      final workerIds = <int>{};
      for (var request in requests) {
        for (var proposal in (request['proposals'] ?? [])) {
          if (proposal['worker_id'] != null) {
            workerIds.add(proposal['worker_id']);
          }
        }
      }

      // Batch fetch worker data using Firebase UIDs
      final workerData = await _fetchWorkerData(workerIds);
      for (var request in requests) {
        for (var proposal in (request['proposals'] ?? [])) {
          final workerId = proposal['worker_id'];
          final user = workerData[workerId] ?? {};
          proposal['worker_name'] = user['name'] ?? 'Usuario $workerId';
          proposal['worker_rating'] = user['rating']?.toDouble() ?? 0.0;
          proposal['worker_image'] = user['image'];
          proposal['worker_firebase_uid'] = user['uid'];
        }
      }
      emit(ProposalsLoaded({'requests': requests}, requests));
    } catch (e) {
      final errorMessage = _handleError(e);
      print('FetchServiceRequests error: $errorMessage');
      emit(ProposalsError(errorMessage));
    }
  }

  Future<void> _onFetchProposals(
    FetchProposals event,
    Emitter<ProposalsState> emit,
  ) async {
    emit(ProposalsLoading());
    try {
      final response = await ApiService.get(
        '/api/service-requests/${event.requestId}',
      );
      final serviceRequest = Map<String, dynamic>.from(response['data'] ?? {});
      final proposals = List<Map<String, dynamic>>.from(
        serviceRequest['proposals'] ?? [],
      );
      final workerIds = <int>{};
      for (var proposal in proposals) {
        if (proposal['worker_id'] != null) {
          workerIds.add(proposal['worker_id']);
        }
      }

      // Batch fetch worker data using Firebase UIDs
      final workerData = await _fetchWorkerData(workerIds);
      for (var proposal in proposals) {
        final workerId = proposal['worker_id'];
        final user = workerData[workerId] ?? {};
        proposal['worker_name'] = user['name'] ?? 'Usuario $workerId';
        proposal['worker_rating'] = user['rating']?.toDouble() ?? 0.0;
        proposal['worker_image'] = user['image'];
        proposal['worker_firebase_uid'] = user['uid'];
      }
      emit(ProposalsLoaded(serviceRequest, proposals));
    } catch (e) {
      final errorMessage = _handleError(e);
      print('FetchProposals error: $errorMessage');
      emit(ProposalsError(errorMessage));
    }
  }

  Future<void> _onRejectServiceRequest(
    RejectServiceRequest event,
    Emitter<ProposalsState> emit,
  ) async {
    try {
      await ApiService.post(
        '/api/service-requests/${event.requestId}/reject',
        {},
      );
      emit(ProposalsActionSuccess('Servicio rechazado'));
      add(FetchServiceRequests());
    } catch (e) {
      final errorMessage = _handleError(e);
      print('RejectServiceRequest error: $errorMessage');
      emit(ProposalsError('Error al rechazar: $errorMessage'));
    }
  }

  Future<void> _onRejectProposal(
    RejectProposal event,
    Emitter<ProposalsState> emit,
  ) async {
    try {
      await ApiService.post(
        '/api/service-requests/proposals/${event.proposalId}/reject',
        {},
      );
      emit(ProposalsActionSuccess('Propuesta rechazada'));
      add(FetchProposals(event.requestId));
    } catch (e) {
      final errorMessage = _handleError(e);
      print('RejectProposal error: $errorMessage');
      emit(ProposalsError('Error al rechazar propuesta: $errorMessage'));
    }
  }

  Future<void> _onHireWorker(
    HireWorker event,
    Emitter<ProposalsState> emit,
  ) async {
    emit(ProposalsLoading());
    try {
      String? workerFirebaseUid = event.workerId;
      if (workerFirebaseUid == null && event.proposalId != null) {
        // Fetch proposal to get worker_id if not provided
        final response = await ApiService.get(
          '/api/service-requests/${event.requestId}',
        );
        final proposals = List<Map<String, dynamic>>.from(
          response['data']['proposals'] ?? [],
        );
        final proposal = proposals.firstWhere(
          (p) => p['id'] == event.proposalId,
          orElse: () => {},
        );
        final numericWorkerId = proposal['worker_id'];
        if (numericWorkerId != null) {
          final uidResponse = await ApiService.get(
            '/api/users/map-id-to-uid/$numericWorkerId',
          );
          workerFirebaseUid = uidResponse['data']['uid'];
        }
      }

      if (workerFirebaseUid == null) {
        throw Exception('Worker ID not provided and could not be resolved');
      }

      // Verify worker is a Chambeador
      final accountTypeResponse = await ApiService.get(
        '/api/account-type/$workerFirebaseUid',
      );
      if (accountTypeResponse['data']['account_type'] != 'Chambeador') {
        throw Exception('Selected worker is not a Chambeador');
      }

      // Hire worker
      await ApiService.post('/api/service-requests/${event.requestId}/hire', {
        'agreed_budget': event.budget,
        if (event.proposalId != null) 'proposal_id': event.proposalId,
        'worker_id': workerFirebaseUid,
      });

      // Initialize chat
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ApiService.post('/api/chats/initialize', {
          'request_id': event.requestId,
          'worker_id': workerFirebaseUid,
          'account_type': 'Client',
        });
      }

      emit(ProposalsActionSuccess('Contrato creado exitosamente'));
      add(FetchServiceRequests());
    } catch (e) {
      final errorMessage = _handleError(e);
      print('HireWorker error: $errorMessage');
      emit(ProposalsError('Error al contratar: $errorMessage'));
    }
  }

  Future<Map<int, Map<String, dynamic>>> _fetchWorkerData(
    Set<int> workerIds,
  ) async {
    final workerData = <int, Map<String, dynamic>>{};
    for (var workerId in workerIds) {
      try {
        // Map numeric ID to Firebase UID
        final uidResponse = await ApiService.get(
          '/api/users/map-id-to-uid/$workerId',
        );
        final workerFirebaseUid = uidResponse['data']['uid'];
        if (workerFirebaseUid != null) {
          // Fetch worker profile
          final userResponse = await ApiService.get(
            '/api/users/$workerFirebaseUid',
          );
          final userData = userResponse['data'] ?? {};
          // Verify account_type
          if (userData['account_type'] == 'Chambeador') {
            workerData[workerId] = {
              'uid': workerFirebaseUid,
              'name': userData['name'] ?? 'Usuario $workerId',
              'rating': userData['rating']?.toDouble() ?? 0.0,
              'image': userData['image'],
            };
          } else {
            workerData[workerId] = {
              'uid': workerFirebaseUid,
              'name': 'Usuario $workerId',
              'rating': 0.0,
              'image': null,
            };
          }
        } else {
          workerData[workerId] = {
            'uid': null,
            'name': 'Usuario $workerId',
            'rating': 0.0,
            'image': null,
          };
        }
      } catch (e) {
        print('Error fetching worker data for ID $workerId: $e');
        workerData[workerId] = {
          'uid': null,
          'name': 'Usuario $workerId',
          'rating': 0.0,
          'image': null,
        };
      }
    }
    return workerData;
  }

  String _handleError(dynamic e) {
    if (e.toString().contains('401')) {
      return 'Sesión no autorizada. Por favor, inicia sesión nuevamente.';
    } else if (e.toString().contains('404')) {
      return 'Recurso no encontrado.';
    } else if (e.toString().contains('403')) {
      return 'Acceso denegado.';
    } else {
      return 'Error inesperado: $e';
    }
  }
}
