import 'package:flutter/material.dart';
// Import your other screens
import 'package:chambea/screens/client/perfil_screen.dart';
import 'package:chambea/screens/client/notificaciones_screen.dart';
import 'package:chambea/screens/client/billetera_screen.dart';
import 'package:chambea/screens/client/configuracion_screen.dart';
import 'package:chambea/screens/chambeador/home_screen.dart';
import 'package:chambea/screens/client/supportscreen.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text('Perfil'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PerfilScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title: const Text('Notificación'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificacionesScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.green),
              title: const Text('Soporte técnico'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.green),
              title: const Text('Cerrar sesión'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle logout here
              },
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: const Text('Modo chambeador'),
            ),
          ],
        ),
      ),
    );
  }
}
