import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chambea/blocs/client/client_bloc.dart';
import 'package:chambea/blocs/client/client_event.dart';
import 'package:chambea/blocs/client/client_state.dart';

class ProfilePhotoUploadScreen extends StatefulWidget {
  const ProfilePhotoUploadScreen({super.key});

  @override
  _ProfilePhotoUploadScreenState createState() =>
      _ProfilePhotoUploadScreenState();
}

class _ProfilePhotoUploadScreenState extends State<ProfilePhotoUploadScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Pick image from source
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _image = File(pickedFile.path);
        });
        print('DEBUG: Image selected: ${pickedFile.path}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto seleccionada')));
      } else {
        print('DEBUG: No image selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se seleccionó ninguna foto')),
        );
      }
    } catch (e) {
      print('DEBUG: Error selecting image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al seleccionar foto: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Upload image by dispatching UploadClientProfilePhotoEvent
  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una foto primero')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      context.read<ClientBloc>().add(
        UploadClientProfilePhotoEvent(image: _image!),
      );
      print(
        'DEBUG: Dispatched UploadClientProfilePhotoEvent for image: ${_image!.path}',
      );
    } catch (e) {
      print('DEBUG: Error dispatching upload event: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir la foto: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<ClientBloc, ClientState>(
      listener: (context, state) {
        if (state.isLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al subir la foto: ${state.error}')),
            );
          } else if (state.profilePhotoPath != null &&
              state.profilePhotoPath!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imagen subida con éxito')),
            );
            // Pass result to trigger profile fetch in PerfilScreen
            Navigator.pop(context, {'refresh': true});
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Subir foto de perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: screenHeight * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _image == null
                            ? const Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.white,
                              )
                            : Image.file(_image!, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Elige cómo quieres subir tu foto:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text(
                        'Tomar una foto',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text(
                        'Seleccionar foto',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _image != null ? _uploadImage : null,
                      child: const Text(
                        'Guardar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
