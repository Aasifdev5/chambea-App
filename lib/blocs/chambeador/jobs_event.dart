import 'package:equatable/equatable.dart';

abstract class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object> get props => [];
}

class FetchJobs extends JobsEvent {}