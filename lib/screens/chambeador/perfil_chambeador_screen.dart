import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_event.dart';
import 'package:chambea/blocs/chambeador/chambeador_state.dart';
import 'package:chambea/screens/chambeador/profile_photo_upload_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

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
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _skillController = TextEditingController();
  final _customSubcategoryController = TextEditingController();

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
      'Initializing PerfilChambeadorScreen, fetching profile and categories',
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
        print('No auth token available');
        return;
      }
      final url = Uri.parse('https://chambea.lat/api/categories');
      print('Request URL: $url');
      print('Request Headers: ${headers.keys.join(", ")}');
      final response = await http.get(url, headers: headers);
      print('Categories API Response: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(responseData['data']);
            _isLoadingCategories = false;
            if (_categories.isNotEmpty && _selectedCategoryId == null) {
              _selectedCategoryId = _categories[0]['id'].toString();
              _selectedCategoryName = _categories[0]['name'];
              _fetchSubcategories(_selectedCategoryId!);
            }
          });
          print('Fetched categories: $_categories');
        } else {
          setState(() {
            _isLoadingCategories = false;
            _categoryError =
                responseData['message'] ?? 'Error al cargar categorías';
          });
          print('Error in category response: ${responseData['message']}');
        }
      } else {
        setState(() {
          _isLoadingCategories = false;
          _categoryError =
              'Error al cargar categorías: Código ${response.statusCode}';
        });
        print('Error fetching categories: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
        _categoryError = 'Error al cargar categorías: $e';
      });
      print('Exception fetching categories: $e');
    }
  }

  Future<void> _fetchSubcategories(String categoryId) async {
    if (categoryId.isEmpty) {
      setState(() {
        _isLoadingSubcategories = false;
        _subcategoryError = 'ID de categoría inválido';
      });
      print('Invalid categoryId: $categoryId');
      return;
    }
    setState(() {
      _isLoadingSubcategories = true;
      _subcategoryError = null;
      if (_selectedCategoryName != 'Otros') {
        _customSubcategoryController.clear();
      }
    });
    try {
      final headers = await _getAuthToken();
      if (headers == null) {
        setState(() {
          _isLoadingSubcategories = false;
          _subcategoryError = 'No se pudo autenticar al usuario';
        });
        print('No auth token available for subcategories');
        return;
      }
      final url = Uri.parse(
        'https://chambea.lat/api/subcategories/$categoryId',
      );
      print('Request URL: $url');
      print('Request Headers: ${headers.keys.join(", ")}');
      final response = await http.get(url, headers: headers);
      print('Subcategories API Response: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> subcategories = responseData['data'] ?? [];
          final state = context.read<ChambeadorBloc>().state;
          setState(() {
            _availableSubcategories = List<String>.from(subcategories);
            // Preserve checked subcategories from state if they exist in new list
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
            'Fetched subcategories for category $categoryId: $_availableSubcategories',
          );
        } else {
          setState(() {
            _isLoadingSubcategories = false;
            _subcategoryError =
                responseData['message'] ?? 'Error al cargar subcategorías';
          });
          print('Error in subcategory response: ${responseData['message']}');
        }
      } else {
        setState(() {
          _isLoadingSubcategories = false;
          _subcategoryError =
              'Error del servidor al cargar subcategorías (Código: ${response.statusCode})';
        });
        print('Error fetching subcategories: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingSubcategories = false;
        _subcategoryError = 'Error al cargar subcategorías: $e';
      });
      print('Exception fetching subcategories: $e');
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _addressController.text = result['address'];
        _lat = result['lat'];
        _lng = result['lng'];
        print(
          'Selected location: address=${_addressController.text}, lat=$_lat, lng=$_lng',
        );
      });
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
    _customSubcategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ChambeadorBloc, ChambeadorState>(
      listener: (context, state) {
        print('Listener received state: $state');
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
          if (_phoneController.text.isEmpty)
            _phoneController.text = state.phone;
          if (_emailController.text.isEmpty)
            _emailController.text = state.email ?? '';
          if (_addressController.text.isEmpty)
            _addressController.text = state.address ?? '';
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
            if (_selectedCategoryName == 'Otros' &&
                state.subcategories.isNotEmpty) {
              _customSubcategoryController.text =
                  state.subcategories.keys.firstOrNull ?? '';
            }
            _lat = state.lat;
            _lng = state.lng;
            _isInitialLoad = false;
          });
          if (state.name.isEmpty && state.lastName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, completa tu perfil')),
            );
          }
          print(
            'Updated controllers: name=${_nameController.text}, category=$_selectedCategoryName, subcategories=$_subcategories, skills=$_skills, lat=$_lat, lng=$_lng',
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
                  if (_formKey.currentState!.validate() && _skills.isNotEmpty) {
                    final subcategoriesList = _selectedCategoryName == 'Otros'
                        ? [_customSubcategoryController.text.trim()]
                        : _subcategories.keys
                              .where((key) => _subcategories[key]!)
                              .toList();
                    if (_selectedCategoryName == 'Otros' &&
                        _customSubcategoryController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, ingrese una subcategoría personalizada para Otros',
                          ),
                        ),
                      );
                      return;
                    }
                    if (_selectedCategoryName != 'Otros' &&
                        subcategoriesList.isEmpty &&
                        _availableSubcategories.isNotEmpty) {
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
                      'Applying changes with subcategories: $subcategoriesList, skills: $_skills, lat: $_lat, lng: $_lng',
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
                    print('Form validation failed or no skills added');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor, completa todos los campos requeridos y añade al menos una habilidad',
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
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              print('Navigating to ProfilePhotoUploadScreen');
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfilePhotoUploadScreen(),
                                ),
                              );
                              if (result != null) {
                                print('Uploading profile photo: $result');
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
                                      ? NetworkImage(state.profilePhotoPath!)
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
                          decoration: InputDecoration(
                            labelText: 'Fecha de nacimiento*',
                            hintText: 'dd/mm/yyyy',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            try {
                              final parts = value.split('/');
                              if (parts.length != 3) return 'Formato inválido';
                              final day = int.parse(parts[0]);
                              final month = int.parse(parts[1]);
                              final year = int.parse(parts[2]);
                              final date = DateTime(year, month, day);
                              if (date.year != year ||
                                  date.month != month ||
                                  date.day != day) {
                                return 'Fecha inválida';
                              }
                              _birthDateController.text =
                                  '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
                              return null;
                            } catch (e) {
                              return 'Formato inválido';
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Número telefónico*',
                            hintText: '+1234567890',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(value)) {
                              return 'Formato inválido (debe ser + seguido de 1-14 dígitos)';
                            }
                            return null;
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
                              print('Selected gender: $_gender');
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
                                                'Added skill to UI: ${_skillController.text}',
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
                                    'Removed skill from UI: ${entry.value}',
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
                              // Do not clear _subcategories to preserve checked state
                              _availableSubcategories.clear();
                              _customSubcategoryController.clear();
                              print(
                                'Selected category: $_selectedCategoryName (ID: $_selectedCategoryId)',
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
                        _selectedCategoryName == 'Otros'
                            ? TextFormField(
                                controller: _customSubcategoryController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Ingrese una subcategoría personalizada',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Por favor, ingrese una subcategoría'
                                    : null,
                              )
                            : _availableSubcategories.isEmpty &&
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
                                          'Updated subcategory in UI: ${entry.key} to $value',
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
                                (_selectedCategoryName == 'Otros'
                                    ? _customSubcategoryController.text
                                          .trim()
                                          .isNotEmpty
                                    : _availableSubcategories.isEmpty ||
                                          _subcategories.values.any(
                                            (selected) => selected,
                                          ))) {
                              final subcategoriesList =
                                  _selectedCategoryName == 'Otros'
                                  ? [_customSubcategoryController.text.trim()]
                                  : _subcategories.keys
                                        .where((key) => _subcategories[key]!)
                                        .toList();
                              print(
                                'Saving profile with subcategories: $subcategoriesList, skills: $_skills, lat: $_lat, lng: $_lng',
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
                              Navigator.pushNamed(context, '/antecedentes');
                            } else {
                              print(
                                'Form validation failed, no skills, or no subcategories selected',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, completa todos los campos requeridos, añade al menos una habilidad y selecciona al menos una subcategoría si están disponibles',
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
  const MapPickerScreen({super.key});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(
    -12.046374,
    -77.042793,
  ); // Default: Lima, Peru
  String _address = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                List<Placemark> placemarks = await placemarkFromCoordinates(
                  _selectedLocation.latitude,
                  _selectedLocation.longitude,
                );
                if (placemarks.isNotEmpty) {
                  Placemark placemark = placemarks.first;
                  _address =
                      '${placemark.street}, ${placemark.locality}, ${placemark.country}';
                } else {
                  _address = 'Ubicación desconocida';
                }
                Navigator.pop(context, {
                  'address': _address,
                  'lat': _selectedLocation.latitude,
                  'lng': _selectedLocation.longitude,
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al obtener la dirección: $e')),
                );
              }
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
            _mapController?.animateCamera(CameraUpdate.newLatLng(location));
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId('selected-location'),
            position: _selectedLocation,
          ),
        },
      ),
    );
  }
}
