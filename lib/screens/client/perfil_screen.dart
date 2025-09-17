import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Added for date formatting
import 'package:chambea/blocs/client/client_bloc.dart';
import 'package:chambea/blocs/client/client_event.dart';
import 'package:chambea/blocs/client/client_state.dart';
import 'package:chambea/screens/client/home.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  DateTime? _selectedBirthDate; // Added to store the selected date

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndFetchProfile();
    });
  }

  Future<void> _checkAuthAndFetchProfile() async {
    if (!mounted) return;
    if (FirebaseAuth.instance.currentUser == null) {
      print('DEBUG: No authenticated user found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor inicia sesión para continuar')),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }
    print('DEBUG: Authenticated user: ${FirebaseAuth.instance.currentUser?.uid}');
    context.read<ClientBloc>().add(FetchClientProfileEvent());
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
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
          content: Text('Imagen seleccionada. Puedes subirla ahora o más tarde.'),
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
      print('DEBUG: Uploading image to /api/profile/upload-image');
      context.read<ClientBloc>().add(
        UploadClientProfilePhotoEvent(image: _imageFile!),
      );
    } catch (e) {
      print('DEBUG: Image upload error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
      }
    }
  }

  // Added method to select birth date using calendar picker
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Customize as needed
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      print('DEBUG: No authenticated user found in _saveProfile');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor inicia sesión para continuar')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      context.read<ClientBloc>().add(
        UpdateClientProfileEvent(
          name: _nameController.text,
          lastName: _lastNameController.text,
          birthDate: _birthDateController.text, // Formatted date string
          phone: _phoneController.text,
          location: _locationController.text,
        ),
      );
    } catch (e) {
      print('DEBUG: Profile update error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil: $e')),
        );
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
    return BlocConsumer<ClientBloc, ClientState>(
      listener: (context, state) {
        if (state.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        }
        if (!state.isLoading && state.name.isNotEmpty) {
          _nameController.text = state.name;
          _lastNameController.text = state.lastName;
          _phoneController.text = state.phone;
          _locationController.text = state.location;
          // Handle birth date loading
          if (state.birthDate.isNotEmpty) {
            try {
              final parsedDate = DateFormat('dd/MM/yyyy').parse(state.birthDate);
              _selectedBirthDate = parsedDate;
              _birthDateController.text = state.birthDate;
            } catch (e) {
              print('DEBUG: Error parsing birth date: $e');
            }
          }
        }
        if (!state.isLoading && state.profilePhotoPath != null && _imageFile != null) {
          if (mounted) {
            setState(() {
              _imageFile = null; // Clear local image after successful upload
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imagen subida con éxito')),
            );
          }
        }
        if (!state.isLoading && state.name.isNotEmpty && state.wasUpdated) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil actualizado con éxito')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
            );
          }
        }
      },
      builder: (context, state) {
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
                                    : state.profilePhotoPath != null &&
                                          state.profilePhotoPath!.isNotEmpty
                                    ? NetworkImage('https://chambea.lat/${state.profilePhotoPath!}')
                                    : null,
                                onBackgroundImageError: state.profilePhotoPath != null &&
                                        state.profilePhotoPath!.isNotEmpty
                                    ? (exception, stackTrace) {
                                        print('DEBUG: Error loading profile image: $exception');
                                      }
                                    : null,
                                child: _imageFile == null &&
                                        (state.profilePhotoPath == null ||
                                            state.profilePhotoPath!.isEmpty)
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
                        // Modified birth date field with calendar picker
                        GestureDetector(
                          onTap: _selectBirthDate,
                          child: AbsorbPointer( // Makes the field read-only
                            child: TextFormField(
                              controller: _birthDateController,
                              enabled: false, // Prevents manual editing
                              decoration: const InputDecoration(
                                hintText: 'Fecha de nacimiento (dd/mm/yyyy)',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (_selectedBirthDate == null) {
                                  return 'Por favor seleccione su fecha de nacimiento';
                                }
                                if (_selectedBirthDate!.isAfter(DateTime.now())) {
                                  return 'La fecha de nacimiento no puede ser en el futuro';
                                }
                                return null;
                              },
                            ),
                          ),
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
      },
    );
  }
}