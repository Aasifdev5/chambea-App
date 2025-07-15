import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/blocs/chambeador/chambeador_event.dart';
import 'package:chambea/blocs/chambeador/chambeador_state.dart';
import 'dart:io';

class ChambeadorBloc extends Bloc<ChambeadorEvent, ChambeadorState> {
  ChambeadorBloc() : super(const ChambeadorState()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfilePhotoEvent>(_onUploadProfilePhoto);
    on<UploadCertificateEvent>(_onUploadCertificate);
    on<UploadIdentityCardEvent>(_onUploadIdentityCard);
    on<AddSubcategoryEvent>(_onAddSubcategory);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final profileResponse = await ApiService.get('/api/chambeador/profile');
      final certificateResponse = await ApiService.get(
        '/api/background-certificate',
      );
      final identityCardResponse = await ApiService.get('/api/identity-card');

      print('Profile Response: $profileResponse');
      print('Certificate Response: $certificateResponse');
      print('Identity Card Response: $identityCardResponse');

      final subcategoriesList = List<String>.from(
        profileResponse['data']['subcategories'] ?? [],
      );
      final subcategoriesMap = Map<String, bool>.fromIterable(
        subcategoriesList,
        key: (item) => item as String,
        value: (_) => true,
      );

      emit(
        state.copyWith(
          isLoading: false,
          name: profileResponse['data']['name'] ?? '',
          lastName: profileResponse['data']['last_name'] ?? '',
          profession: profileResponse['data']['profession'] ?? 'Plomero',
          birthDate: profileResponse['data']['birth_date'] ?? '',
          phone: profileResponse['data']['phone'] ?? '',
          email: profileResponse['data']['email'],
          gender: profileResponse['data']['gender'] ?? 'Masculino',
          address: profileResponse['data']['address'],
          lat: profileResponse['data']['lat']?.toDouble(),
          lng: profileResponse['data']['lng']?.toDouble(),
          aboutMe: profileResponse['data']['about_me'] ?? '',
          skills: List<String>.from(profileResponse['data']['skills'] ?? []),
          category: profileResponse['data']['category'] ?? '',
          subcategories: subcategoriesMap,
          profilePhotoPath: profileResponse['data']['profile_image'],
          certificatePath: certificateResponse['data']?['certificate_path'],
          idNumber: identityCardResponse['data']?['id_number'],
          frontImagePath: identityCardResponse['data']?['front_image'],
          backImagePath: identityCardResponse['data']?['back_image'],
        ),
      );

      print('Emitted State: ${state.copyWith(isLoading: false)}');
    } catch (e) {
      print('Error fetching profile: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Failed to fetch profile: $e'),
      );
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ChambeadorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = {
        'name': event.name,
        'last_name': event.lastName,
        'profession': event.profession,
        'birth_date': event.birthDate,
        'phone': event.phone,
        if (event.email != null) 'email': event.email,
        'gender': event.gender,
        if (event.address != null) 'address': event.address,
        if (event.lat != null) 'lat': event.lat,
        if (event.lng != null) 'lng': event.lng,
        'about_me': event.aboutMe,
        'skills': event.skills,
        'category': event.category,
        'subcategories': event.subcategories,
      };

      final response = await ApiService.post('/api/chambeador/profile', data);

      print('Update Profile Response: $response');

      if (response['status'] == 'success') {
        final updatedSubcategoriesList = List<String>.from(
          response['data']['subcategories'] ?? [],
        );
        final updatedSubcategoriesMap = Map<String, bool>.fromIterable(
          updatedSubcategoriesList,
          key: (item) => item as String,
          value: (_) => true,
        );

        emit(
          state.copyWith(
            isLoading: false,
            name: event.name,
            lastName: event.lastName,
            profession: event.profession,
            birthDate: event.birthDate,
            phone: event.phone,
            email: event.email,
            gender: event.gender,
            address: event.address,
            lat: event.lat,
            lng: event.lng,
            aboutMe: event.aboutMe,
            skills: event.skills,
            category: event.category,
            subcategories: updatedSubcategoriesMap,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error:
                response['errors']?['phone']?.join(', ') ??
                response['message'] ??
                'Error updating profile',
          ),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Failed to update profile: $e'),
      );
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
      print('Upload Photo Response: $response');
      if (response['status'] == 'success') {
        emit(
          state.copyWith(
            isLoading: false,
            profilePhotoPath: response['data']['image_path'],
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: response['message'] ?? 'Error uploading photo',
          ),
        );
      }
    } catch (e) {
      print('Error uploading photo: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Failed to upload photo: $e'),
      );
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
      print('Upload Certificate Response: $response');
      if (response['status'] == 'success') {
        emit(
          state.copyWith(
            isLoading: false,
            certificatePath: response['data']['certificate_path'],
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: response['message'] ?? 'Error uploading certificate',
          ),
        );
      }
    } catch (e) {
      print('Error uploading certificate: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to upload certificate: $e',
        ),
      );
    }
  }

  Future<void> _onUploadIdentityCard(
    UploadIdentityCardEvent event,
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
      print('Upload Identity Card Response: $response');
      if (response['status'] == 'success') {
        emit(
          state.copyWith(
            isLoading: false,
            idNumber: response['data']['id_number'],
            frontImagePath: response['data']['front_image'],
            backImagePath: response['data']['back_image'],
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: response['message'] ?? 'Error uploading identity card',
          ),
        );
      }
    } catch (e) {
      print('Error uploading identity card: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to upload identity card: $e',
        ),
      );
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
      print('Add Subcategory Response: $response');
      if (response['status'] == 'success') {
        final updatedSubcategoriesList = List<String>.from(
          response['data']['subcategories'] ?? [],
        );
        final updatedSubcategoriesMap = Map<String, bool>.fromIterable(
          updatedSubcategoriesList,
          key: (item) => item as String,
          value: (_) => true,
        );
        emit(
          state.copyWith(
            isLoading: false,
            subcategories: updatedSubcategoriesMap,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: response['message'] ?? 'Error adding subcategory',
          ),
        );
      }
    } catch (e) {
      print('Error adding subcategory: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to add subcategory: $e',
        ),
      );
    }
  }
}
