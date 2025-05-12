import 'package:flutter/material.dart';
import 'package:chambea/screens/client/ubicacion_step_screen.dart';
import 'package:chambea/models/service_request.dart';
import 'package:intl/intl.dart'; // For formatting the date

class SolicitarServicioScreen extends StatefulWidget {
  final String? subcategoryName; // Nullable to allow unspecified subcategory

  const SolicitarServicioScreen({Key? key, required this.subcategoryName})
    : super(key: key);

  @override
  _SolicitarServicioScreenState createState() =>
      _SolicitarServicioScreenState();
}

class _SolicitarServicioScreenState extends State<SolicitarServicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceRequest _serviceRequest = ServiceRequest();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;

  // Hardcoded categories and subcategories (can be fetched dynamically)
  final Map<String, List<String>> _subcategories = {
    'Construcción': ['Albañil', 'Plomero', 'Pintor'],
    'Hogar': ['Personal de Limpieza', 'Lavanderia', 'Chef'],
    'Gastronomía': ['Charquero', 'Chef', 'Cocinero'],
  };

  // Function to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        _serviceRequest.date = _dateController.text;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.subcategoryName != null) {
      _selectedSubcategory = widget.subcategoryName;
      _serviceRequest.subcategory = widget.subcategoryName;
      // Pre-select category based on subcategory
      _subcategories.forEach((category, subcategories) {
        if (subcategories.contains(widget.subcategoryName)) {
          _selectedCategory = category;
          _serviceRequest.category = category;
        }
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
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
        title: Text(
          'Solicitar servicio',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.045, // Smaller font (Medium: 0.05)
            fontWeight: FontWeight.bold,
          ),
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.black54,
                        size: 16,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Av. Benovides 4887',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Text(
                        'Solicitar servicio',
                        style: TextStyle(
                          fontSize:
                              screenWidth *
                              0.045, // Smaller font (Medium: 0.05)
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        '[*] Campo obligatorio',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize:
                              screenWidth *
                              0.03, // Smaller font (Medium: 0.032)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepCircle('01', isActive: true),
                      _buildStepLine(),
                      _buildStepCircle('02', isActive: false),
                      _buildStepLine(),
                      _buildStepCircle('03', isActive: false),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Paso 1',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
                        ),
                      ),
                      Text(
                        'Paso 2',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
                        ),
                      ),
                      Text(
                        'Paso 3',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (widget.subcategoryName != null &&
                      widget.subcategoryName!.isNotEmpty)
                    Text(
                      'Subcategoría: ${widget.subcategoryName}',
                      style: TextStyle(
                        fontSize:
                            screenWidth * 0.035, // Smaller font (Medium: 0.038)
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  if (widget.subcategoryName != null &&
                      widget.subcategoryName!.isNotEmpty)
                    SizedBox(height: screenHeight * 0.02),
                  // Show dropdowns only if subcategoryName is null or empty
                  if (widget.subcategoryName == null ||
                      widget.subcategoryName!.isEmpty) ...[
                    Text(
                      '¿Qué tipo de servicio necesitas?*',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            screenWidth * 0.045, // Smaller font (Medium: 0.05)
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Categoría *',
                        labelStyle: TextStyle(
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _selectedCategory,
                      items:
                          _subcategories.keys.map((String value) {
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
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _selectedSubcategory = null; // Reset subcategory
                          _serviceRequest.category = value;
                          _serviceRequest.subcategory = null;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una categoría';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Subcategoría *',
                        labelStyle: TextStyle(
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
                        ),
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
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize:
                                          screenWidth *
                                          0.035, // Smaller font (Medium: 0.038)
                                    ),
                                  ),
                                );
                              }).toList()
                              : [],
                      onChanged: (value) {
                        setState(() {
                          _selectedSubcategory = value;
                          _serviceRequest.subcategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una subcategoría';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                  Text(
                    '¿Cuándo necesitas que haga esto?*',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          screenWidth * 0.045, // Smaller font (Medium: 0.05)
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Fecha *',
                      labelStyle: TextStyle(
                        fontSize:
                            screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor seleccione una fecha';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    controller: _startTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Hora de inicio *',
                      labelStyle: TextStyle(
                        fontSize:
                            screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      ),
                      suffixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _startTimeController.text = picked.format(context);
                          _serviceRequest.startTime = _startTimeController.text;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor seleccione una hora de inicio';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_serviceRequest.category != null &&
                              _serviceRequest.subcategory != null &&
                              _serviceRequest.date != null &&
                              _serviceRequest.startTime != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => UbicacionStepScreen(
                                      serviceRequest: _serviceRequest,
                                    ),
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
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Siguiente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
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
      ),
    );
  }

  Widget _buildStepCircle(String number, {required bool isActive}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return CircleAvatar(
      radius: 20,
      backgroundColor:
          isActive ? const Color(0xFF22c55e) : Colors.grey.shade300,
      child: Text(
        number,
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
