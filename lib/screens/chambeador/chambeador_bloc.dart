import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../services/api_service.dart'; // Corrected import path
import 'chambeador_event.dart';
import 'chambeador_state.dart';

class ChambeadorBloc extends Bloc<ChambeadorEvent, ChambeadorState> {
  ChambeadorBloc() : super(ChambeadorState()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfilePhotoEvent>(_onUploadProfilePhoto);
    on<AddSubcategoryEvent>(_onAddSubcategory);
    on<FetchCertificateEvent>(_onFetchCertificate);
    on<UploadCertificateEvent>(_onUploadCertificate);
    on<FetchIdentityCardEvent>(_onFetchIdentityCard);
    on<UpdateIdentityCardEvent>(_onUpdateIdentityCard);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.get('/api/chambeador/profile');
      final data = response['data'];
      emit(
        state.copyWith(
          name: data['name'] ?? '',
          lastName: data['last_name'] ?? '',
          profession: data['profession'] ?? '',
          birthDate: data['birth_date'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          gender: data['gender'] ?? '',
          address: data['address'] ?? '',
          profilePhotoPath: data['profile_image'],
          aboutMe: data['about_me'] ?? '',
          skills: List<String>.from(data['skills'] ?? []),
          category: data['category'] ?? '',
          subcategories: Map<String, bool>.from(data['subcategories'] ?? {}),
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final body = {
        'name': event.name,
        'last_name': event.lastName,
        'profession': event.profession,
        'birth_date': event.birthDate,
        'phone': event.phone,
        'email': event.email,
        'gender': event.gender,
        'address': event.address,
        'about_me': event.aboutMe,
        'skills': event.skills,
        'category': event.category,
        'subcategories': event.subcategories,
      };
      final response = await ApiService.put('/api/chambeador/profile', body);
      if (response['statusCode'] == 200) {
        emit(
          state.copyWith(
            name: event.name,
            lastName: event.lastName,
            profession: event.profession,
            birthDate: event.birthDate,
            phone: event.phone,
            email: event.email,
            gender: event.gender,
            address: event.address,
            aboutMe: event.aboutMe,
            skills: event.skills,
            category: event.category,
            subcategories: event.subcategories,
            isLoading: false,
            error: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUploadProfilePhoto(
    UploadProfilePhotoEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.uploadFile(
        '/api/chambeador/profile/upload-image',
        'image',
        event.image,
      );
      if (response['statusCode'] == 200) {
        emit(
          state.copyWith(
            profilePhotoPath: response['body']['image_path'],
            isLoading: false,
            error: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddSubcategory(
    AddSubcategoryEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.post('/api/chambeador/subcategory', {
        'subcategory': event.subcategory,
      });
      if (response['statusCode'] == 200) {
        final updatedSubcategories = Map<String, bool>.from(state.subcategories)
          ..[event.subcategory] = false;
        emit(
          state.copyWith(
            subcategories: updatedSubcategories,
            isLoading: false,
            error: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onFetchCertificate(
    FetchCertificateEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.get('/api/background-certificate');
      emit(
        state.copyWith(
          certificatePath: response['data']?['certificate_path'],
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUploadCertificate(
    UploadCertificateEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.uploadFile(
        '/api/background-certificate/upload',
        'certificate',
        event.certificate,
      );
      if (response['statusCode'] == 200) {
        emit(
          state.copyWith(
            certificatePath: response['body']['certificate_path'],
            isLoading: false,
            error: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onFetchIdentityCard(
    FetchIdentityCardEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.get('/api/identity-card');
      emit(
        state.copyWith(
          idNumber: response['data']?['id_number'] ?? '',
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateIdentityCard(
    UpdateIdentityCardEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.uploadIdentityCard(
        '/api/identity-card/update',
        event.idNumber,
        event.frontImage,
        event.backImage,
      );
      if (response['statusCode'] == 200) {
        emit(
          state.copyWith(
            idNumber: event.idNumber,
            isLoading: false,
            error: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
