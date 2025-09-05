import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'proposal_event.dart';
import 'proposal_state.dart';
import 'dart:convert';

class ProposalBloc extends Bloc<ProposalEvent, ProposalState> {
  ProposalBloc() : super(ProposalInitial()) {
    on<SubmitProposal>(_onSubmitProposal);
  }

  Future<void> _onSubmitProposal(
    SubmitProposal event,
    Emitter<ProposalState> emit,
  ) async {
    emit(ProposalSubmitting());
    try {
      final response =
          await ApiService.post('/api/service-requests/proposals', {
            'service_request_id': event.serviceRequestId,
            'proposed_budget': event.proposedBudget,
            'message': event.message,
            'availability': event.availability,
            'time_to_complete': event.timeToComplete,
          });
      print('DEBUG: Proposal submission response: $response');
      if (response['message'] == 'Propuesta enviada exitosamente') {
        emit(ProposalSuccess(response['data']));
      } else {
        emit(
          ProposalError(
            response['message']?.toString() ??
                response['errors']?.toString() ??
                'Failed to submit proposal',
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Proposal submission error: $e');
      String errorMessage = 'Error al enviar la propuesta';
      // Try to parse the error message from the exception
      try {
        final errorString = e.toString();
        if (errorString.contains('Validation error')) {
          final match = RegExp(
            r'Validation error: (.+)$',
          ).firstMatch(errorString);
          errorMessage = match?.group(1) ?? errorMessage;
        } else if (errorString.contains('{"message":')) {
          final jsonString = RegExp(
            r'\{.*\}',
          ).firstMatch(errorString)?.group(0);
          if (jsonString != null) {
            final jsonError = jsonDecode(jsonString) as Map<String, dynamic>;
            errorMessage = jsonError['message']?.toString() ?? errorMessage;
          }
        }
      } catch (parseError) {
        print('DEBUG: Error parsing exception: $parseError');
      }
      emit(ProposalError(errorMessage));
    }
  }
}
