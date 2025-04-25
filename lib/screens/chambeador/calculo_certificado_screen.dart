import 'package:flutter/material.dart';

class CalculoCertificadoScreen extends StatefulWidget {
  @override
  _CalculoCertificadoScreenState createState() =>
      _CalculoCertificadoScreenState();
}

class _CalculoCertificadoScreenState extends State<CalculoCertificadoScreen> {
  // State variables for form fields
  String _idNumber = '';
  bool _isFrontImageUploaded = false;
  bool _isBackImageUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed:
              () => Navigator.pop(context), // Navigate back to previous screen
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
                    _isFrontImageUploaded
                        ? Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50,
                        )
                        : Icon(Icons.upload_file, color: Colors.grey, size: 50),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // Simulate image upload for front side
                  setState(() {
                    _isFrontImageUploaded = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Imagen frontal subida')),
                  );
                },
                child: Text(
                  _isFrontImageUploaded ? 'Reemplazar' : 'Añadir',
                  style: TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 16),
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
                    _isBackImageUploaded
                        ? Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50,
                        )
                        : Icon(Icons.upload_file, color: Colors.grey, size: 50),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // Simulate image upload for back side
                  setState(() {
                    _isBackImageUploaded = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Imagen trasera subida')),
                  );
                },
                child: Text(
                  _isBackImageUploaded ? 'Reemplazar' : 'Añadir',
                  style: TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Validate and apply changes
                if (_idNumber.isEmpty ||
                    !_isFrontImageUploaded ||
                    !_isBackImageUploaded) {
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
                  Navigator.pop(context); // Navigate back to previous screen
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
                'Si tienes preguntas, por favor, contacta el servicio de asistencia',
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
