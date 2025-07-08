import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final String time;
  final bool isSent;
  final bool isImage;

  const ChatMessage({
    required this.message,
    required this.time,
    required this.isSent,
    required this.isImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSent ? Colors.green.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isImage)
              CachedNetworkImage(
                imageUrl: message,
                width: 150,
                height: 100,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            else
              Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
