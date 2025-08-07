import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chambea/screens/chambeador/perfil_chambeador_screen.dart';
import 'package:chambea/blocs/chambeador/chambeador_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_event.dart';
import 'package:chambea/blocs/chambeador/chambeador_state.dart';

class AntecedentesScreen extends StatefulWidget {
  const AntecedentesScreen({super.key});

  @override
  _AntecedentesScreenState createState() => _AntecedentesScreenState();
}

class _AntecedentesScreenState extends State<AntecedentesScreen> {
  File? _certificate;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickCertificate() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _certificate = File(pickedFile.path);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Certificado seleccionado')));
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ChambeadorBloc>().add(FetchProfileEvent());
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
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Certificado de antecedentes',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Certificado de antecedentes penales\nOpcional',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Container(
                              height: screenHeight * 0.15,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _certificate != null
                                  ? Image.file(
                                      _certificate!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : state.certificatePath != null
                                  ? Image.network(
                                      state.certificatePath!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                    )
                                  : const Icon(
                                      Icons.description,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            OutlinedButton(
                              onPressed: _pickCertificate,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.02,
                                  ),
                                ),
                              ),
                              child: Text(
                                _certificate != null ||
                                        state.certificatePath != null
                                    ? 'Cambiar'
                                    : 'Añadir',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
      if (_certificate != null) {
        // Dispatch upload event
        context.read<ChambeadorBloc>().add(
          UploadCertificateEvent(certificate: _certificate!),
        );

        // Optional delay to ensure upload completes
        await Future.delayed(Duration(milliseconds: 500));

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificado guardado'),
          ),
        );

        // Navigate to perfil_chambeador_screen.dart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PerfilChambeadorScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona un certificado.'),
          ),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
    ),
    child: Text(
      'Siguiente',
      style: TextStyle(
        fontSize: screenWidth * 0.045,
        color: Colors.white,
      ),
    ),
  ),
),


                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Si tienes preguntas, por favor, contacte servicio de asistencia',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
