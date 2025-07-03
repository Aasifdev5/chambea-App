import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'job_detail_event.dart';
import 'job_detail_state.dart';

class JobDetailBloc extends Bloc<JobDetailEvent, JobDetailState> {
  JobDetailBloc() : super(JobDetailInitial()) {
    on<FetchJobDetail>(_onFetchJobDetail);
  }

  Future<void> _onFetchJobDetail(
    FetchJobDetail event,
    Emitter<JobDetailState> emit,
  ) async {
    emit(JobDetailLoading());
    try {
      final response = await ApiService.get(
        '/api/service-requests/job/${event.requestId}',
      );
      if (response['success'] == true) {
        emit(JobDetailLoaded(response['data']));
      } else {
        emit(
          JobDetailError(response['message'] ?? 'Failed to fetch job details'),
        );
      }
    } catch (e) {
      emit(JobDetailError(e.toString()));
    }
  }
}
