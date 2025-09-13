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
    on<RecontractWorker>(_onRecontractWorker);
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

      final accountTypeResponse = await ApiService.get(
        '/api/account-type/$workerFirebaseUid',
      );
      // if (accountTypeResponse['data']['account_type'] != 'Chambeador') {
      //   throw Exception('Selected worker is not a Chambeador');
      // }

      final response = await ApiService.post('/api/service-requests/${event.requestId}/hire', {
        'agreed_budget': event.budget,
        if (event.proposalId != null) 'proposal_id': event.proposalId,
        'worker_id': workerFirebaseUid,
      });

      emit(ProposalsActionSuccess('Contrato creado exitosamente', contractData: response['contract']));
      add(FetchServiceRequests());
    } catch (e) {
      final errorMessage = _handleError(e);
      print('HireWorker error: $errorMessage');
      emit(ProposalsError('Error al contratar: $errorMessage'));
    }
  }

  Future<void> _onRecontractWorker(
    RecontractWorker event,
    Emitter<ProposalsState> emit,
  ) async {
    emit(ProposalsLoading());
    try {
      // Ensure workerId is numeric
      final numericWorkerId = event.workerId;
      print(
        'DEBUG: RecontractWorker event.workerId: $numericWorkerId (type: ${numericWorkerId.runtimeType})',
      );

      if (numericWorkerId <= 0) {
        throw Exception('Invalid worker_id: $numericWorkerId');
      }

      // Log the payload before sending
      final payload = {
        'worker_id': numericWorkerId,
        'subcategory': event.subcategory,
      };
      print(
        'DEBUG: Sending POST /api/contracts/rehire/${event.requestId} with payload: $payload',
      );

      final response = await ApiService.post(
        '/api/contracts/rehire/${event.requestId}',
        payload,
      );

      print('DEBUG: Recontract response: $response');

      if (response['status'] == 'success') {
        emit(ProposalsActionSuccess('Recontratación iniciada exitosamente'));
        emit(
          ProposalsLoaded({
            'id': response['contract']['service_request_id'],
          }, []),
        );
      } else {
        emit(ProposalsError(response['message'] ?? 'Error al recontratar'));
      }
    } catch (e) {
      final errorMessage = _handleError(e);
      print('RecontractWorker error: $errorMessage');
      emit(ProposalsError(errorMessage));
    }
  }

  Future<Map<int, Map<String, dynamic>>> _fetchWorkerData(
    Set<int> workerIds,
  ) async {
    final workerData = <int, Map<String, dynamic>>{};
    for (var workerId in workerIds) {
      try {
        final uidResponse = await ApiService.get(
          '/api/users/map-id-to-uid/$workerId',
        );
        final workerFirebaseUid = uidResponse['data']['uid'];
        if (workerFirebaseUid != null) {
          final userResponse = await ApiService.get(
            '/api/users/$workerFirebaseUid',
          );
          final userData = userResponse['data'] ?? {};
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
    } else if (e.toString().contains('422')) {
      return 'Datos inválidos enviados al servidor.';
    } else {
      return 'Error inesperado: $e';
    }
  }
}
