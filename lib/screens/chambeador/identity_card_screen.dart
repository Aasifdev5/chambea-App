import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chambea/screens/chambeador/antecedentes_screen.dart';
import 'package:chambea/blocs/chambeador/chambeador_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_event.dart';
import 'package:chambea/blocs/chambeador/chambeador_state.dart';

class IdentityCardScreen extends StatefulWidget {
  const IdentityCardScreen({super.key});

  @override
  _IdentityCardScreenState createState() => _IdentityCardScreenState();
}

class _IdentityCardScreenState extends State<IdentityCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _backImage = File(pickedFile.path);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFront ? 'Imagen frontal subida' : 'Imagen trasera subida',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ChambeadorBloc>().add(FetchProfileEvent());
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ChambeadorBloc, ChambeadorState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (!state.isLoading && state.idNumber != null) {
          _idNumberController.text = state.idNumber!;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Cédula de identidad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: state.isLoading
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
                        TextFormField(
                          controller: _idNumberController,
                          decoration: InputDecoration(
                            labelText: 'Número de cédula de identidad*',
                            hintText: 'Número',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Cédula de identidad (PARTE FRONTAL)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          height: screenHeight * 0.2,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: _frontImage != null
                                ? Stack(
                                    children: [
                                      Image.file(
                                        _frontImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : state.frontImagePath != null
                                ? Image.network(
                                    state.frontImagePath!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                  )
                                : const Icon(
                                    Icons.badge,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Center(
                          child: TextButton(
                            onPressed: () => _pickImage(true),
                            child: Text(
                              _frontImage != null ||
                                      state.frontImagePath != null
                                  ? 'Cambiar'
                                  : 'Añadir',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Cédula de identidad (PARTE TRASERA)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          height: screenHeight * 0.2,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: _backImage != null
                                ? Stack(
                                    children: [
                                      Image.file(
                                        _backImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : state.backImagePath != null
                                ? Image.network(
                                    state.backImagePath!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                  )
                                : const Icon(
                                    Icons.badge,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Center(
                          child: TextButton(
                            onPressed: () => _pickImage(false),
                            child: Text(
                              _backImage != null || state.backImagePath != null
                                  ? 'Cambiar'
                                  : 'Añadir',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ),
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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Check if images are provided locally or already uploaded
                              final hasLocalImages =
                                  _frontImage != null && _backImage != null;
                              final hasUploadedImages =
                                  state.frontImagePath != null &&
                                  state.backImagePath != null &&
                                  _idNumberController.text.isNotEmpty;

                              if (hasLocalImages || hasUploadedImages) {
                                if (hasLocalImages) {
                                  // Dispatch upload event if new images are provided
                                  context.read<ChambeadorBloc>().add(
                                    UploadIdentityCardEvent(
                                      idNumber: _idNumberController.text,
                                      frontImage: _frontImage!,
                                      backImage: _backImage!,
                                    ),
                                  );
                                  // Wait briefly to ensure the upload event is processed
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                }
                                // Navigate to AntecedentesScreen
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Cédula de identidad guardada',
                                      ),
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AntecedentesScreen(),
                                    ),
                                  );
                                }
                              } else {
                                // Show specific error messages
                                String errorMessage =
                                    'Por favor, completa los siguientes campos:';
                                if (_idNumberController.text.isEmpty) {
                                  errorMessage += '\n- Número de cédula';
                                }
                                if (_frontImage == null &&
                                    state.frontImagePath == null) {
                                  errorMessage += '\n- Imagen frontal';
                                }
                                if (_backImage == null &&
                                    state.backImagePath == null) {
                                  errorMessage += '\n- Imagen trasera';
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              }
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
