import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_event.dart';
import 'package:chambea/blocs/chambeador/chambeador_state.dart';
import 'package:chambea/screens/chambeador/profile_photo_upload_screen.dart';
import 'package:chambea/screens/chambeador/identity_card_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class PerfilChambeadorScreen extends StatefulWidget {
  const PerfilChambeadorScreen({super.key});

  @override
  _PerfilChambeadorScreenState createState() => _PerfilChambeadorScreenState();
}

class _PerfilChambeadorScreenState extends State<PerfilChambeadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController(text: '+591 ');
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _skillController = TextEditingController();

  String _gender = 'Masculino';
  String? _selectedCategoryId;
  String _selectedCategoryName = '';
  Map<String, bool> _subcategories = {};
  List<Map<String, dynamic>> _categories = [];
  List<String> _availableSubcategories = [];
  List<String> _skills = [];
  bool _isLoadingCategories = true;
  bool _isLoadingSubcategories = false;
  String? _categoryError;
  String? _subcategoryError;
  bool _isInitialLoad = true;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    print(
      '[PerfilChambeadorScreen] Initializing, fetching profile and categories',
    );
    context.read<ChambeadorBloc>().add(FetchProfileEvent());
    _fetchCategories();
  }

  Future<Map<String, String>?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      return {'Authorization': 'Bearer $token'};
    }
    print('[PerfilChambeadorScreen] No auth token available');
    return null;
  }

  Future<void> _fetchCategories() async {
    try {
      final headers = await _getAuthToken();
      if (headers == null) {
        setState(() {
          _isLoadingCategories = false;
          _categoryError = 'No se pudo autenticar al usuario';
        });
        return;
      }
      final url = Uri.parse('https://chambea.lat/api/categories');
      print('[PerfilChambeadorScreen] Request URL: $url');
      final response = await http.get(url, headers: headers);
      print(
        '[PerfilChambeadorScreen] Categories API Response: ${response.body}',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(
              responseData['data'],
            ).where((category) => category['name'] != 'Otros').toList();
            _isLoadingCategories = false;
            if (_categories.isNotEmpty && _selectedCategoryId == null) {
              _selectedCategoryId = _categories[0]['id'].toString();
              _selectedCategoryName = _categories[0]['name'];
              _fetchSubcategories(_selectedCategoryId!);
            }
          });
          print('[PerfilChambeadorScreen] Fetched categories: $_categories');
        } else {
          setState(() {
            _isLoadingCategories = false;
            _categoryError =
                responseData['message'] ?? 'Error al cargar categorías';
          });
          print(
            '[PerfilChambeadorScreen] Error in category response: ${responseData['message']}',
          );
        }
      } else {
        setState(() {
          _isLoadingCategories = false;
          _categoryError =
              'Error al cargar categorías: Código ${response.statusCode}';
        });
        print(
          '[PerfilChambeadorScreen] Error fetching categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
        _categoryError = 'Error al cargar categorías: $e';
      });
      print('[PerfilChambeadorScreen] Exception fetching categories: $e');
    }
  }

  Future<void> _fetchSubcategories(String categoryId) async {
    if (categoryId.isEmpty) {
      setState(() {
        _isLoadingSubcategories = false;
        _subcategoryError = 'ID de categoría inválido';
      });
      print('[PerfilChambeadorScreen] Invalid categoryId: $categoryId');
      return;
    }
    setState(() {
      _isLoadingSubcategories = true;
      _subcategoryError = null;
    });
    try {
      final headers = await _getAuthToken();
      if (headers == null) {
        setState(() {
          _isLoadingSubcategories = false;
          _subcategoryError = 'No se pudo autenticar al usuario';
        });
        return;
      }
      final url = Uri.parse(
        'https://chambea.lat/api/subcategories/$categoryId',
      );
      print('[PerfilChambeadorScreen] Request URL: $url');
      final response = await http.get(url, headers: headers);
      print(
        '[PerfilChambeadorScreen] Subcategories API Response: ${response.body}',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> subcategories = responseData['data'] ?? [];
          final state = context.read<ChambeadorBloc>().state;
          setState(() {
            _availableSubcategories = List<String>.from(subcategories);
            _subcategories = {
              for (var sub in _availableSubcategories)
                sub: state.subcategories[sub] ?? _subcategories[sub] ?? false,
            };
            _isLoadingSubcategories = false;
            if (subcategories.isEmpty) {
              _subcategoryError =
                  responseData['message'] ?? 'No se encontraron subcategorías';
            }
          });
          print(
            '[PerfilChambeadorScreen] Fetched subcategories for category $categoryId: $_availableSubcategories',
          );
        } else {
          setState(() {
            _isLoadingSubcategories = false;
            _subcategoryError =
                responseData['message'] ?? 'Error al cargar subcategorías';
          });
          print(
            '[PerfilChambeadorScreen] Error in subcategory response: ${responseData['message']}',
          );
        }
      } else {
        setState(() {
          _isLoadingSubcategories = false;
          _subcategoryError =
              'Error del servidor al cargar subcategorías (Código: ${response.statusCode})';
        });
        print(
          '[PerfilChambeadorScreen] Error fetching subcategories: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingSubcategories = false;
        _subcategoryError = 'Error al cargar subcategorías: $e';
      });
      print('[PerfilChambeadorScreen] Exception fetching subcategories: $e');
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapPickerScreen(initialLat: _lat, initialLng: _lng),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _addressController.text = result['address'] ?? '';
        _lat = result['lat'];
        _lng = result['lng'];
        print(
          '[PerfilChambeadorScreen] Selected location: address=${_addressController.text}, lat=$_lat, lng=$_lng',
        );
      });
    }
  }

  Future<void> _updateAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String newAddress =
            '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}';
        newAddress = newAddress.trim().isEmpty
            ? 'Ubicación desconocida'
            : newAddress.trim();
        setState(() {
          _addressController.text = newAddress;
          print(
            '[PerfilChambeadorScreen] Address updated from coordinates: $newAddress',
          );
        });
      }
    } catch (e) {
      print(
        '[PerfilChambeadorScreen] Error updating address from coordinates: $e',
      );
    }
  }

  Future<void> _selectBirthDate() async {
    print('[PerfilChambeadorScreen] Birth date field tapped');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDateController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(_birthDateController.text)
          : DateTime.now().subtract(
              const Duration(days: 7300),
            ), // ~20 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'), // Set Spanish locale
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _birthDateController.text = formattedDate;
      });
      print('[PerfilChambeadorScreen] Selected birth date: $formattedDate');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _aboutMeController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ChambeadorBloc, ChambeadorState>(
      listener: (context, state) {
        print('[PerfilChambeadorScreen] Listener received state: $state');
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (!state.isLoading && _isInitialLoad) {
          if (_nameController.text.isEmpty) _nameController.text = state.name;
          if (_lastNameController.text.isEmpty)
            _lastNameController.text = state.lastName;
          if (_birthDateController.text.isEmpty)
            _birthDateController.text = state.birthDate;
          if (_phoneController.text == '+591 ' && state.phone.isNotEmpty) {
            _phoneController.text = state.phone;
          }
          if (_emailController.text.isEmpty)
            _emailController.text = state.email ?? '';
          if (_aboutMeController.text.isEmpty)
            _aboutMeController.text = state.aboutMe;
          setState(() {
            _gender = state.gender.isNotEmpty ? state.gender : 'Masculino';
            _skills = state.skills.isNotEmpty ? List.from(state.skills) : [];
            if (state.category.isNotEmpty &&
                _categories.any((c) => c['name'] == state.category)) {
              _selectedCategoryId = _categories
                  .firstWhere((c) => c['name'] == state.category)['id']
                  .toString();
              _selectedCategoryName = state.category;
              if (_availableSubcategories.isEmpty) {
                _fetchSubcategories(_selectedCategoryId!);
              }
            }
            _subcategories = {
              for (var sub in _availableSubcategories)
                sub: state.subcategories[sub] ?? false,
            };
            _lat = state.lat;
            _lng = state.lng;
            if (state.lat != null &&
                state.lng != null &&
                _addressController.text.isEmpty) {
              _updateAddressFromCoordinates(state.lat!, state.lng!);
            } else {
              _addressController.text = state.address ?? '';
            }
            _isInitialLoad = false;
          });
          if (state.name.isEmpty && state.lastName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, completa tu perfil')),
            );
          }
          print(
            '[PerfilChambeadorScreen] Updated controllers: name=${_nameController.text}, category=$_selectedCategoryName, subcategories=$_subcategories, skills=$_skills, lat=$_lat, lng=$_lng, address=${_addressController.text}',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamed(context, '/home');
                }
              },
            ),
            title: const Text(
              'Perfil Chambeador',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _skills.isNotEmpty &&
                      state.profilePhotoPath != null &&
                      state.profilePhotoPath!.isNotEmpty) {
                    final subcategoriesList = _subcategories.keys
                        .where((key) => _subcategories[key]!)
                        .toList();
                    if (_availableSubcategories.isNotEmpty &&
                        subcategoriesList.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, selecciona al menos una subcategoría',
                          ),
                        ),
                      );
                      return;
                    }
                    print(
                      '[PerfilChambeadorScreen] Applying changes with subcategories: $subcategoriesList, skills: $_skills, lat: $_lat, lng: $_lng',
                    );
                    context.read<ChambeadorBloc>().add(
                      UpdateProfileEvent(
                        name: _nameController.text,
                        lastName: _lastNameController.text,
                        profession: _selectedCategoryName,
                        birthDate: _birthDateController.text,
                        phone: _phoneController.text,
                        email: _emailController.text.isNotEmpty
                            ? _emailController.text
                            : null,
                        gender: _gender,
                        address: _addressController.text.isNotEmpty
                            ? _addressController.text
                            : null,
                        aboutMe: _aboutMeController.text,
                        skills: _skills,
                        category: _selectedCategoryName,
                        subcategories: subcategoriesList,
                        lat: _lat,
                        lng: _lng,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cambios aplicados')),
                    );
                    Navigator.pushNamed(context, '/home');
                  } else {
                    print(
                      '[PerfilChambeadorScreen] Form validation failed, no skills, no profile photo, or no subcategories',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Por favor, completa todos los campos requeridos, añade al menos una habilidad${_availableSubcategories.isNotEmpty ? ", selecciona al menos una subcategoría" : ""}${state.profilePhotoPath == null || state.profilePhotoPath!.isEmpty ? ", y sube una foto de perfil" : ""}',
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Aplicar',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
            ],
          ),
          body:
              state.isLoading || _isLoadingCategories || _isLoadingSubcategories
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_categoryError != null)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: screenHeight * 0.02,
                            ),
                            child: Text(
                              _categoryError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (_subcategoryError != null)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: screenHeight * 0.02,
                            ),
                            child: Text(
                              _subcategoryError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (state.profilePhotoPath == null ||
                            state.profilePhotoPath!.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: screenHeight * 0.02,
                            ),
                            child: const Text(
                              'Debe subir una foto de perfil',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              print(
                                '[PerfilChambeadorScreen] Navigating to ProfilePhotoUploadScreen',
                              );
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfilePhotoUploadScreen(),
                                ),
                              );
                              if (result != null) {
                                print(
                                  '[PerfilChambeadorScreen] Uploading profile photo: $result',
                                );
                                context.read<ChambeadorBloc>().add(
                                  UploadProfilePhotoEvent(image: result),
                                );
                              }
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: screenWidth * 0.13,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage:
                                      state.profilePhotoPath != null
                                      ? NetworkImage(
                                          '${state.profilePhotoPath!}',
                                        )
                                      : null,
                                  onBackgroundImageError:
                                      state.profilePhotoPath != null
                                      ? (exception, stackTrace) {
                                          print(
                                            '[PerfilChambeadorScreen] Error loading profile image: $exception',
                                          );
                                        }
                                      : null,
                                  child: state.profilePhotoPath == null
                                      ? Icon(
                                          Icons.person,
                                          size: screenWidth * 0.13,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.04,
                                    backgroundColor: Colors.green,
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: screenWidth * 0.04,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre*',
                            hintText: 'Nombres',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Este campo es requerido' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Apellidos*',
                            hintText: 'Apellidos',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Este campo es requerido' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _birthDateController,
                          readOnly: true,
                          onTap: _selectBirthDate,
                          decoration: InputDecoration(
                            labelText: 'Fecha de nacimiento*',
                            hintText: 'dd/mm/yyyy',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            try {
                              final date = DateFormat(
                                'dd/MM/yyyy',
                              ).parse(value);
                              if (date.isAfter(DateTime.now())) {
                                return 'La fecha no puede ser en el futuro';
                              }
                              return null;
                            } catch (e) {
                              return 'Formato inválido (dd/mm/yyyy)';
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Número telefónico*',
                            hintText: '+591 12345678',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: Text(
                                '+591',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty || value == '+591 ') {
                              return 'Este campo es requerido';
                            }
                            if (!RegExp(r'^\+591\s?\d{8}$').hasMatch(value)) {
                              return 'El número debe tener 8 dígitos después de +591';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (!value.startsWith('+591 ')) {
                              _phoneController.text = '+591 ';
                              _phoneController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _phoneController.text.length,
                                    ),
                                  );
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Correo electrónico',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isNotEmpty &&
                                !RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                              return 'Correo electrónico inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: InputDecoration(
                            labelText: 'Género',
                            hintText: 'Seleccionar género',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['Masculino', 'Femenino', 'Otro']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _gender = value!;
                              print(
                                '[PerfilChambeadorScreen] Selected gender: $_gender',
                              );
                            });
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton.icon(
                          onPressed: _pickLocation,
                          icon: const Icon(Icons.map),
                          label: const Text('Seleccionar ubicación en el mapa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Dirección de domicilio*',
                            hintText: 'Ciudad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Este campo es requerido' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Sobre mi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _aboutMeController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                'Describe tu experiencia y habilidades...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Este campo es requerido' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Habilidades*',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Añadir Habilidad'),
                                    content: TextField(
                                      controller: _skillController,
                                      decoration: const InputDecoration(
                                        hintText: 'Ingresa una habilidad',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (_skillController
                                              .text
                                              .isNotEmpty) {
                                            setState(() {
                                              _skills.add(
                                                _skillController.text,
                                              );
                                              print(
                                                '[PerfilChambeadorScreen] Added skill to UI: ${_skillController.text}',
                                              );
                                              _skillController.clear();
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Añadir'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                'Añadir',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_skills.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: screenHeight * 0.01,
                            ),
                            child: const Text(
                              'Debe añadir al menos una habilidad',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          children: _skills.asMap().entries.map((entry) {
                            return Chip(
                              label: Text(entry.value),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _skills.removeAt(entry.key);
                                  print(
                                    '[PerfilChambeadorScreen] Removed skill from UI: ${entry.value}',
                                  );
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Categoría de Servicio*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            hintText: 'Selecciona una categoría',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category['id'].toString(),
                                  child: Text(category['name']),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value!;
                              _selectedCategoryName = _categories.firstWhere(
                                (c) => c['id'].toString() == value,
                              )['name'];
                              _availableSubcategories.clear();
                              print(
                                '[PerfilChambeadorScreen] Selected category: $_selectedCategoryName (ID: $_selectedCategoryId)',
                              );
                              _fetchSubcategories(_selectedCategoryId!);
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Este campo es requerido' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Subcategorías*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        _availableSubcategories.isEmpty &&
                                _subcategoryError == null
                            ? const Text(
                                'No hay subcategorías disponibles',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              )
                            : Column(
                                children: _subcategories.entries.map((entry) {
                                  return CheckboxListTile(
                                    title: Text(entry.key),
                                    value: entry.value,
                                    onChanged: (value) {
                                      setState(() {
                                        _subcategories[entry.key] = value!;
                                        print(
                                          '[PerfilChambeadorScreen] Updated subcategory in UI: ${entry.key} to $value',
                                        );
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  );
                                }).toList(),
                              ),
                        SizedBox(height: screenHeight * 0.03),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                _skills.isNotEmpty &&
                                (_availableSubcategories.isEmpty ||
                                    _subcategories.values.any(
                                      (selected) => selected,
                                    )) &&
                                state.profilePhotoPath != null &&
                                state.profilePhotoPath!.isNotEmpty) {
                              final subcategoriesList = _subcategories.keys
                                  .where((key) => _subcategories[key]!)
                                  .toList();
                              print(
                                '[PerfilChambeadorScreen] Saving profile with subcategories: $subcategoriesList, skills: $_skills, lat: $_lat, lng: $_lng',
                              );
                              context.read<ChambeadorBloc>().add(
                                UpdateProfileEvent(
                                  name: _nameController.text,
                                  lastName: _lastNameController.text,
                                  profession: _selectedCategoryName,
                                  birthDate: _birthDateController.text,
                                  phone: _phoneController.text,
                                  email: _emailController.text.isNotEmpty
                                      ? _emailController.text
                                      : null,
                                  gender: _gender,
                                  address: _addressController.text.isNotEmpty
                                      ? _addressController.text
                                      : null,
                                  aboutMe: _aboutMeController.text,
                                  skills: _skills,
                                  category: _selectedCategoryName,
                                  subcategories: subcategoriesList,
                                  lat: _lat,
                                  lng: _lng,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Datos guardados, avanzando al siguiente paso',
                                  ),
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const IdentityCardScreen(),
                                ),
                              );
                            } else {
                              print(
                                '[PerfilChambeadorScreen] Form validation failed, no skills, no subcategories, or no profile photo',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Por favor, completa todos los campos requeridos, añade al menos una habilidad${_availableSubcategories.isNotEmpty ? ", selecciona al menos una subcategoría" : ""}${state.profilePhotoPath == null || state.profilePhotoPath!.isEmpty ? ", y sube una foto de perfil" : ""}',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Siguiente',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        const Center(
                          child: Text(
                            'Si tienes preguntas, por favor, contacte servicio de asistencia',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(
    -17.9833,
    -67.15,
  ); // Oruro, Bolivia as fallback
  String _address = '';
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLat != null && widget.initialLng != null) {
      setState(() {
        _selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
        _updateMarker(_selectedLocation);
      });
      await _updateAddress(widget.initialLat!, widget.initialLng!);
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, habilita los servicios de ubicación'),
          ),
        );
        _setFallbackLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado')),
          );
          _setFallbackLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El permiso de ubicación está denegado permanentemente',
            ),
          ),
        );
        _setFallbackLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _updateMarker(_selectedLocation);
        print(
          '[MapPickerScreen] Current location: lat=${position.latitude}, lng=${position.longitude}',
        );
      });

      await _updateAddress(position.latitude, position.longitude);
      if (_mapController != null && _selectedLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_selectedLocation),
        );
      }
    } catch (e) {
      print('[MapPickerScreen] Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación: $e')),
      );
      _setFallbackLocation();
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _updateMarker(_selectedLocation);
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selectedLocation, zoom: 15.0),
        ),
      );
      await _updateAddress(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );
      print(
        '[MapPickerScreen] Moved to current location: lat=${_selectedLocation.latitude}, lng=${_selectedLocation.longitude}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener la ubicación actual')),
      );
      print('[MapPickerScreen] Error going to current location: $e');
    }
  }

  void _setFallbackLocation() {
    setState(() {
      _selectedLocation = const LatLng(-17.9833, -67.15); // Oruro, Bolivia
      _updateMarker(_selectedLocation);
      _address = 'Ubicación desconocida';
      print(
        '[MapPickerScreen] Set fallback location: lat=-17.9833, lng=-67.15',
      );
    });
    _updateAddress(-17.9833, -67.15);
  }

  Future<void> _updateAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          _address =
              '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}';
          _address = _address.trim().isEmpty
              ? 'Ubicación desconocida'
              : _address.trim();
          print('[MapPickerScreen] Address updated: $_address');
        });
      } else {
        setState(() {
          _address = 'Ubicación desconocida';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Error al obtener la dirección';
      });
      print('[MapPickerScreen] Error getting address: $e');
    }
  }

  Future<void> _updateMarker(LatLng position) async {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedLocation = newPosition;
              _updateMarker(newPosition);
              print(
                '[MapPickerScreen] Marker dragged to: lat=${newPosition.latitude}, lng=${newPosition.longitude}',
              );
            });
            _updateAddress(newPosition.latitude, newPosition.longitude);
          },
        ),
      );
      _selectedLocation = position;
    });
    await _updateAddress(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          TextButton(
            onPressed: _selectedLocation == null
                ? null
                : () {
                    Navigator.pop(context, {
                      'address': _address,
                      'lat': _selectedLocation.latitude,
                      'lng': _selectedLocation.longitude,
                    });
                  },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: _selectedLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_selectedLocation != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLng(_selectedLocation),
                      );
                    }
                  },
                  onTap: (position) {
                    setState(() {
                      _selectedLocation = position;
                      _updateMarker(position);
                      print(
                        '[MapPickerScreen] Map tapped at: lat=${position.latitude}, lng=${position.longitude}',
                      );
                    });
                  },
                  markers: _markers,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.green,
                    onPressed: _goToCurrentLocation,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}
