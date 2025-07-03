import 'package:equatable/equatable.dart';

abstract class ProposalEvent extends Equatable {
  const ProposalEvent();

  @override
  List<Object> get props => [];
}

class SubmitProposal extends ProposalEvent {
  final int serviceRequestId;
  final String proposedBudget;
  final String message;
  final String availability;
  final String timeToComplete;

  const SubmitProposal({
    required this.serviceRequestId,
    required this.proposedBudget,
    required this.message,
    required this.availability,
    required this.timeToComplete,
  });

  @override
  List<Object> get props => [serviceRequestId, proposedBudget, message, availability, timeToComplete];
}