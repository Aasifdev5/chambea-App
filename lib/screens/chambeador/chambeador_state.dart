class ChambeadorState {
  final String name;
  final String lastName;
  final String profession;
  final String birthDate;
  final String phone;
  final String email;
  final String gender;
  final String address;
  final String? profilePhotoPath;
  final String aboutMe;
  final List<String> skills;
  final String category;
  final Map<String, bool> subcategories;
  final String? certificatePath;
  final String idNumber;
  final bool isLoading;
  final String? error;

  ChambeadorState({
    this.name = '',
    this.lastName = '',
    this.profession = '',
    this.birthDate = '',
    this.phone = '',
    this.email = '',
    this.gender = '',
    this.address = '',
    this.profilePhotoPath,
    this.aboutMe = '',
    this.skills = const [],
    this.category = '',
    this.subcategories = const {},
    this.certificatePath,
    this.idNumber = '',
    this.isLoading = false,
    this.error,
  });

  ChambeadorState copyWith({
    String? name,
    String? lastName,
    String? profession,
    String? birthDate,
    String? phone,
    String? email,
    String? gender,
    String? address,
    String? profilePhotoPath,
    String? aboutMe,
    List<String>? skills,
    String? category,
    Map<String, bool>? subcategories,
    String? certificatePath,
    String? idNumber,
    bool? isLoading,
    String? error,
  }) {
    return ChambeadorState(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      profession: profession ?? this.profession,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      aboutMe: aboutMe ?? this.aboutMe,
      skills: skills ?? this.skills,
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
      certificatePath: certificatePath ?? this.certificatePath,
      idNumber: idNumber ?? this.idNumber,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
