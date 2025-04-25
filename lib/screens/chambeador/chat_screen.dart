import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/buscar_screen.dart';
import 'package:chambea/screens/chambeador/chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context), // Optional back navigation
        ),
        title: Text(
          'Chats',
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
              index % 2 == 0 ? 'Julio César Suárez' : 'Mario Urioste',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              index == 0
                  ? 'OK'
                  : index == 1
                  ? 'Perfecto'
                  : index == 2
                  ? 'Terminé de limpiar a las 8pm' // Corrected typo and phrasing
                  : index == 3
                  ? '¿Por cuándo servicio??'
                  : 'ok, nos vemos mañana entonces',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            trailing: Text(
              index == 0
                  ? '10:01 AM'
                  : index == 1
                  ? '10:32'
                  : index == 2
                  ? '11:01 AM'
                  : index == 3
                  ? 'Ayer'
                  : 'Ayer',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatDetailScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
