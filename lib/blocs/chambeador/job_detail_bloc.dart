import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/models/job.dart';
import 'job_detail_event.dart';
import 'job_detail_state.dart';
import 'dart:async';

class JobDetailBloc extends Bloc<JobDetailEvent, JobDetailState> {
  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 2);

  JobDetailBloc() : super(JobDetailInitial()) {
    on<FetchJobDetail>(_onFetchJobDetail);
  }

  Future<void> _onFetchJobDetail(
    FetchJobDetail event,
    Emitter<JobDetailState> emit,
  ) async {
    emit(JobDetailLoading());
    int attempt = 0;

    while (attempt < _maxRetries) {
      try {
        final response = await ApiService.get(
          '/api/service-requests/job/${event.requestId}',
        );
        if (response['success'] == true &&
            response['data'] is Map<String, dynamic>) {
          final job = Job.fromJson(response['data']);
          emit(JobDetailLoaded(job));
          return;
        } else if (response['status'] == 'error') {
          String errorMessage;
          switch (response['statusCode']) {
            case 429:
              errorMessage =
                  'Demasiadas solicitudes. Por favor, intenta de nuevo más tarde.';
              break;
            case 403:
              errorMessage = 'No tienes permiso para acceder a este trabajo.';
              break;
            case 404:
              errorMessage = 'El trabajo solicitado no se encontró.';
              break;
            default:
              errorMessage =
                  response['message']?.toString() ??
                  'No se pudieron cargar los detalles del trabajo.';
          }
          emit(JobDetailError(errorMessage));
          return;
        }
      } catch (e) {
        if (e.toString().contains('429')) {
          attempt++;
          if (attempt >= _maxRetries) {
            emit(
              JobDetailError(
                'Demasiadas solicitudes. Por favor, intenta de nuevo más tarde.',
              ),
            );
            return;
          }
          // Exponential backoff: delay = initialDelay * (2 ^ attempt)
          await Future.delayed(_initialDelay * (1 << attempt));
        } else {
          emit(
            JobDetailError(
              'Error al cargar los detalles del trabajo: ${e.toString()}',
            ),
          );
          return;
        }
      }
    }
  }
}
