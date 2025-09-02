import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/informacion_basica_screen.dart';
import 'package:chambea/screens/chambeador/identity_card_screen.dart';
import 'package:chambea/screens/chambeador/antecedentes_screen.dart';
import 'package:chambea/screens/chambeador/perfil_chambeador_screen.dart';
import 'package:chambea/screens/chambeador/home_screen.dart';

class ChambeadorRegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Configuración de cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // List of navigation options
            Expanded(
              child: ListView(
                children: [
                  // ListTile(
                  //   title: const Text('Información básica'),
                  //   trailing: const Icon(Icons.arrow_forward),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => InformacionBasicaScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // const Divider(),
                  ListTile(
                    title: const Text('Cédula de identidad'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => IdentityCardScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Certificado de antecedentes policiales'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AntecedentesScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Perfil Chambeador'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PerfilChambeadorScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // "Aceptar" button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Terms and conditions note
            const Text(
              'Al tocar "Aceptar", acepto los términos y condiciones, así como reconozco y acepto el tratamiento y la transferencia de datos personales de acuerdo con lo estipulado en la política de privacidad.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
