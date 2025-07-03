import 'package:equatable/equatable.dart';

abstract class ProposalsEvent extends Equatable {
  const ProposalsEvent();

  @override
  List<Object> get props => [];
}

class FetchServiceRequests extends ProposalsEvent {}

class FetchProposals extends ProposalsEvent {
  final int requestId;

  const FetchProposals(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class RejectServiceRequest extends ProposalsEvent {
  final int requestId;

  const RejectServiceRequest(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class RejectProposal extends ProposalsEvent {
  final int proposalId;
  final int requestId;

  const RejectProposal(this.proposalId, this.requestId);

  @override
  List<Object> get props => [proposalId, requestId];
}
