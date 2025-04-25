import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/buscar_screen.dart';

class ChatDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed:
              () => Navigator.pop(context), // Navigate back to ChatScreen
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text(
              'Mario Urioste',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
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
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {
              // Placeholder for more options (e.g., settings or info)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Opciones adicionales')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildChatMessage(
                  message: 'quae ab inventore',
                  time: '16:50',
                  isSent: false,
                ),
                _buildChatMessage(
                  message: 'quae architecto beatae vitae',
                  time: '00:13',
                  isSent: false,
                ),
                _buildChatMessage(
                  message: 'Sed ut perspiciatis unde omnis iste',
                  time: '00:13',
                  isSent: false,
                  isImage: true,
                ),
                _buildChatMessage(
                  message: 'doloremque laudantium, totam rem?',
                  time: '16:46',
                  isSent: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Mensaje',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // Placeholder for sending message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mensaje enviado')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage({
    required String message,
    required String time,
    required bool isSent,
    bool isImage = false,
  }) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSent ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment:
              isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isImage)
              Container(width: 150, height: 100, color: Colors.grey.shade300)
            else
              Text(
                message,
                style: TextStyle(
                  color: isSent ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isSent ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
