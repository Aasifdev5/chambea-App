import 'package:equatable/equatable.dart';

abstract class ProposalsState extends Equatable {
  const ProposalsState();
  @override
  List<Object?> get props => [];
}

class ProposalsInitial extends ProposalsState {}

class ProposalsLoading extends ProposalsState {}

class ProposalsLoaded extends ProposalsState {
  final Map<String, dynamic> serviceRequest;
  final List<Map<String, dynamic>> proposals;

  const ProposalsLoaded(this.serviceRequest, this.proposals);

  @override
  List<Object?> get props => [serviceRequest, proposals];
}

class ProposalsActionSuccess extends ProposalsState {
  final String message;
  final Map<String, dynamic>? contractData;

  const ProposalsActionSuccess(this.message, {this.contractData});

  @override
  List<Object?> get props => [message, contractData];
}

class ProposalsError extends ProposalsState {
  final String message;

  const ProposalsError(this.message);

  @override
  List<Object?> get props => [message];
}