import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool _notificationsEnabled = true;
  bool _newsEnabled = false;
  bool _textMessagesEnabled = true;
  bool _phoneCallsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Cambiar contraseña'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Notificaciones'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
              activeColor: Colors.green,
            ),
          ),
          ListTile(
            title: const Text('Privacidad'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Cerrar Sesión'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          const Text('Más opciones', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Noticias'),
            trailing: Switch(
              value: _newsEnabled,
              onChanged: (value) => setState(() => _newsEnabled = value),
              activeColor: Colors.green,
            ),
          ),
          ListTile(
            title: const Text('Mensaje de texto'),
            trailing: Switch(
              value: _textMessagesEnabled,
              onChanged: (value) => setState(() => _textMessagesEnabled = value),
              activeColor: Colors.green,
            ),
          ),
          ListTile(
            title: const Text('Llamadas telefónicas'),
            trailing: Switch(
              value: _phoneCallsEnabled,
              onChanged: (value) => setState(() => _phoneCallsEnabled = value),
              activeColor: Colors.green,
            ),
          ),
          ListTile(
            title: const Text('Currency'),
            subtitle: const Text('\$ - USD'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Lenguaje'),
            subtitle: const Text('Español'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Cuenta Vinculada'),
            subtitle: const Text('Google'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}