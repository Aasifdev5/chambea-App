import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ClientEvent extends Equatable {
  const ClientEvent();
  @override
  List<Object?> get props => [];
}

class FetchClientProfileEvent extends ClientEvent {}

class UpdateClientProfileEvent extends ClientEvent {
  final String name;
  final String lastName;
  final String birthDate;
  final String phone;
  final String location;

  const UpdateClientProfileEvent({
    required this.name,
    required this.lastName,
    required this.birthDate,
    required this.phone,
    required this.location,
  });

  @override
  List<Object?> get props => [name, lastName, birthDate, phone, location];
}

class UploadClientProfilePhotoEvent extends ClientEvent {
  final File image;

  const UploadClientProfilePhotoEvent({required this.image});

  @override
  List<Object?> get props => [image];
}
