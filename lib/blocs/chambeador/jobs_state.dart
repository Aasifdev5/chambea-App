import 'package:equatable/equatable.dart';

class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<dynamic> jobs;

  const JobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);

  @override
  List<Object?> get props => [message];
}