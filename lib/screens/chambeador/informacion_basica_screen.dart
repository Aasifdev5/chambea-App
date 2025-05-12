import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/profile_photo_upload_screen.dart'; // Import the new screen

class InformacionBasicaScreen extends StatefulWidget {
  @override
  _InformacionBasicaScreenState createState() =>
      _InformacionBasicaScreenState();
}

class _InformacionBasicaScreenState extends State<InformacionBasicaScreen> {
  // State variables for form fields
  String _name = '';
  String _lastName = '';
  String _profession = 'Electricista';
  String _birthDate = '';
  String _phone = '';
  String _email = '';
  String _gender = 'Masculino';
  String _address = '';
  String? _profilePhotoPath; // To store the path of the uploaded photo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Cambios aplicados')));
              Navigator.pop(context);
            },
            child: Text(
              'Aplicar',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  // Navigate to the photo upload screen and get the result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePhotoUploadScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _profilePhotoPath = result;
                    });
                  }
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                          _profilePhotoPath != null
                              ? AssetImage(
                                _profilePhotoPath!,
                              ) // Placeholder for now
                              : null,
                      child:
                          _profilePhotoPath == null
                              ? Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre*',
                hintText: 'Nombres',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Apellidos*',
                hintText: 'Apellidos',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _lastName = value;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _profession.isEmpty ? null : _profession,
              decoration: InputDecoration(
                labelText: 'Profesión',
                hintText: 'Selecciona tu profesión',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  ['Electricista', 'Plomero', 'Carpintero']
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
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Fecha de nacimiento*',
                hintText: 'Fecha de Nacimiento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _birthDate = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Número telefónico*',
                hintText: 'Número Telefónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _phone = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Correo electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender.isEmpty ? null : _gender,
              decoration: InputDecoration(
                labelText: 'Género',
                hintText: 'Seleccionar género',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  ['Masculino', 'Femenino', 'Otro']
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
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Dirección de domicilio',
                hintText: 'Ciudad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _address = value;
                });
              },
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
                // Validate and navigate to the next screen
                if (_name.isNotEmpty &&
                    _lastName.isNotEmpty &&
                    _birthDate.isNotEmpty &&
                    _phone.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Datos guardados, avanzando al siguiente paso',
                      ),
                    ),
                  );
                  // Placeholder for next screen navigation
                  // Replace with actual navigation
                  Navigator.pushNamed(context, '/next_screen');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Por favor completa todos los campos requeridos',
                      ),
                    ),
                  );
                }
              },
              child: Text(
                'Siguiente',
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
