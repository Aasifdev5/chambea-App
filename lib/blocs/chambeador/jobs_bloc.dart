import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retry/retry.dart';
import 'package:chambea/services/api_service.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  JobsBloc() : super(const JobsInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
    on<FetchJobs>(_onFetchJobs);
    on<FetchWorkerProfile>(_onFetchWorkerProfile);
    on<FetchContractSummary>(_onFetchContractSummary);
  }

  String _normalizeImagePath(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    // Remove 'https://chambea.lat/storage/' prefix if present
    String normalized = imagePath.replaceAll(
      'https://chambea.lat/storage/',
      'https://chambea.lat/',
    );
    // Ensure the path starts with 'uploads/service_requests/' or 'service_requests/'
    if (normalized.contains('uploads/service_requests/') ||
        normalized.contains('service_requests/')) {
      return normalized;
    }
    // If it's a relative path, prepend the base URL
    if (!normalized.startsWith('http')) {
      return 'https://chambea.lat/$normalized';
    }
    return normalized;
  }

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<JobsState> emit,
  ) async {
    emit(const JobsLoading());
    try {
      final [
        jobsResponse,
        profileResponse,
        summaryResponse,
      ] = await Future.wait([
        retry(
          () => ApiService.get('/api/service-requests/jobs'),
          maxAttempts: 3,
          delayFactor: const Duration(seconds: 1),
        ),
        retry(
          () => ApiService.get('/api/chambeador/profile'),
          maxAttempts: 3,
          delayFactor: const Duration(seconds: 1),
        ),
        retry(
          () => ApiService.get('/api/worker/contracts/summary'),
          maxAttempts: 3,
          delayFactor: const Duration(seconds: 1),
        ),
      ]);

      if (jobsResponse['success'] == true &&
          profileResponse['status'] == 'success' &&
          summaryResponse['status'] == 'success') {
        final List<dynamic> jobs = jobsResponse['data'] ?? [];
        final enrichedJobs = await Future.wait(
          jobs.map((job) async {
            try {
              // Normalize image path
              job['image'] = _normalizeImagePath(job['image']);
              print(
                'DEBUG: Normalized image path for job ${job['id']}: ${job['image']}',
              );
              final clientResponse = await retry(
                () => ApiService.get('/api/users/${job['created_by']}'),
                maxAttempts: 2,
                delayFactor: const Duration(seconds: 1),
              );
              if (clientResponse['status'] == 'success') {
                job['client_name'] =
                    clientResponse['data']['name'] ??
                    'Usuario ${job['created_by']}';
                job['client_rating'] =
                    clientResponse['data']['rating']?.toDouble() ?? 0.0;
              } else {
                job['client_name'] = 'Usuario ${job['created_by']}';
                job['client_rating'] = 0.0;
              }
            } catch (e) {
              print(
                'ERROR: Failed to fetch client data for user ${job['created_by']}: $e',
              );
              job['client_name'] = 'Usuario ${job['created_by']}';
              job['client_rating'] = 0.0;
            }
            return job;
          }).toList(),
        );

        emit(
          JobsLoaded(
            enrichedJobs,
            workerProfile: profileResponse['data'],
            contractSummary: summaryResponse['data'],
          ),
        );
      } else {
        emit(const JobsError('Failed to fetch home data'));
      }
    } catch (e) {
      emit(JobsError('Failed to fetch home data: $e'));
    }
  }

  Future<void> _onFetchJobs(FetchJobs event, Emitter<JobsState> emit) async {
    emit(const JobsLoading());
    try {
      final response = await retry(
        () => ApiService.get('/api/service-requests/jobs'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      if (response['success'] == true) {
        final List<dynamic> jobs = response['data'] ?? [];
        final enrichedJobs = await Future.wait(
          jobs.map((job) async {
            try {
              // Normalize image path
              job['image'] = _normalizeImagePath(job['image']);
              print(
                'DEBUG: Normalized image path for job ${job['id']}: ${job['image']}',
              );
              final clientResponse = await retry(
                () => ApiService.get('/api/users/${job['created_by']}'),
                maxAttempts: 2,
                delayFactor: const Duration(seconds: 1),
              );
              if (clientResponse['status'] == 'success') {
                job['client_name'] =
                    clientResponse['data']['name'] ??
                    'Usuario ${job['created_by']}';
                job['client_rating'] =
                    clientResponse['data']['rating']?.toDouble() ?? 0.0;
              } else {
                job['client_name'] = 'Usuario ${job['created_by']}';
                job['client_rating'] = 0.0;
              }
            } catch (e) {
              print(
                'ERROR: Failed to fetch client data for user ${job['created_by']}: $e',
              );
              job['client_name'] = 'Usuario ${job['created_by']}';
              job['client_rating'] = 0.0;
            }
            return job;
          }).toList(),
        );
        emit(
          JobsLoaded(
            enrichedJobs,
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
    emit(const JobsLoading());
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
    emit(const JobsLoading());
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
