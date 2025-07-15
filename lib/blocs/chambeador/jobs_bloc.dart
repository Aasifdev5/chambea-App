import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'package:retry/retry.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  JobsBloc() : super(JobsInitial()) {
    on<FetchJobs>(_onFetchJobs);
    on<FetchWorkerProfile>(_onFetchWorkerProfile);
    on<FetchContractSummary>(_onFetchContractSummary);
  }

  Future<void> _onFetchJobs(FetchJobs event, Emitter<JobsState> emit) async {
    emit(JobsLoading());
    try {
      final response = await retry(
        () => ApiService.get('/api/service-requests/jobs'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      if (response['success'] == true) {
        emit(
          JobsLoaded(
            response['data'] ?? [],
            workerProfile: state is JobsLoaded
                ? (state as JobsLoaded).workerProfile
                : null,
            contractSummary: state is JobsLoaded
                ? (state as JobsLoaded).contractSummary
                : null,
          ),
        );
      } else {
        emit(JobsError(response['message'] ?? 'Failed to fetch jobs'));
      }
    } catch (e) {
      emit(JobsError('Failed to fetch jobs: $e'));
    }
  }

  Future<void> _onFetchWorkerProfile(
    FetchWorkerProfile event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobsLoading());
    try {
      final response = await retry(
        () => ApiService.get('/api/chambeador/profile'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      if (response['status'] == 'success' && response['data'] != null) {
        emit(
          JobsLoaded(
            state is JobsLoaded ? (state as JobsLoaded).jobs : [],
            workerProfile: response['data'],
            contractSummary: state is JobsLoaded
                ? (state as JobsLoaded).contractSummary
                : null,
          ),
        );
      } else {
        emit(
          JobsError(response['message'] ?? 'Failed to fetch worker profile'),
        );
      }
    } catch (e) {
      emit(JobsError('Failed to fetch worker profile: $e'));
    }
  }

  Future<void> _onFetchContractSummary(
    FetchContractSummary event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobsLoading());
    try {
      final response = await retry(
        () => ApiService.get('/api/worker/contracts/summary'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      if (response['status'] == 'success' && response['data'] != null) {
        emit(
          JobsLoaded(
            state is JobsLoaded ? (state as JobsLoaded).jobs : [],
            workerProfile: state is JobsLoaded
                ? (state as JobsLoaded).workerProfile
                : null,
            contractSummary: response['data'],
          ),
        );
      } else {
        emit(
          JobsError(response['message'] ?? 'Failed to fetch contract summary'),
        );
      }
    } catch (e) {
      emit(JobsError('Failed to fetch contract summary: $e'));
    }
  }
}
