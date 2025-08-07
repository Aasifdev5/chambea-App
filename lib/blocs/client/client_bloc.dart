import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:chambea/services/api_service.dart';
import 'client_event.dart';
import 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  ClientBloc() : super(ClientState()) {
    on<FetchClientProfileEvent>(_onFetchProfile);
    on<UpdateClientProfileEvent>(_onUpdateProfile);
    on<UploadClientProfilePhotoEvent>(_onUploadProfilePhoto);
  }

  Future<void> _onFetchProfile(
    FetchClientProfileEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.get('/api/profile');
      if (response['status'] == 'success') {
        final data = response['data'];
        // Strip /storage from profile_photo if present
        final profilePhoto = (data['profile_photo'] ?? '').replaceFirst('storage/', '');
        emit(
          state.copyWith(
            name: data['name'] ?? '',
            lastName: data['last_name'] ?? '',
            birthDate: data['birth_date'] ?? '',
            phone: data['phone'] ?? '',
            location: data['location'] ?? '',
            profilePhotoPath: profilePhoto.isNotEmpty ? profilePhoto : null,
            isLoading: false,
            error: null,
            wasUpdated: false,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateClientProfileEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final body = {
        'name': event.name,
        'last_name': event.lastName,
        'birth_date': event.birthDate,
        'phone': event.phone,
        'location': event.location,
      };
      final response = await ApiService.post('/api/profile', body);
      if (response['status'] == 'success') {
        emit(
          state.copyWith(
            name: event.name,
            lastName: event.lastName,
            birthDate: event.birthDate,
            phone: event.phone,
            location: event.location,
            isLoading: false,
            error: null,
            wasUpdated: true,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUploadProfilePhoto(
    UploadClientProfilePhotoEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.uploadFile(
        '/api/profile/upload-image',
        'image',
        event.image,
      );
      if (response['status'] == 'success') {
        // Strip /storage from image_path if present
        final imagePath = (response['image_path'] ?? '').replaceFirst('storage/', '');
        emit(
          state.copyWith(
            profilePhotoPath: imagePath.isNotEmpty ? imagePath : null,
            isLoading: false,
            error: null,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}