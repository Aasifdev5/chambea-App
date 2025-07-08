import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final String time;
  final bool isSent;
  final bool isImage;

  const ChatMessage({
    required this.message,
    required this.time,
    required this.isSent,
    this.isImage = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isImage)
              Container(
                width: 150,
                height: 100,
                color: Colors.grey.shade300,
                child: Center(child: Text('Imagen no soportada')),
              )
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
