import 'package:equatable/equatable.dart';

abstract class JobDetailEvent extends Equatable {
  const JobDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchJobDetail extends JobDetailEvent {
  final int requestId;

  const FetchJobDetail(this.requestId);

  @override
  List<Object> get props => [requestId];
}