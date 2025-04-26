import 'package:flutter/material.dart';
import 'package:chambea/models/service_request.dart';

class MasDetallesStepScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;

  const MasDetallesStepScreen({required this.serviceRequest});

  @override
  _MasDetallesStepScreenState createState() => _MasDetallesStepScreenState();
}

class _MasDetallesStepScreenState extends State<MasDetallesStepScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedPaymentMethod;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  // Hardcoded categories and subcategories (can be fetched dynamically)
  final Map<String, List<String>> _subcategories = {
    'Construcción': ['Albañil', 'Plomero', 'Pintor'],
    'Hogar': ['Personal de Limpieza', 'Lavanderia', 'Chef'],
    'Gastronomía': ['Charquero', 'Chef', 'Cocinero'],
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if data exists
    _selectedCategory = widget.serviceRequest.category;
    _selectedSubcategory = widget.serviceRequest.subcategory;
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
            const SizedBox(width: 4),
            Text(
              'Av. Benavides 4887',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Más detalles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '[*] Campo obligatorio',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Paso 1',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Paso 2',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Paso 3',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Qué tipo de servicio necesitas?*',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Construcción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedCategory,
                items:
                    _subcategories.keys.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubcategory =
                        null; // Reset subcategory when category changes
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Subcategoría',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedSubcategory,
                items:
                    _selectedCategory != null
                        ? _subcategories[_selectedCategory]!.map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                        : [],
                onChanged:
                    (value) => setState(() => _selectedSubcategory = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una subcategoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Suba una imagen para indicar el tipo de servicio que requiere (Opcional).',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ayuda de la persona que asignarás la tarea a comprender lo que se debe hacer.',
              ),
              const SizedBox(height: 16),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Icon(Icons.add, size: 40)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sugiere tu presupuesto*',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Siempre puedes negociar el precio final mediante el chat.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: 'Introducir el presupuesto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduzca un presupuesto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Método de pago',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedPaymentMethod,
                items:
                    ['Efectivo', 'Código QR'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.serviceRequest.category = _selectedCategory;
                      widget.serviceRequest.subcategory = _selectedSubcategory;
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
                        Navigator.popUntil(context, (route) => route.isFirst);
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
                  child: const Text(
                    'Enviar Solicitud',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(dynamic content, {required bool isCompleted}) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: isCompleted ? Colors.green : Colors.grey.shade300,
      child:
          content is IconData
              ? Icon(content, color: Colors.white)
              : Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
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
