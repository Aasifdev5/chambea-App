import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CalculoCertificadoScreen extends StatefulWidget {
  @override
  _CalculoCertificadoScreenState createState() =>
      _CalculoCertificadoScreenState();
}

class _CalculoCertificadoScreenState extends State<CalculoCertificadoScreen> {
  String _idNumber = '';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Número de cédula de identidad*',
                hintText: 'Número',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _idNumber = value;
                });
              },
            ),
            SizedBox(height: 16),

            // FRONT IMAGE
            Text(
              'Cédula de identidad (PARTE FRONTAL)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child:
                    _frontImage != null
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
                        : Icon(Icons.badge, color: Colors.grey, size: 50),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _pickImage(true),
                child: Text(
                  _frontImage != null ? 'Añadir' : 'Añadir',
                  style: TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 16),

            // BACK IMAGE
            Text(
              'Cédula de identidad (PARTE TRASERA)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child:
                    _backImage != null
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
                        : Icon(Icons.badge, color: Colors.grey, size: 50),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _pickImage(false),
                child: Text(
                  _backImage != null ? 'Añadir' : 'Añadir',
                  style: TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),
            ),

            SizedBox(height: 20),

            // APPLY BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_idNumber.isEmpty ||
                    _frontImage == null ||
                    _backImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Por favor, completa todos los campos requeridos',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Datos aplicados')));
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Aplicar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            SizedBox(height: 10),
            Center(
              child: Text(
                'Si tienes preguntas, por favor, contacte servicio de asistencia',
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
