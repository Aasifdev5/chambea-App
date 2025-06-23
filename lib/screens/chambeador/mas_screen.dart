import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chambea/screens/chambeador/perfil_chambeador_screen.dart';
import 'package:chambea/screens/chambeador/notification_screen.dart';
import 'package:chambea/screens/chambeador/billetera_screen.dart';
import 'package:chambea/screens/chambeador/configuracion_screen.dart';
import 'package:chambea/screens/chambeador/home_screen.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:chambea/main.dart'; // For SplashScreen

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();
      // Sign out from Google Sign-In if used
      await GoogleSignIn().signOut();
      // Navigate to SplashScreen and clear navigation stack
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada exitosamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () =>
              Navigator.pop(context), // Navigate back to previous screen
        ),
        title: const Text(
          'Menú',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menú',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text(
                'Perfil',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PerfilChambeadorScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title: const Text(
                'Notificación',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
                color: Colors.green,
              ),
              title: const Text(
                'Billetera',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BilleteraScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title: const Text(
                'Configuración',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ConfiguracionScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support, color: Colors.green),
              title: const Text(
                'Soporte técnico',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Soporte técnico contactado')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.green),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () => _handleLogout(context),
            ),
            const Spacer(),
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
                  MaterialPageRoute(
                    builder: (context) => const ClientHomeScreen(),
                  ),
                );
              },
              child: const Text(
                'Modo Client',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
