import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chambea/screens/chambeador/perfil_chambeador_screen.dart';
import 'package:chambea/screens/chambeador/notification_screen.dart';
import 'package:chambea/screens/chambeador/billetera_screen.dart';
import 'package:chambea/screens/chambeador/configuracion_screen.dart';
import 'package:chambea/screens/client/supportscreen.dart';
import 'package:chambea/screens/chambeador/home_screen.dart';
import 'package:chambea/screens/client/perfil_screen.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:chambea/main.dart';
import 'package:chambea/screens/chambeador/informacion_basica_screen.dart';
import 'package:chambea/screens/chambeador/identity_card_screen.dart';
import 'package:chambea/screens/chambeador/antecedentes_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Check if user profile exists via Laravel API
  Future<bool> _checkUserProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('https://chambea.lat/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      print('DEBUG: API response status: ${response.statusCode}');
      print('DEBUG: API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print('DEBUG: User profile exists for UID: ${user.uid}');
          return true;
        } else {
          print('DEBUG: Unexpected response format: ${response.body}');
          return false;
        }
      } else if (response.statusCode == 404) {
        print('DEBUG: Profile not found for UID: ${user.uid}');
        return false;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Error checking user profile: $e');
      throw Exception('Error checking user profile: $e');
    }
  }

  // Handle Modo Client button tap
  Future<void> _handleModoClient(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor inicia sesión para continuar'),
          ),
        );
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verificando perfil del usuario...')),
        );
      }

      final profileExists = await _checkUserProfile(context);

      if (context.mounted) {
        if (profileExists) {
          print('DEBUG: Navigating to ClientHomeScreen');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
          );
        } else {
          print('DEBUG: Navigating to PerfilScreen');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PerfilScreen()),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al verificar perfil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
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
              leading: const Icon(Icons.badge, color: Colors.green),
              title: const Text(
                'Tarjeta de Identidad',
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
                  MaterialPageRoute(builder: (_) => IdentityCardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.green),
              title: const Text(
                'Antecedentes',
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
                  MaterialPageRoute(builder: (_) => AntecedentesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.green),
              title: const Text(
                'Información Básica',
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
                  MaterialPageRoute(builder: (_) => InformacionBasicaScreen()),
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
              onPressed: () => _handleModoClient(context),
              child: const Text(
                'Modo cliente',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
