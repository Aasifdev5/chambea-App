import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/models/job.dart';
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
      if (response['success'] == true &&
          response['data'] is Map<String, dynamic>) {
        final job = Job.fromJson(response['data']);
        emit(JobDetailLoaded(job));
      } else {
        emit(
          JobDetailError(
            response['message']?.toString() ?? 'Failed to fetch job details',
          ),
        );
      }
    } catch (e) {
      emit(JobDetailError(e.toString()));
    }
  }
}
