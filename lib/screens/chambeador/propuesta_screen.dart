import 'package:flutter/material.dart';

class PropuestaScreen extends StatefulWidget {
  @override
  _PropuestaScreenState createState() => _PropuestaScreenState();
}

class _PropuestaScreenState extends State<PropuestaScreen> {
  bool _isCreating = true; // Switch between Crear and Evaluar modes
  String _availability = 'Inmediato';
  String _proposalDetails = 'El precio de 80 BOB es mi servicio por hora';
  String _cost = 'BOB 80.00';
  String _completionTime = '3 días';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context), // Consistent back navigation
        ),
        title: Text(
          'Propuesta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isCreating)
            TextButton(
              onPressed: () {
                setState(() {
                  _isCreating = false;
                });
              },
              child: Text(
                'Evaluar',
                style: TextStyle(color: Colors.yellow.shade700, fontSize: 16),
              ),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isCreating = true;
                });
              },
              child: Text(
                'Crear',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel returns to previous screen
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hace 2 horas',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      'BOB. 80 - 150/Hora',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Instalaciones de luces LED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        'ILUMINACIÓN',
                        style: TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    Chip(
                      label: Text('PANELES', style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    Chip(
                      label: Text('SEGURIDAD', style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      'Ave Bush - La Paz',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mario Urioste',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.yellow.shade700,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.1',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (_isCreating)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponibilidad para empezar*',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _availability,
                        decoration: InputDecoration(
                          hintText: 'Inmediato',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items:
                            ['Inmediato', '1 día', '2 días']
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _availability = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Detalle de la propuesta*',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText:
                              'El precio de 80 BOB es mi servicio por hora',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _proposalDetails = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Presupuesto*',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Costo del servicio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: TextEditingController(text: _cost),
                        onChanged: (value) {
                          setState(() {
                            _cost = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tiempo para cumplir con el trabajo',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '3 días',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: TextEditingController(
                          text: _completionTime,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _completionTime = value;
                          });
                        },
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponibilidad para empezar*',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _availability,
                        decoration: InputDecoration(
                          hintText: 'Seleccionar disponibilidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items:
                            ['Inmediato', '1 día', '2 días']
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _availability = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Detalle de la propuesta*',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Agregar detalle',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _proposalDetails = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Presupuesto*',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Introducir el presupuesto',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: TextEditingController(text: _cost),
                        onChanged: (value) {
                          setState(() {
                            _cost = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tiempo para cumplir con el trabajo',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Ejemplo: 2 días o 3 días',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: TextEditingController(
                          text: _completionTime,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _completionTime = value;
                          });
                        },
                      ),
                    ],
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
                    // Add logic to handle proposal submission or evaluation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Propuesta enviada')),
                    );
                    Navigator.pop(
                      context,
                    ); // Return to HomeScreen after submission
                  },
                  child: Text(
                    'Enviar Propuesta',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
