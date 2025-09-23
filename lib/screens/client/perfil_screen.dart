import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:chambea/blocs/client/client_bloc.dart';
import 'package:chambea/blocs/client/client_event.dart';
import 'package:chambea/blocs/client/client_state.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  DateTime? _selectedBirthDate;

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
    print(
      'DEBUG: Authenticated user: ${FirebaseAuth.instance.currentUser?.uid}',
    );
    context.read<ClientBloc>().add(FetchClientProfileEvent());
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
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

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _locationController.text = result['address'] ?? '';
        print(
          '[PerfilScreen] Selected location: address=${_locationController.text}',
        );
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    final state = context.read<ClientBloc>().state;
    if (_imageFile == null &&
        (state.profilePhotoPath == null || state.profilePhotoPath!.isEmpty)) {
      print('DEBUG: No profile image selected or uploaded');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, sube una foto de perfil')),
        );
      }
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
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

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      context.read<ClientBloc>().add(
        UpdateClientProfileEvent(
          name: _nameController.text,
          lastName: _lastNameController.text,
          birthDate: _birthDateController.text,
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        }
        if (!state.isLoading && state.name.isNotEmpty) {
          _nameController.text = state.name;
          _lastNameController.text = state.lastName;
          _phoneController.text = state.phone;
          _locationController.text = state.location;
          if (state.birthDate.isNotEmpty) {
            try {
              final parsedDate = DateFormat(
                'dd/MM/yyyy',
              ).parse(state.birthDate);
              _selectedBirthDate = parsedDate;
              _birthDateController.text = state.birthDate;
            } catch (e) {
              print('DEBUG: Error parsing birth date: $e');
            }
          }
        }
        if (!state.isLoading &&
            state.profilePhotoPath != null &&
            _imageFile != null) {
          if (mounted) {
            setState(() {
              _imageFile = null;
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
                        if (_imageFile == null &&
                            (state.profilePhotoPath == null ||
                                state.profilePhotoPath!.isEmpty))
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Debe subir una foto de perfil',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : state.profilePhotoPath != null &&
                                          state.profilePhotoPath!.isNotEmpty
                                    ? NetworkImage(
                                        'https://chambea.lat/${state.profilePhotoPath!}',
                                      )
                                    : null,
                                onBackgroundImageError:
                                    state.profilePhotoPath != null &&
                                        state.profilePhotoPath!.isNotEmpty
                                    ? (exception, stackTrace) {
                                        print(
                                          'DEBUG: Error loading profile image: $exception',
                                        );
                                      }
                                    : null,
                                child:
                                    _imageFile == null &&
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
                        GestureDetector(
                          onTap: _selectBirthDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _birthDateController,
                              enabled: false,
                              decoration: const InputDecoration(
                                hintText: 'Fecha de nacimiento (dd/mm/yyyy)',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (_selectedBirthDate == null) {
                                  return 'Por favor seleccione su fecha de nacimiento';
                                }
                                if (_selectedBirthDate!.isAfter(
                                  DateTime.now(),
                                )) {
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

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

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
    await _getCurrentLocation();
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
                    Navigator.pop(context, {'address': _address});
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
