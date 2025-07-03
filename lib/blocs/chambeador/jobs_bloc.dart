import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  JobsBloc() : super(JobsInitial()) {
    on<FetchJobs>(_onFetchJobs);
  }

  Future<void> _onFetchJobs(FetchJobs event, Emitter<JobsState> emit) async {
    emit(JobsLoading());
    try {
      final response = await ApiService.get('/api/service-requests/jobs');
      if (response['success'] == true) {
        emit(JobsLoaded(response['data'] ?? []));
      } else {
        emit(JobsError(response['message'] ?? 'Failed to fetch jobs'));
      }
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }
}