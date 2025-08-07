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

class InformacionBasicaScreen extends StatefulWidget {
  const InformacionBasicaScreen({super.key});

  @override
  _InformacionBasicaScreenState createState() => _InformacionBasicaScreenState();
}

class _InformacionBasicaScreenState extends State<InformacionBasicaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _profession;
  String _gender = 'Masculino';
  List<Map<String, dynamic>> _professions = [];
  bool _isLoadingProfessions = true;
  String? _professionError;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    print(
      '[InformacionBasicaScreen] Initializing, fetching profile and categories',
    );
    context.read<ChambeadorBloc>().add(FetchProfileEvent());
    _fetchProfessions();
  }

  Future<Map<String, String>?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      return {'Authorization': 'Bearer $token'};
    }
    print('[InformacionBasicaScreen] No auth token available');
    return null;
  }

  Future<void> _fetchProfessions() async {
    try {
      final headers = await _getAuthToken();
      if (headers == null) {
        setState(() {
          _isLoadingProfessions = false;
          _professionError = 'No se pudo autenticar al usuario';
        });
        return;
      }
      final url = Uri.parse('https://chambea.lat/api/categories');
      print('[InformacionBasicaScreen] Request URL: $url');
      print(
        '[InformacionBasicaScreen] Request Headers: ${headers.keys.join(", ")}',
      );
      final response = await http.get(url, headers: headers);
      print(
        '[InformacionBasicaScreen] Categories API Response: ${response.body}',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final List<Map<String, dynamic>> fetchedProfessions =
              List<Map<String, dynamic>>.from(responseData['data'] ?? []);
          setState(() {
            _professions = fetchedProfessions;
            _isLoadingProfessions = false;
            final state = context.read<ChambeadorBloc>().state;
            if (_professions.any((p) => p['name'] == state.profession)) {
              _profession = state.profession;
            } else if (_professions.isNotEmpty) {
              _profession = _professions[0]['name'];
            } else {
              _profession = '';
              _professionError = 'No se encontraron categorías disponibles';
            }
          });
          print('[InformacionBasicaScreen] Fetched categories: $_professions');
        } else {
          setState(() {
            _isLoadingProfessions = false;
            _professionError =
                responseData['message'] ?? 'Error al cargar categorías';
          });
          print(
            '[InformacionBasicaScreen] Error in category response: ${responseData['message']}',
          );
        }
      } else {
        setState(() {
          _isLoadingProfessions = false;
          _professionError =
              'Error al cargar categorías: Código ${response.statusCode}';
        });
        print(
          '[InformacionBasicaScreen] Error fetching categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingProfessions = false;
        _professionError = 'Error al cargar categorías: $e';
      });
      print('[InformacionBasicaScreen] Exception fetching categories: $e');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ChambeadorBloc, ChambeadorState>(
      listener: (context, state) {
        print('[InformacionBasicaScreen] Listener received state: $state');
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
        if (!state.isLoading && _isInitialLoad) {
          setState(() {
            _nameController.text = state.name;
            _lastNameController.text = state.lastName;
            _birthDateController.text = state.birthDate;
            _phoneController.text = state.phone;
            _emailController.text = state.email ?? '';
            _addressController.text = state.address ?? '';
            _gender = state.gender.isNotEmpty ? state.gender : 'Masculino';
            if (_professions.any((p) => p['name'] == state.profession)) {
              _profession = state.profession;
            }
            _isInitialLoad = false;
          });
          if (state.name.isEmpty && state.lastName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, completa tu perfil')),
            );
          }
          print(
            '[InformacionBasicaScreen] Updated controllers: name=${_nameController.text}, profession=$_profession, email=${_emailController.text}, address=${_addressController.text}',
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
              'Información básica',
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
                      _profession != null &&
                      _profession!.isNotEmpty) {
                    print('[InformacionBasicaScreen] Applying changes');
                    context.read<ChambeadorBloc>().add(
                          UpdateProfileEvent(
                            name: _nameController.text,
                            lastName: _lastNameController.text,
                            profession: _profession!,
                            birthDate: _birthDateController.text,
                            phone: _phoneController.text,
                            email: _emailController.text.isNotEmpty
                                ? _emailController.text
                                : null,
                            gender: _gender,
                            address: _addressController.text.isNotEmpty
                                ? _addressController.text
                                : null,
                            aboutMe: state.aboutMe,
                            skills: state.skills,
                            category: state.category,
                            subcategories: state.subcategories.keys
                                .where((key) => state.subcategories[key]!)
                                .toList(),
                            lat: state.lat,
                            lng: state.lng,
                          ),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cambios aplicados')),
                    );
                  } else {
                    print(
                      '[InformacionBasicaScreen] Form validation failed or no valid profession selected',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor, completa todos los campos requeridos y selecciona una profesión válida',
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
          body: state.isLoading || _isLoadingProfessions
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
                        if (_professionError != null)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: screenHeight * 0.02,
                            ),
                            child: Text(
                              _professionError!,
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
                                '[InformacionBasicaScreen] Navigating to ProfilePhotoUploadScreen',
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
                                  '[InformacionBasicaScreen] Uploading profile photo: $result',
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
                                  backgroundImage: state.profilePhotoPath != null
                                      ? NetworkImage(
                                          '${state.profilePhotoPath!}')
                                      : null,
                                  onBackgroundImageError:
                                      state.profilePhotoPath != null
                                          ? (exception, stackTrace) {
                                              print(
                                                '[InformacionBasicaScreen] Error loading profile image: $exception',
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
                        DropdownButtonFormField<String>(
                          value: _profession,
                          decoration: InputDecoration(
                            labelText: 'Profesión*',
                            hintText: 'Selecciona tu profesión',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: _professions.isEmpty
                              ? [
                                  const DropdownMenuItem(
                                    value: '',
                                    enabled: false,
                                    child: Text('Cargando profesiones...'),
                                  ),
                                ]
                              : _professions
                                    .map(
                                      (profession) => DropdownMenuItem<String>(
                                        value: profession['name'],
                                        child: Text(profession['name']),
                                      ),
                                    )
                                    .toList(),
                          onChanged: _professions.isEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    _profession = value!;
                                    print(
                                      '[InformacionBasicaScreen] Selected profession: $_profession',
                                    );
                                  });
                                },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Por favor, selecciona una profesión válida'
                              : null,
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
                                (gender) => DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _gender = value!;
                              print(
                                '[InformacionBasicaScreen] Selected gender: $_gender',
                              );
                            });
                          },
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
                                _profession != null &&
                                _profession!.isNotEmpty) {
                              print('[InformacionBasicaScreen] Saving profile');
                              context.read<ChambeadorBloc>().add(
                                    UpdateProfileEvent(
                                      name: _nameController.text,
                                      lastName: _lastNameController.text,
                                      profession: _profession!,
                                      birthDate: _birthDateController.text,
                                      phone: _phoneController.text,
                                      email: _emailController.text.isNotEmpty
                                          ? _emailController.text
                                          : null,
                                      gender: _gender,
                                      address: _addressController.text.isNotEmpty
                                          ? _addressController.text
                                          : null,
                                      aboutMe: state.aboutMe,
                                      skills: state.skills,
                                      category: state.category,
                                      subcategories: state.subcategories.keys
                                          .where((key) => state.subcategories[key]!)
                                          .toList(),
                                      lat: state.lat,
                                      lng: state.lng,
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
                                '[InformacionBasicaScreen] Form validation failed or no valid profession selected',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, completa todos los campos requeridos y selecciona una profesión válida',
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