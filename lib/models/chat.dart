class Chat {
  final String jobId;
  final String workerName;
  final String? workerImageUrl;
  final String jobTitle;
  final List<ChatMessage> messages;

  Chat({
    required this.jobId,
    required this.workerName,
    this.workerImageUrl,
    required this.jobTitle,
    required this.messages,
  });

  // Factory method to create a Chat from JSON (if fetching from a backend)
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      jobId: json['jobId'] as String,
      workerName: json['workerName'] as String,
      workerImageUrl: json['workerImageUrl'] as String?,
      jobTitle: json['jobTitle'] as String,
      messages: (json['messages'] as List)
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList(),
    );
  }

  // Method to convert Chat to JSON (if sending to a backend)
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'workerName': workerName,
      'workerImageUrl': workerImageUrl,
      'jobTitle': jobTitle,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}

class ChatMessage {
  final String message;
  final String time;
  final bool isSent;
  final bool isImage;

  ChatMessage({
    required this.message,
    required this.time,
    required this.isSent,
    this.isImage = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] as String,
      time: json['time'] as String,
      isSent: json['isSent'] as bool,
      isImage: json['isImage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'time': time,
      'isSent': isSent,
      'isImage': isImage,
    };
  }
}