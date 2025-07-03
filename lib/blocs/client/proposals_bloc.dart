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
  }

  Future<void> _onFetchServiceRequests(
    FetchServiceRequests event,
    Emitter<ProposalsState> emit,
  ) async {
    emit(ProposalsLoading());
    try {
      final response = await ApiService.get('/api/service-requests');
      final requests = List<Map<String, dynamic>>.from(response['data'] ?? []);
      for (var request in requests) {
        for (var proposal in (request['proposals'] ?? [])) {
          try {
            final userResponse = await ApiService.get(
              '/api/users/${proposal['worker_id']}',
            );
            final user = userResponse['data'] ?? {};
            proposal['worker_name'] =
                user['name'] ?? 'Usuario ${proposal['worker_id']}';
            proposal['worker_rating'] = user['rating']?.toDouble() ?? 0.0;
            proposal['worker_image'] = user['image'];
          } catch (e) {
            proposal['worker_name'] = 'Usuario ${proposal['worker_id']}';
            proposal['worker_rating'] = 0.0;
            proposal['worker_image'] = null;
          }
        }
      }
      emit(ProposalsLoaded({}, requests));
    } catch (e) {
      emit(ProposalsError(e.toString()));
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
      for (var proposal in proposals) {
        try {
          final userResponse = await ApiService.get(
            '/api/users/${proposal['worker_id']}',
          );
          final user = userResponse['data'] ?? {};
          proposal['worker_name'] =
              user['name'] ?? 'Usuario ${proposal['worker_id']}';
          proposal['worker_rating'] = user['rating']?.toDouble() ?? 0.0;
          proposal['worker_image'] = user['image'];
        } catch (e) {
          proposal['worker_name'] = 'Usuario ${proposal['worker_id']}';
          proposal['worker_rating'] = 0.0;
          proposal['worker_image'] = null;
        }
      }
      emit(ProposalsLoaded(serviceRequest, proposals));
    } catch (e) {
      emit(ProposalsError(e.toString()));
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
      emit(ProposalsError('Error al rechazar: $e'));
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
      emit(ProposalsError('Error al rechazar propuesta: $e'));
    }
  }
}
