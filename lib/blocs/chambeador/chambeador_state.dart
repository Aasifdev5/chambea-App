import 'package:equatable/equatable.dart';

class ChambeadorState extends Equatable {
  final bool isLoading;
  final String? error;
  final String name;
  final String lastName;
  final String profession;
  final String birthDate;
  final String phone;
  final String? email; // Made nullable
  final String gender;
  final String? address; // Made nullable
  final String aboutMe;
  final List<String> skills;
  final String category;
  final Map<String, bool> subcategories;
  final String? profilePhotoPath;
  final String? certificatePath;
  final String? idNumber;
  final String? frontImagePath;
  final String? backImagePath;

  const ChambeadorState({
    this.isLoading = false,
    this.error,
    this.name = '',
    this.lastName = '',
    this.profession = 'Plomero',
    this.birthDate = '',
    this.phone = '',
    this.email, // Nullable
    this.gender = 'Masculino',
    this.address, // Nullable
    this.aboutMe = '',
    this.skills = const [],
    this.category = '',
    this.subcategories = const {},
    this.profilePhotoPath,
    this.certificatePath,
    this.idNumber,
    this.frontImagePath,
    this.backImagePath,
  });

  ChambeadorState copyWith({
    bool? isLoading,
    String? error,
    String? name,
    String? lastName,
    String? profession,
    String? birthDate,
    String? phone,
    String? email,
    String? gender,
    String? address,
    String? aboutMe,
    List<String>? skills,
    String? category,
    Map<String, bool>? subcategories,
    String? profilePhotoPath,
    String? certificatePath,
    String? idNumber,
    String? frontImagePath,
    String? backImagePath,
  }) {
    return ChambeadorState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      profession: profession ?? this.profession,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      aboutMe: aboutMe ?? this.aboutMe,
      skills: skills ?? this.skills,
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      certificatePath: certificatePath ?? this.certificatePath,
      idNumber: idNumber ?? this.idNumber,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
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
    profilePhotoPath,
    certificatePath,
    idNumber,
    frontImagePath,
    backImagePath,
  ];
}
