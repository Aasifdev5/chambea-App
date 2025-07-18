class ClientState {
  final String name;
  final String lastName;
  final String birthDate;
  final String phone;
  final String location;
  final String? profilePhotoPath;
  final bool isLoading;
  final String? error;

  ClientState({
    this.name = '',
    this.lastName = '',
    this.birthDate = '',
    this.phone = '',
    this.location = '',
    this.profilePhotoPath,
    this.isLoading = false,
    this.error,
  });

  ClientState copyWith({
    String? name,
    String? lastName,
    String? birthDate,
    String? phone,
    String? location,
    String? profilePhotoPath,
    bool? isLoading,
    String? error,
  }) {
    return ClientState(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
