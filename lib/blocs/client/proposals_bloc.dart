import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
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

      // Batch fetch worker data
      final workerData = await _fetchWorkerData(workerIds);
      for (var request in requests) {
        for (var proposal in (request['proposals'] ?? [])) {
          final workerId = proposal['worker_id'];
          final user = workerData[workerId] ?? {};
          proposal['worker_name'] = user['name'] ?? 'Usuario $workerId';
          proposal['worker_rating'] = user['rating']?.toDouble() ?? 0.0;
          proposal['worker_image'] = user['image'];
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

      // Batch fetch worker data
      final workerData = await _fetchWorkerData(workerIds);
      for (var proposal in proposals) {
        final workerId = proposal['worker_id'];
        final user = workerData[workerId] ?? {};
        proposal['worker_name'] = user['name'] ?? 'Usuario $workerId';
        proposal['worker_rating'] = user['rating']?.toDouble() ?? 0.0;
        proposal['worker_image'] = user['image'];
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
    try {
      await ApiService.post('/api/service-requests/${event.requestId}/hire', {
        'agreed_budget': event.budget,
        if (event.proposalId != null) 'proposal_id': event.proposalId,
        if (event.workerId != null) 'worker_id': event.workerId,
      });
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
        final userResponse = await ApiService.get('/api/users/$workerId');
        workerData[workerId] = userResponse['data'] ?? {};
      } catch (e) {
        workerData[workerId] = {
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
