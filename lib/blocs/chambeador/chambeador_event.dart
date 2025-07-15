import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ChambeadorEvent extends Equatable {
  const ChambeadorEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ChambeadorEvent {}

class UpdateProfileEvent extends ChambeadorEvent {
  final String name;
  final String lastName;
  final String profession;
  final String birthDate;
  final String phone;
  final String? email;
  final String gender;
  final String? address;
  final String aboutMe;
  final List<String> skills;
  final String category;
  final List<String> subcategories;
  final double? lat;
  final double? lng;

  const UpdateProfileEvent({
    required this.name,
    required this.lastName,
    required this.profession,
    required this.birthDate,
    required this.phone,
    this.email,
    required this.gender,
    this.address,
    required this.aboutMe,
    required this.skills,
    required this.category,
    required this.subcategories,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [
    name,
    lastName,
    profession,
    birthDate,
    phone,
    email,
    gender,
    address,
    aboutMe,
    skills,
    category,
    subcategories,
    lat,
    lng,
  ];
}

class UploadProfilePhotoEvent extends ChambeadorEvent {
  final File image;

  const UploadProfilePhotoEvent({required this.image});

  @override
  List<Object?> get props => [image];
}

class UploadCertificateEvent extends ChambeadorEvent {
  final File certificate;

  const UploadCertificateEvent({required this.certificate});

  @override
  List<Object?> get props => [certificate];
}

class UploadIdentityCardEvent extends ChambeadorEvent {
  final String idNumber;
  final File frontImage;
  final File backImage;

  const UploadIdentityCardEvent({
    required this.idNumber,
    required this.frontImage,
    required this.backImage,
  });

  @override
  List<Object?> get props => [idNumber, frontImage, backImage];
}

class AddSubcategoryEvent extends ChambeadorEvent {
  final String subcategory;

  const AddSubcategoryEvent({required this.subcategory});

  @override
  List<Object?> get props => [subcategory];
}
