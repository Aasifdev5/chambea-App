import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/contratado_screen.dart';

class PropuestaScreen extends StatefulWidget {
  @override
  _PropuestaScreenState createState() => _PropuestaScreenState();
}

class _PropuestaScreenState extends State<PropuestaScreen> {
  final _availabilityOptions = ['Inmediato', '1 día', '2 días'];
  String _availability = 'Inmediato';
  String _proposalDetails = '';
  String _budget = '';
  String _timeToComplete = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Propuesta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '(*) Campo obligatorio',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _buildJobCard(),
            const SizedBox(height: 20),
            _buildDropdownField(
              'Disponibilidad para empezar*',
              _availabilityOptions,
              _availability,
              (value) {
                setState(() => _availability = value!);
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Detalle de la propuesta*',
              hint: 'El precio de 80 BOB es mi servicio por hora',
              maxLength: 50,
              onChanged: (val) => setState(() => _proposalDetails = val),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Presupuesto*',
              hint: 'Introducir el presupuesto',
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => _budget = val),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Tiempo para cumplir con el trabajo',
              hint: 'Ejemplo: 2 días o 3 días',
              onChanged: (val) => setState(() => _timeToComplete = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContratadoScreen()),
                );
              },
              child: const Text(
                'Enviar Propuesta',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Hace 2 horas',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Consultar',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Cortocircuito en cocina',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildChip('Enchufes'),
              _buildChip('Paneles'),
              _buildChip('Instalación de cables'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              SizedBox(width: 4),
              Text('Hoy · 16:00', style: TextStyle(color: Colors.black54)),
              Spacer(),
              Text(
                'BOB: 80 - 150 / Hora',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.black54),
              SizedBox(width: 4),
              Text(
                'Ave Bush - La Paz',
                style: TextStyle(color: Colors.black54),
              ),
              Spacer(),
              Icon(Icons.payment, size: 16, color: Colors.black54),
              SizedBox(width: 4),
              Text('Efectivo o QR', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/user.png'), // Placeholder
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mario Urioste',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text('4.1', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          maxLength: maxLength,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
