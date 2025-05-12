import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/perfil_chambeador_screen.dart';
import 'package:chambea/screens/chambeador/notification_screen.dart';
import 'package:chambea/screens/chambeador/billetera_screen.dart';
import 'package:chambea/screens/chambeador/configuracion_screen.dart';
import 'package:chambea/screens/chambeador/home_screen.dart'; // For navigation back to HomeScreen on logout
import 'package:chambea/screens/client/home.dart';

class MasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed:
              () => Navigator.pop(context), // Navigate back to previous screen
        ),
        title: Text(
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menú',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green),
              title: Text(
                'Perfil',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: Icon(
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
              leading: Icon(Icons.notifications, color: Colors.green),
              title: Text(
                'Notificación',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () {
                // Navigate to PerfilScreen (assuming it handles notifications as per previous update)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.green),
              title: Text(
                'Billetera',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: Icon(
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
              leading: Icon(Icons.settings, color: Colors.green),
              title: Text(
                'Configuración',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: Icon(
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
              leading: Icon(Icons.support, color: Colors.green),
              title: Text(
                'Soporte técnico',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Soporte técnico contactado')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.green),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
              onTap: () {
                // Simulate logout by navigating back to HomeScreen and showing a SnackBar
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (Route<dynamic> route) => false, // Clear the navigation stack
                );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Sesión cerrada')));
              },
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientHomeScreen()),
                );
              },
              child: Text(
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
