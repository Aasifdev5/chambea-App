import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('Andrés Villamontes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessage(
                  text: 'quae ab inventore',
                  time: '16:50',
                  isSentByMe: false,
                  isRead: true,
                ),
                _buildMessage(
                  text: 'quasi architecto beatae vitae',
                  time: '09:13',
                  isSentByMe: false,
                  isRead: true,
                ),
                _buildMessageWithImage(
                  imageUrl: 'assets/room_image.jpg',
                  text: 'Sed ut perspiciatis unde omnis iste',
                  time: '08:13',
                  isSentByMe: false,
                  isRead: true,
                ),
                _buildMessage(
                  text: 'doloremque laudantium, totam rem?',
                  time: '16:46',
                  isSentByMe: true,
                  isRead: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Mensaje',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage({
    required String text,
    required String time,
    required bool isSentByMe,
    required bool isRead,
  }) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.grey.shade300 : Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                if (!isSentByMe && isRead) ...[
                  const SizedBox(width: 4),
                  const Text(
                    'Read',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageWithImage({
    required String imageUrl,
    required String text,
    required String time,
    required bool isSentByMe,
    required bool isRead,
  }) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.grey.shade300 : Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: 200,
              color: Colors.grey.shade300,
              child: const Center(child: Text('Image Placeholder')),
            ),
            const SizedBox(height: 8),
            Text(text),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                if (!isSentByMe && isRead) ...[
                  const SizedBox(width: 4),
                  const Text(
                    'Read',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}