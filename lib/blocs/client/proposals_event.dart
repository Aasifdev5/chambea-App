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

  const RejectProposal(this.proposalId, {required this.requestId});

  @override
  List<Object> get props => [proposalId, requestId];
}

class HireWorker extends ProposalsEvent {
  final int requestId;
  final int? proposalId;
  final String? workerId;
  final double budget;

  const HireWorker({
    required this.requestId,
    this.proposalId,
    this.workerId,
    required this.budget,
  });

  @override
  List<Object> get props => [
    requestId,
    proposalId ?? 0,
    workerId ?? '',
    budget,
  ];
}

class RecontractWorker extends ProposalsEvent {
  final int workerId;
  final int requestId;
  final String subcategory;

  const RecontractWorker({
    required this.workerId,
    required this.requestId,
    required this.subcategory,
  });

  @override
  List<Object> get props => [workerId, requestId, subcategory];
}
