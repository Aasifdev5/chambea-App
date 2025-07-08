import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_event.dart';
import 'package:chambea/blocs/chambeador/chambeador_state.dart';
import 'package:chambea/screens/chambeador/profile_photo_upload_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

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

  String _profession = 'Plomero';
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
        print('No auth token available'); // Debug
        return;
      }
      final url = Uri.parse('https://chambea.lat/api/categories');
      print('Request URL: $url'); // Debug
      print('Request Headers: ${headers.keys.join(", ")}'); // Debug
      final response = await http.get(url, headers: headers);
      print('Categories API Response: ${response.body}'); // Debug
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _categories = data
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _isLoadingCategories = false;
          if (_categories.isNotEmpty && _selectedCategoryId == null) {
            _selectedCategoryId = _categories[0]['id'].toString();
            _selectedCategoryName = _categories[0]['name'];
          }
        });
        print('Fetched categories: $_categories'); // Debug
        if (_selectedCategoryId != null) {
          _fetchSubcategories(_selectedCategoryId!);
        }
      } else {
        setState(() {
          _isLoadingCategories = false;
          _categoryError =
              'Error al cargar categorías: Código ${response.statusCode}';
        });
        print('Error fetching categories: ${response.statusCode}'); // Debug
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
        _categoryError = 'Error al cargar categorías: $e';
      });
      print('Exception fetching categories: $e'); // Debug
    }
  }

  Future<void> _fetchSubcategories(String categoryId) async {
    if (categoryId.isEmpty) {
      setState(() {
        _isLoadingSubcategories = false;
        _subcategoryError = 'ID de categoría inválido';
      });
      print('Invalid categoryId: $categoryId'); // Debug
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
        print('No auth token available for subcategories'); // Debug
        return;
      }
      final url = Uri.parse(
        'https://chambea.lat/api/subcategories/$categoryId',
      );
      print('Request URL: $url'); // Debug
      print('Request Headers: ${headers.keys.join(", ")}'); // Debug
      final response = await http.get(url, headers: headers);
      print('Subcategories API Response: ${response.body}'); // Debug
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> subcategories = responseData['data'] ?? [];
          setState(() {
            _availableSubcategories = List<String>.from(subcategories);
            _subcategories = {
              for (var sub in _availableSubcategories)
                sub: _subcategories[sub] ?? false,
            };
            _isLoadingSubcategories = false;
            if (subcategories.isEmpty) {
              _subcategoryError =
                  responseData['message'] ?? 'No se encontraron subcategorías';
            }
          });
          print(
            'Fetched subcategories for category $categoryId: $_availableSubcategories',
          ); // Debug
        } else {
          setState(() {
            _isLoadingSubcategories = false;
            _subcategoryError =
                'No se pudieron cargar las subcategorías: ${responseData['message'] ?? 'Error desconocido'}';
          });
          print(
            'Error in subcategory response: ${responseData['message']}',
          ); // Debug
        }
      } else {
        setState(() {
          _isLoadingSubcategories = false;
          _subcategoryError =
              'Error del servidor al cargar subcategorías (Código: ${response.statusCode})';
        });
        print('Error fetching subcategories: ${response.statusCode}'); // Debug
      }
    } catch (e) {
      setState(() {
        _isLoadingSubcategories = false;
        _subcategoryError = 'Error al cargar subcategorías: $e';
      });
      print('Exception fetching subcategories: $e'); // Debug
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
        print('Listener received state: $state'); // Debug
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (!state.isLoading && _isInitialLoad) {
          if (_nameController.text.isEmpty)
            _nameController.text = state.name ?? '';
          if (_lastNameController.text.isEmpty)
            _lastNameController.text = state.lastName ?? '';
          if (_birthDateController.text.isEmpty)
            _birthDateController.text = state.birthDate ?? '';
          if (_phoneController.text.isEmpty)
            _phoneController.text = state.phone ?? '';
          if (_emailController.text.isEmpty)
            _emailController.text = state.email ?? '';
          if (_addressController.text.isEmpty)
            _addressController.text = state.address ?? '';
          if (_aboutMeController.text.isEmpty)
            _aboutMeController.text = state.aboutMe ?? '';
          setState(() {
            _profession = state.profession.isNotEmpty
                ? state.profession
                : 'Plomero';
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
            _isInitialLoad = false;
          });
          if (state.name == null && state.lastName == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, completa tu perfil')),
            );
          }
          print(
            'Updated controllers: name=${_nameController.text}, profession=$_profession, category=$_selectedCategoryName, subcategories=$_subcategories, skills=$_skills',
          ); // Debug
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
                  Navigator.pushReplacementNamed(context, '/home');
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
                    final subcategoriesList = _subcategories.keys
                        .where((key) => _subcategories[key]!)
                        .toList();
                    print(
                      'Applying changes with subcategories: $subcategoriesList, skills: $_skills',
                    ); // Debug
                    context.read<ChambeadorBloc>().add(
                      UpdateProfileEvent(
                        name: _nameController.text,
                        lastName: _lastNameController.text,
                        profession: _profession,
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
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cambios aplicados')),
                    );
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    print('Form validation failed or no skills added'); // Debug
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
                              print(
                                'Navigating to ProfilePhotoUploadScreen',
                              ); // Debug
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfilePhotoUploadScreen(),
                                ),
                              );
                              if (result != null) {
                                print(
                                  'Uploading profile photo: $result',
                                ); // Debug
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
                        DropdownButtonFormField<String>(
                          value: _profession,
                          decoration: InputDecoration(
                            labelText: 'Profesión',
                            hintText: 'Selecciona tu profesión',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['Electricista', 'Plomero', 'Carpintero']
                              .map(
                                (profession) => DropdownMenuItem(
                                  value: profession,
                                  child: Text(profession),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _profession = value!;
                              print(
                                'Selected profession: $_profession',
                              ); // Debug
                            });
                          },
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
                              print('Selected gender: $_gender'); // Debug
                            });
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Dirección de domicilio',
                            hintText: 'Ciudad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
                                              ); // Debug
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
                          children: _skills
                              .asMap()
                              .entries
                              .map(
                                (entry) => Chip(
                                  label: Text(entry.value),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _skills.removeAt(entry.key);
                                      print(
                                        'Removed skill from UI: ${entry.value}',
                                      ); // Debug
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Categorías de Servicio*',
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
                              _subcategories.clear();
                              _availableSubcategories.clear();
                              print(
                                'Selected category: $_selectedCategoryName (ID: $_selectedCategoryId)',
                              ); // Debug
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
                                          'Updated subcategory in UI: ${entry.key} to $value',
                                        ); // Debug
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
                                    ))) {
                              final subcategoriesList = _subcategories.keys
                                  .where((key) => _subcategories[key]!)
                                  .toList();
                              print(
                                'Saving profile with subcategories: $subcategoriesList, skills: $_skills',
                              ); // Debug
                              context.read<ChambeadorBloc>().add(
                                UpdateProfileEvent(
                                  name: _nameController.text,
                                  lastName: _lastNameController.text,
                                  profession: _profession,
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
                              ); // Debug
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
