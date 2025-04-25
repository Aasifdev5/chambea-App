import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/buscar_screen.dart';

class NotificationScreen extends StatelessWidget {
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
          'Notification', // Changed title to "Perfil" for consistency
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BuscarScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              'Geoffrey Manning',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              'confirmed your booking request',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            trailing: Text(
              '09:30 AM',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            onTap: () {
              // Optionally add navigation to a detailed notification view
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Notification tapped')));
            },
          );
        },
      ),
    );
  }
}
