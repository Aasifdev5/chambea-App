import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'proposal_event.dart';
import 'proposal_state.dart';

class ProposalBloc extends Bloc<ProposalEvent, ProposalState> {
  ProposalBloc() : super(ProposalInitial()) {
    on<SubmitProposal>(_onSubmitProposal);
  }

  Future<void> _onSubmitProposal(SubmitProposal event, Emitter<ProposalState> emit) async {
    emit(ProposalSubmitting());
    try {
      final response = await ApiService.post('/api/service-requests/proposals', {
        'service_request_id': event.serviceRequestId,
        'proposed_budget': event.proposedBudget,
        'message': event.message,
        'availability': event.availability,
        'time_to_complete': event.timeToComplete,
      });
      if (response['message'] == 'Proposal submitted successfully') {
        emit(ProposalSuccess(response['data']));
      } else {
        emit(ProposalError(response['errors']?.toString() ?? 'Failed to submit proposal'));
      }
    } catch (e) {
      emit(ProposalError(e.toString()));
    }
  }
}