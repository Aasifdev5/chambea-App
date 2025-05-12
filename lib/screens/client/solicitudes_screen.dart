import 'package:flutter/material.dart';
import 'package:chambea/screens/client/solicitar_servicio_screen.dart';
import 'package:chambea/screens/client/propuestas_screen.dart';

class SolicitudesScreen extends StatelessWidget {
  const SolicitudesScreen({super.key}); // Added constructor for clarity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Lista de solicitudes'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildRequestCard(
                  context: context, // Pass context
                  status: 'Activo',
                  title: 'Instalaciones de luces LED',
                  location: 'Ave Bush - La Paz',
                  price: 'BOB: 80',
                  proposals: 1,
                  subcategoryName: 'Electricidad',
                ),
                _buildRequestCard(
                  context: context, // Pass context
                  status: 'Activo',
                  title: 'Limpieza de 4 habitaciones',
                  location: 'Ave Bush - La Paz',
                  price: 'BOB: 80',
                  proposals: 5,
                  subcategoryName: 'Limpieza',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            SolicitarServicioScreen(subcategoryName: ''),
                  ),
                );
              },
              child: const Text(
                'Solicitar servicio',
                style: TextStyle(
                  color: Colors.white,
                ), // Set text color to white
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard({
    required BuildContext context, // Add context parameter
    required String status,
    required String title,
    required String location,
    required String price,
    required int proposals,
    required String subcategoryName,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.yellow.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(location),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text(price)],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            PropuestasScreen(subcategoryName: subcategoryName),
                  ),
                );
              },
              child: Text(
                '$proposals Propuesta${proposals > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                ), // Set text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
