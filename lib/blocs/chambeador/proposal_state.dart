import 'package:equatable/equatable.dart';

class ProposalState extends Equatable {
  const ProposalState();

  @override
  List<Object?> get props => [];
}

class ProposalInitial extends ProposalState {}

class ProposalSubmitting extends ProposalState {}

class ProposalSuccess extends ProposalState {
  final Map<String, dynamic> proposal;

  const ProposalSuccess(this.proposal);

  @override
  List<Object?> get props => [proposal];
}

class ProposalError extends ProposalState {
  final String message;

  const ProposalError(this.message);

  @override
  List<Object?> get props => [message];
}
