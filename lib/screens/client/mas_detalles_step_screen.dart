import 'package:flutter/material.dart';
import 'package:chambea/models/service_request.dart';
import 'package:chambea/screens/client/bandeja_screen.dart';
import 'package:chambea/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class MasDetallesStepScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;

  const MasDetallesStepScreen({required this.serviceRequest});

  @override
  _MasDetallesStepScreenState createState() => _MasDetallesStepScreenState();
}

class _MasDetallesStepScreenState extends State<MasDetallesStepScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentMethod;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.serviceRequest.paymentMethod;
    if (widget.serviceRequest.description != null) {
      _descriptionController.text = widget.serviceRequest.description!;
    }
    if (widget.serviceRequest.budget != null) {
      _budgetController.text = widget.serviceRequest.budget!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitServiceRequest() async {
    if (_formKey.currentState!.validate()) {
      widget.serviceRequest.description = _descriptionController.text;
      widget.serviceRequest.budget = _budgetController.text;
      widget.serviceRequest.paymentMethod = _selectedPaymentMethod;

      if (!widget.serviceRequest.isStep3Complete()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor complete todos los campos requeridos'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          widget.serviceRequest.createdBy = int.tryParse(user.uid) ?? 0;
        } else {
          throw Exception('User not authenticated');
        }

        Map<String, dynamic> response;
        if (_selectedImage != null) {
          response = await ApiService.uploadFileWithFields(
            '/api/service-requests',
            'image',
            _selectedImage!,
            widget.serviceRequest.toJson(),
          );
        } else {
          response = await ApiService.post(
            '/api/service-requests',
            widget.serviceRequest.toJson(),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada con éxito')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BandejaScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar la solicitud: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.black54, size: 16),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Av. Benavides 4887',
              style: TextStyle(
                color: Colors.black54,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: const Color(0xFF22c55e),
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Más detalles',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          '[*] Campo obligatorio',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepCircle(Icons.check, isCompleted: true),
                        _buildStepLine(),
                        _buildStepCircle(Icons.check, isCompleted: true),
                        _buildStepLine(),
                        _buildStepCircle('03', isCompleted: false),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Paso 1',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        Text(
                          'Paso 2',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        Text(
                          'Paso 3',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Suba una imagen para indicar el tipo de servicio que requiere (Opcional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Ayuda de la persona que asignarás la tarea a comprender lo que se debe hacer.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: screenHeight * 0.15,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Center(child: Icon(Icons.add, size: 40))
                            : null,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Sugiere tu presupuesto*',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Siempre puedes negociar el precio final mediante el chat.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _budgetController,
                      decoration: InputDecoration(
                        labelText: 'Introducir el presupuesto *',
                        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: screenWidth * 0.035),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor introduzca un presupuesto';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Método de pago *',
                        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _selectedPaymentMethod,
                      items: ['Efectivo', 'Código QR'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPaymentMethod = value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione un método de pago';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitServiceRequest,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Enviar Solicitud',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22c55e),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(dynamic content, {required bool isCompleted}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return CircleAvatar(
      radius: 20,
      backgroundColor: isCompleted
          ? const Color(0xFF22c55e)
          : Colors.grey.shade300,
      child: content is IconData
          ? Icon(content, color: Colors.white, size: 20)
          : Text(
              content,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
            ),
    );
  }

  Widget _buildStepLine() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}
