import 'package:flutter/material.dart';
import 'package:chambea/screens/client/chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatDetailScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChatItem(context, 'Julio César Suárez', 'Ok', '10:01 AM'),
          _buildChatItem(
            context,
            'Pedro Castillo',
            'Perfecto, gracias',
            '10:32 AM',
          ),
          _buildChatItem(
            context,
            'Julio César Suárez',
            'Terminó de Imperio hasta las 1pm',
            '11:01 AM',
          ),
          _buildChatItem(context, 'Julio César Suárez', 'Gracias', 'Ayer'),
          _buildChatItem(
            context,
            'Julio César Suárez',
            'Para cuándo sería??',
            'Ayer',
          ),
          _buildChatItem(
            context,
            'Mario Urioste',
            'Ok, nos vemos mañana entonces',
            'Ayer',
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    String name,
    String message,
    String time,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name),
      subtitle: Text(message),
      trailing: Text(time),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatDetailScreen()),
        );
      },
    );
  }
}
