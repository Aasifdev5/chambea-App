import 'package:equatable/equatable.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

class JobsInitial extends JobsState {
  const JobsInitial();
}

class JobsLoading extends JobsState {
  const JobsLoading();
}

class JobsLoaded extends JobsState {
  final List<dynamic> jobs;
  final Map<String, dynamic>? workerProfile;
  final Map<String, dynamic>? contractSummary;

  const JobsLoaded(this.jobs, {this.workerProfile, this.contractSummary});

  @override
  List<Object?> get props => [jobs, workerProfile, contractSummary];
}

class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);

  @override
  List<Object?> get props => [message];
}
