import 'package:flutter/material.dart';
import 'package:chambea/models/service_request.dart';
import 'package:chambea/screens/client/bandeja_screen.dart';

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

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if data exists
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
                fontSize: screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
                fontSize: screenWidth * 0.035, // Smaller font (Medium: 0.038)
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
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
                        fontSize:
                            screenWidth * 0.045, // Smaller font (Medium: 0.05)
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      '[*] Campo obligatorio',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize:
                            screenWidth * 0.03, // Smaller font (Medium: 0.032)
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
                        fontSize:
                            screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      ),
                    ),
                    Text(
                      'Paso 2',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                        fontSize:
                            screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      ),
                    ),
                    Text(
                      'Paso 3',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize:
                            screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Suba una imagen para indicar el tipo de servicio que requiere (Opcional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Ayuda de la persona que asignarás la tarea a comprender lo que se debe hacer.',
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  height: screenHeight * 0.15,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Icon(Icons.add, size: 40)),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción (Opcional)',
                    labelStyle: TextStyle(
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Sugiere tu presupuesto*',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Siempre puedes negociar el precio final mediante el chat.',
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: _budgetController,
                  decoration: InputDecoration(
                    labelText: 'Introducir el presupuesto *',
                    labelStyle: TextStyle(
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
                  ),
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
                    labelStyle: TextStyle(
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _selectedPaymentMethod,
                  items:
                      ['Efectivo', 'Código QR'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize:
                                  screenWidth *
                                  0.035, // Smaller font (Medium: 0.038)
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedPaymentMethod = value),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.serviceRequest.description =
                            _descriptionController.text;
                        widget.serviceRequest.budget = _budgetController.text;
                        widget.serviceRequest.paymentMethod =
                            _selectedPaymentMethod;
                        if (widget.serviceRequest.isStep3Complete()) {
                          // Submit the service request (e.g., to a backend API)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Solicitud enviada con éxito'),
                            ),
                          );
                          // Navigate to BandejaScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BandejaScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor complete todos los campos requeridos',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'Enviar Solicitud',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
    );
  }

  Widget _buildStepCircle(dynamic content, {required bool isCompleted}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return CircleAvatar(
      radius: 20,
      backgroundColor:
          isCompleted ? const Color(0xFF22c55e) : Colors.grey.shade300,
      child:
          content is IconData
              ? Icon(content, color: Colors.white, size: 20)
              : Text(
                content,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
