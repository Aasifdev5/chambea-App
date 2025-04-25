import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/home_screen.dart'; // For logout navigation

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool _notificationsEnabled = true;
  bool _textMessagesEnabled = true;
  bool _phoneCallsEnabled = false;

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
          'Configuración',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cuenta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ListTile(
                title: Text(
                  'Cambiar contraseña',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
                onTap: () {
                  // Placeholder for password change screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Navegar a pantalla de cambio de contraseña',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),
              ListTile(
                title: Text(
                  'Privacidad',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
                onTap: () {
                  // Placeholder for privacy settings screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navegar a pantalla de privacidad')),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
                onTap: () {
                  // Simulate logout by navigating back to HomeScreen and clearing navigation stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Sesión cerrada')));
                },
              ),
              SizedBox(height: 20),
              Text(
                'Más opciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ListTile(
                title: Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Switch(
                  value: _textMessagesEnabled,
                  onChanged: (value) {
                    setState(() {
                      _textMessagesEnabled = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),
              ListTile(
                title: Text(
                  'Mensajes de texto',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Switch(
                  value: _textMessagesEnabled,
                  onChanged: (value) {
                    setState(() {
                      _textMessagesEnabled = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),
              ListTile(
                title: Text(
                  'Llamadas telefónicas',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Switch(
                  value: _phoneCallsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _phoneCallsEnabled = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),
              ListTile(
                title: Text(
                  'Moneda',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$ - USD',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ],
                ),
                onTap: () {
                  // Placeholder for currency selection screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navegar a selección de moneda')),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Lenguaje',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Español',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ],
                ),
                onTap: () {
                  // Placeholder for language selection screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navegar a selección de lenguaje')),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Cuenta Vinculada',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Google',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ],
                ),
                onTap: () {
                  // Placeholder for linked account management
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navegar a gestión de cuentas vinculadas'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}
