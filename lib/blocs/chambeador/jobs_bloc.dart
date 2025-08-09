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

  String _normalizeImagePath(String? imagePath, {bool isProfilePhoto = false}) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      print('DEBUG: Image path is null or empty');
      return '';
    }

    String normalized = imagePath.trim();

    // Remove duplicate or incorrect prefixes
    normalized = normalized.replaceAll(
      RegExp(r'^https://chambea\.lat/https://chambea\.lat/'),
      'https://chambea.lat/',
    );

    // Remove 'storage/' prefix
    normalized = normalized.replaceFirst(RegExp(r'^storage/'), '');

    // Normalize case for prefix checks
    String lowerCasePath = normalized.toLowerCase();

    // Define expected prefixes
    const profilePrefix = 'uploads/profile_photos/';
    const jobPrefix = 'uploads/service_requests/';

    // Remove existing prefix if present to avoid duplication
    if (isProfilePhoto && lowerCasePath.contains(profilePrefix.toLowerCase())) {
      normalized = normalized.substring(normalized.toLowerCase().indexOf(profilePrefix.toLowerCase()) + profilePrefix.length);
    } else if (!isProfilePhoto && lowerCasePath.contains(jobPrefix.toLowerCase())) {
      normalized = normalized.substring(normalized.toLowerCase().indexOf(jobPrefix.toLowerCase()) + jobPrefix.length);
    } else if (isProfilePhoto && (lowerCasePath.contains('uploads/user_profiles/') || lowerCasePath.contains('uploads/chambeador_profiles/'))) {
      print('WARNING: Unexpected profile photo path: $normalized');
      normalized = normalized.substring(normalized.lastIndexOf('/') + 1);
    } else if (!isProfilePhoto && lowerCasePath.contains('service_requests/')) {
      print('WARNING: Unexpected job image path: $normalized');
      normalized = normalized.substring(normalized.lastIndexOf('/') + 1);
    }

    // Add correct prefix
    normalized = isProfilePhoto ? 'uploads/profile_photos/$normalized' : 'uploads/service_requests/$normalized';

    // Prepend base URL for relative paths
    if (!normalized.startsWith('http')) {
      normalized = 'https://chambea.lat/$normalized';
    }

    // Convert 'Uploads/' to 'uploads/' for consistency
    normalized = normalized.replaceAll('Uploads/', 'uploads/');

    // Validate URL
    try {
      final uri = Uri.parse(normalized);
      if (!uri.isAbsolute || uri.host.isEmpty) {
        print('ERROR: Invalid URL format: $normalized');
        return '';
      }
      print('DEBUG: Normalized image path: $normalized');
      return normalized;
    } catch (e, stackTrace) {
      print('ERROR: Failed to parse URL $normalized: $e\nStack Trace: $stackTrace');
      return '';
    }
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

      print('DEBUG: Jobs response status: ${jobsResponse['success']}');
      print('DEBUG: Profile response status: ${profileResponse['status']}');
      print('DEBUG: Summary response status: ${summaryResponse['status']}');

      if (jobsResponse['success'] == true &&
          profileResponse['status'] == 'success' &&
          summaryResponse['status'] == 'success') {
        final List<dynamic> jobs = jobsResponse['data'] ?? [];
        print('DEBUG: Fetched ${jobs.length} jobs');
        final enrichedJobs = await Future.wait(
          jobs.map((job) async {
            try {
              job['image'] = _normalizeImagePath(job['image']);
              print('DEBUG: Normalized job image for job ${job['id']}: ${job['image']}');
              final clientId = job['created_by']?.toString();
              print('DEBUG: Fetching client data for ID: $clientId');
              if (clientId != null && clientId.isNotEmpty) {
                final clientResponse = await retry(
                  () => ApiService.get('/api/users/$clientId'),
                  maxAttempts: 2,
                  delayFactor: const Duration(seconds: 1),
                );
                print('DEBUG: Client response status: ${clientResponse['status']}');
                String? clientUuid;
                if (clientResponse['status'] == 'success' && clientResponse['data'] != null) {
                  job['client_name'] = clientResponse['data']['name'] ?? 'Usuario $clientId';
                  job['client_rating'] = clientResponse['data']['rating']?.toDouble() ?? 0.0;
                  clientUuid = clientResponse['data']['uid'];
                  print('DEBUG: Client name: ${job['client_name']}, Rating: ${job['client_rating']}, UUID: $clientUuid');
                  String? profilePhoto = clientResponse['data']['profile_photo'] ??
                      clientResponse['data']['profile_image'];
                  print('DEBUG: Profile photo from /api/users: $profilePhoto');
                  if (profilePhoto != null && profilePhoto.isNotEmpty) {
                    job['client_profile_photo'] = _normalizeImagePath(profilePhoto, isProfilePhoto: true);
                    print('DEBUG: Set client profile photo from /api/users: ${job['client_profile_photo']}');
                  }
                } else {
                  job['client_name'] = 'Usuario $clientId';
                  job['client_rating'] = 0.0;
                  print('DEBUG: Fallback client data: name=${job['client_name']}, rating=0.0');
                }
                if (clientUuid != null && clientUuid.isNotEmpty && (job['client_profile_photo'] == null || job['client_profile_photo'].isEmpty)) {
                  try {
                    final photoResponse = await retry(
                      () => ApiService.get('/api/client-profile-photo/$clientUuid'),
                      maxAttempts: 2,
                      delayFactor: const Duration(seconds: 2),
                    );
                    print('DEBUG: Photo response status for UUID $clientUuid: ${photoResponse['status']}');
                    if (photoResponse['status'] == 'success' && photoResponse['data']?['profile_photo_url'] != null) {
                      job['client_profile_photo'] = _normalizeImagePath(
                        photoResponse['data']['profile_photo_url'],
                        isProfilePhoto: true,
                      );
                      print('DEBUG: Set client profile photo from /api/client-profile-photo: ${job['client_profile_photo']}');
                    } else {
                      job['client_profile_photo'] = '';
                      print('DEBUG: No profile photo available from /api/client-profile-photo: ${photoResponse['message'] ?? 'No photo'}');
                    }
                  } catch (e) {
                    job['client_profile_photo'] = '';
                    print('ERROR: Failed to fetch profile photo for UUID $clientUuid: $e');
                  }
                } else if (job['client_profile_photo'] == null) {
                  job['client_profile_photo'] = '';
                  print('DEBUG: No UUID or profile photo available for client ID $clientId');
                }
              } else {
                job['client_name'] = 'Usuario Desconocido';
                job['client_rating'] = 0.0;
                job['client_profile_photo'] = '';
                print('WARNING: Missing client ID for job ${job['id']}');
              }
            } catch (e) {
              print('ERROR: Failed to enrich job ${job['id']}: $e');
              job['client_name'] = 'Usuario ${job['created_by'] ?? 'Desconocido'}';
              job['client_rating'] = 0.0;
              job['client_profile_photo'] = '';
            }
            print('DEBUG: Enriched job ${job['id']}: ${job['client_name']}, ${job['client_rating']}, ${job['client_profile_photo']}');
            return job;
          }).toList(),
        );

        final workerProfile = profileResponse['data'];
        workerProfile['profile_photo'] = _normalizeImagePath(workerProfile['profile_photo'], isProfilePhoto: true);

        emit(
          JobsLoaded(
            enrichedJobs,
            workerProfile: workerProfile,
            contractSummary: summaryResponse['data'],
          ),
        );
        print('DEBUG: Emitted JobsLoaded with ${enrichedJobs.length} jobs');
      } else {
        emit(const JobsError('Failed to fetch home data'));
        print('ERROR: Failed to fetch home data');
      }
    } catch (e) {
      emit(JobsError('Failed to fetch home data: $e'));
      print('ERROR: Failed to fetch home data: $e');
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
      print('DEBUG: Jobs response status: ${response['success']}');
      if (response['success'] == true) {
        final List<dynamic> jobs = response['data'] ?? [];
        print('DEBUG: Fetched ${jobs.length} jobs');
        final enrichedJobs = await Future.wait(
          jobs.map((job) async {
            try {
              job['image'] = _normalizeImagePath(job['image']);
              print('DEBUG: Normalized job image for job ${job['id']}: ${job['image']}');
              final clientId = job['created_by']?.toString();
              print('DEBUG: Fetching client data for ID: $clientId');
              if (clientId != null && clientId.isNotEmpty) {
                final clientResponse = await retry(
                  () => ApiService.get('/api/users/$clientId'),
                  maxAttempts: 2,
                  delayFactor: const Duration(seconds: 1),
                );
                print('DEBUG: Client response status: ${clientResponse['status']}');
                String? clientUuid;
                if (clientResponse['status'] == 'success' && clientResponse['data'] != null) {
                  job['client_name'] = clientResponse['data']['name'] ?? 'Usuario $clientId';
                  job['client_rating'] = clientResponse['data']['rating']?.toDouble() ?? 0.0;
                  clientUuid = clientResponse['data']['uid'];
                  print('DEBUG: Client name: ${job['client_name']}, Rating: ${job['client_rating']}, UUID: $clientUuid');
                  String? profilePhoto = clientResponse['data']['profile_photo'] ??
                      clientResponse['data']['profile_image'];
                  print('DEBUG: Profile photo from /api/users: $profilePhoto');
                  if (profilePhoto != null && profilePhoto.isNotEmpty) {
                    job['client_profile_photo'] = _normalizeImagePath(profilePhoto, isProfilePhoto: true);
                    print('DEBUG: Set client profile photo from /api/users: ${job['client_profile_photo']}');
                  }
                } else {
                  job['client_name'] = 'Usuario $clientId';
                  job['client_rating'] = 0.0;
                  print('DEBUG: Fallback client data: name=${job['client_name']}, rating=0.0');
                }
                if (clientUuid != null && clientUuid.isNotEmpty && (job['client_profile_photo'] == null || job['client_profile_photo'].isEmpty)) {
                  try {
                    final photoResponse = await retry(
                      () => ApiService.get('/api/client-profile-photo/$clientUuid'),
                      maxAttempts: 2,
                      delayFactor: const Duration(seconds: 2),
                    );
                    print('DEBUG: Photo response status for UUID $clientUuid: ${photoResponse['status']}');
                    if (photoResponse['status'] == 'success' && photoResponse['data']?['profile_photo_url'] != null) {
                      job['client_profile_photo'] = _normalizeImagePath(
                        photoResponse['data']['profile_photo_url'],
                        isProfilePhoto: true,
                      );
                      print('DEBUG: Set client profile photo from /api/client-profile-photo: ${job['client_profile_photo']}');
                    } else {
                      job['client_profile_photo'] = '';
                      print('DEBUG: No profile photo available from /api/client-profile-photo: ${photoResponse['message'] ?? 'No photo'}');
                    }
                  } catch (e) {
                    job['client_profile_photo'] = '';
                    print('ERROR: Failed to fetch profile photo for UUID $clientUuid: $e');
                  }
                } else if (job['client_profile_photo'] == null) {
                  job['client_profile_photo'] = '';
                  print('DEBUG: No UUID or profile photo available for client ID $clientId');
                }
              } else {
                job['client_name'] = 'Usuario Desconocido';
                job['client_rating'] = 0.0;
                job['client_profile_photo'] = '';
                print('WARNING: Missing client ID for job ${job['id']}');
              }
            } catch (e) {
              print('ERROR: Failed to enrich job ${job['id']}: $e');
              job['client_name'] = 'Usuario ${job['created_by'] ?? 'Desconocido'}';
              job['client_rating'] = 0.0;
              job['client_profile_photo'] = '';
            }
            print('DEBUG: Enriched job ${job['id']}: ${job['client_name']}, ${job['client_rating']}, ${job['client_profile_photo']}');
            return job;
          }).toList(),
        );
        emit(
          JobsLoaded(
            enrichedJobs,
            workerProfile: state is JobsLoaded ? (state as JobsLoaded).workerProfile : null,
            contractSummary: state is JobsLoaded ? (state as JobsLoaded).contractSummary : null,
          ),
        );
        print('DEBUG: Emitted JobsLoaded with ${enrichedJobs.length} jobs');
      } else {
        emit(JobsError(response['message'] ?? 'Failed to fetch jobs'));
        print('ERROR: Failed to fetch jobs: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      emit(JobsError('Failed to fetch jobs: $e'));
      print('ERROR: Failed to fetch jobs: $e');
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
      print('DEBUG: Worker profile response: ${response['status']}');
      if (response['status'] == 'success' && response['data'] != null) {
        final workerProfile = response['data'];
        workerProfile['profile_photo'] = _normalizeImagePath(workerProfile['profile_photo'], isProfilePhoto: true);
        emit(
          JobsLoaded(
            state is JobsLoaded ? (state as JobsLoaded).jobs : [],
            workerProfile: workerProfile,
            contractSummary: state is JobsLoaded ? (state as JobsLoaded).contractSummary : null,
          ),
        );
        print('DEBUG: Emitted JobsLoaded with worker profile');
      } else {
        emit(JobsError(response['message'] ?? 'Failed to fetch worker profile'));
        print('ERROR: Failed to fetch worker profile: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      emit(JobsError('Failed to fetch worker profile: $e'));
      print('ERROR: Failed to fetch worker profile: $e');
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
      print('DEBUG: Contract summary response: ${response['status']}');
      if (response['status'] == 'success' && response['data'] != null) {
        emit(
          JobsLoaded(
            state is JobsLoaded ? (state as JobsLoaded).jobs : [],
            workerProfile: state is JobsLoaded ? (state as JobsLoaded).workerProfile : null,
            contractSummary: response['data'],
          ),
        );
        print('DEBUG: Emitted JobsLoaded with contract summary');
      } else {
        emit(JobsError(response['message'] ?? 'Failed to fetch contract summary'));
        print('ERROR: Failed to fetch contract summary: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      emit(JobsError('Failed to fetch contract summary: $e'));
      print('ERROR: Failed to fetch contract summary: $e');
    }
  }
}