import 'package:equatable/equatable.dart';

class JobDetailState extends Equatable {
  const JobDetailState();

  @override
  List<Object?> get props => [];
}

class JobDetailInitial extends JobDetailState {}

class JobDetailLoading extends JobDetailState {}

class JobDetailLoaded extends JobDetailState {
  final Map<String, dynamic> job;

  const JobDetailLoaded(this.job);

  @override
  List<Object?> get props => [job];
}

class JobDetailError extends JobDetailState {
  final String message;

  const JobDetailError(this.message);

  @override
  List<Object?> get props => [message];
}