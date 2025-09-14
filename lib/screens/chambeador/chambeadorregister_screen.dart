import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/informacion_basica_screen.dart';
import 'package:chambea/screens/chambeador/identity_card_screen.dart';
import 'package:chambea/screens/chambeador/antecedentes_screen.dart';
import 'package:chambea/screens/chambeador/perfil_chambeador_screen.dart';
import 'package:chambea/screens/chambeador/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChambeadorRegisterScreen extends StatelessWidget {
  Future<bool> _verifyProfileCompletion(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar(context, 'Por favor, inicia sesión para continuar.');
      return false;
    }

    try {
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('https://chambea.lat/api/verify-profile-completion'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('DEBUG: Verify profile response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['can_access_homescreen'] == true) {
          return true;
        } else {
          _showProfileIncompleteDialog(context, data['details']);
          return false;
        }
      } else {
        print('ERROR: Failed to verify profile: ${response.body}');
        final errorData = json.decode(response.body);
        _showErrorSnackBar(context, errorData['message'] ?? 'Error al verificar el perfil. Intenta de nuevo.');
        return false;
      }
    } catch (e) {
      print('ERROR: Failed to verify profile: $e');
      _showErrorSnackBar(context, 'Error de conexión. Verifica tu internet e intenta de nuevo.');
      return false;
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
        elevation: 6,
      ),
    );
  }

  void _showProfileIncompleteDialog(BuildContext context, Map<String, dynamic> details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              'Perfil Incompleto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para continuar al inicio, completa las siguientes secciones:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            if (!details['has_profile'])
              _buildIncompleteItem(context, 'Información Básica', const InformacionBasicaScreen()),
            if (!details['has_identity_card'])
              _buildIncompleteItem(context, 'Cédula de Identidad', const IdentityCardScreen()),
            if (!details['has_certificate'])
              _buildIncompleteItem(context, 'Certificado de Antecedentes', const AntecedentesScreen()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
        ],
        elevation: 8,
      ),
    );
  }

  Widget _buildIncompleteItem(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen),
              );
            },
            child: const Text(
              'Completar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración de cuenta',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(
                    context,
                    title: 'Cédula de identidad',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IdentityCardScreen()),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  _buildListTile(
                    context,
                    title: 'Certificado de antecedentes policiales',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AntecedentesScreen()),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  _buildListTile(
                    context,
                    title: 'Perfil Chambeador',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PerfilChambeadorScreen()),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final canAccessHomeScreen = await _verifyProfileCompletion(context);
                  if (canAccessHomeScreen) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Al tocar "Aceptar", acepto los términos y condiciones, así como reconozco y acepto el tratamiento y la transferencia de datos personales de acuerdo con lo estipulado en la política de privacidad.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.3,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward,
        color: Colors.green,
        size: 24,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}