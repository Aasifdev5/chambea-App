import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  File? _imageFile;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  String? _imageUrl;
  String _profileEndpoint = '/api/profile';
  String _imageUploadEndpoint = '/api/profile/upload-image';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndFetchProfile();
    });
  }

  Future<void> _checkAuthAndFetchProfile() async {
    if (!mounted) return; // Prevent async operations if widget is disposed
    if (!await ApiService.isLoggedIn()) {
      print('DEBUG: No authenticated user found');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor inicia sesión para continuar'),
          ),
        );
      }
      return;
    }
    print(
      'DEBUG: Authenticated user: ${FirebaseAuth.instance.currentUser?.uid}',
    );
    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.get(_profileEndpoint);
      print('DEBUG: Fetch profile response: $response');

      // Validate response structure
      if (response['statusCode'] == 200 &&
          response['body']['status'] == 'success') {
        final data = response['body']['data'];
        if (mounted) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _lastNameController.text = data['last_name'] ?? '';
            _birthDateController.text = data['birth_date'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _locationController.text = data['location'] ?? '';
            _imageUrl = data['profile_image'];
            if (data['account_type'] == 'Chambeador') {
              _profileEndpoint = '/api/chambeador/profile';
              _imageUploadEndpoint = '/api/chambeador/profile/upload-image';
              print(
                'DEBUG: User is Chambeador, switching to $_profileEndpoint',
              );
            } else {
              print('DEBUG: User is Client, using $_profileEndpoint');
            }
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Unexpected response status: ${response['status']}');
      }
    } catch (e) {
      print('DEBUG: Fetch profile error: $e');
      if (mounted) {
        if (e.toString().contains('Profile not found')) {
          print('DEBUG: Profile not found, assuming new user');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar el perfil: $e')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      print('DEBUG: Image selected: ${pickedFile.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Imagen seleccionada. Puedes subirla ahora o más tarde.',
          ),
        ),
      );
    } else {
      print('DEBUG: No image selected');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      print('DEBUG: No image to upload');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay imagen para subir')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      print('DEBUG: Uploading image to $_imageUploadEndpoint');
      final response = await ApiService.uploadImage(
        _imageUploadEndpoint,
        _imageFile!,
      );
      print('DEBUG: Image upload response: $response');
      if (response['statusCode'] == 200 &&
          response['body']['status'] == 'success') {
        if (mounted) {
          setState(() {
            _imageUrl = response['body']['image_path'];
            _imageFile = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen subida con éxito')),
          );
          print('DEBUG: Image uploaded successfully, URL: $_imageUrl');
        }
      } else {
        throw Exception(
          response['body']['message'] ?? 'Error al subir la imagen',
        );
      }
    } catch (e) {
      print('DEBUG: Image upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    if (!await ApiService.isLoggedIn()) {
      print('DEBUG: No authenticated user found in _saveProfile');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor inicia sesión para continuar'),
          ),
        );
      }
      return;
    }

    final profileData = {
      'name': _nameController.text,
      'last_name': _lastNameController.text,
      'birth_date': _birthDateController.text,
      'phone': _phoneController.text,
      'location': _locationController.text,
    };
    print('DEBUG: Sending profile data to $_profileEndpoint: $profileData');

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await (_profileEndpoint == '/api/chambeador/profile'
          ? ApiService.put(_profileEndpoint, profileData)
          : ApiService.post(_profileEndpoint, profileData));
      print('DEBUG: Profile update response: $response');

      if (response['statusCode'] == 200 &&
          response['body']['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado con éxito')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
          );
        }
      } else {
        throw Exception(
          response['body']['message'] ?? 'Error al actualizar el perfil',
        );
      }
    } catch (e) {
      print('DEBUG: Profile update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Configuración de Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : _imageUrl != null && _imageUrl!.isNotEmpty
                                ? NetworkImage(_imageUrl!)
                                : null,
                            child:
                                _imageFile == null &&
                                    (_imageUrl == null || _imageUrl!.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 50,
                                  )
                                : null,
                          ),
                        ),
                        if (_imageFile != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_imageFile != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton(
                          onPressed: _uploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Subir Imagen'),
                        ),
                      ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nombre',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        hintText: 'Apellido',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthDateController,
                      decoration: const InputDecoration(
                        hintText: 'Fecha de nacimiento (dd/mm/yyyy)',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su fecha de nacimiento';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                          return 'Formato de fecha inválido (dd/mm/yyyy)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        hintText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su número de teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'Ubicación',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su ubicación';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Guardar Perfil',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
