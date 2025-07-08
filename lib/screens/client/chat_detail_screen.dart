import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/widgets/chat_message.dart';

class ChatDetailScreen extends StatefulWidget {
  final String workerId;
  final int requestId;

  const ChatDetailScreen({
    required this.workerId,
    required this.requestId,
    super.key,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  String? _chatId;
  String? _workerName;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _error;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Fetch worker details
      final userResponse = await ApiService.get(
        '/api/users/${widget.workerId}',
      );
      if (userResponse['status'] == 'error') {
        throw Exception(userResponse['message'] ?? 'User not found');
      }
      final workerData = userResponse['data'] ?? {};
      if (workerData['account_type'] != 'Chambeador') {
        throw Exception('Worker is not a Chambeador');
      }

      // Initialize chat
      final chatResponse = await ApiService.post('/api/chats/initialize', {
        'request_id': widget.requestId,
        'worker_id': widget.workerId,
        'account_type': 'Client',
      });
      if (chatResponse['status'] == 'error') {
        throw Exception(chatResponse['message'] ?? 'Failed to initialize chat');
      }

      // Fetch messages
      final messagesResponse = await ApiService.get(
        '/api/chats/${chatResponse['data']['chat_id']}/messages',
      );
      if (messagesResponse['status'] == 'error') {
        throw Exception(
          messagesResponse['message'] ?? 'Failed to fetch messages',
        );
      }

      setState(() {
        _chatId = chatResponse['data']['chat_id'];
        _workerName = workerData['name'] ?? 'Usuario ${widget.workerId}';
        _messages = List<Map<String, dynamic>>.from(messagesResponse['data']);
        _isLoading = false;
      });

      // Mark messages as read
      for (var message in _messages) {
        if (message['sender_id'] != user.uid && !message['read']) {
          await ApiService.post('/api/chats/mark-read', {
            'chat_id': _chatId,
            'message_id': message['id'],
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _chatId == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await ApiService.post('/api/chats/send', {
        'chat_id': _chatId,
        'message': _messageController.text,
        'account_type': 'Client',
      });

      if (response['status'] == 'error') {
        throw Exception(response['message'] ?? 'Failed to send message');
      }

      setState(() {
        _messages.add({
          'id': response['message_id'],
          'sender_id': user.uid,
          'message': _messageController.text,
          'timestamp': DateTime.now().toIso8601String(),
          'read': false,
          'sender_account_type': 'Client',
        });
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
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
              _workerName ?? 'Chat',
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
              // Implement search functionality if needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Funcionalidad de búsqueda no implementada'),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Opciones adicionales')));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isSent =
                          message['sender_id'] ==
                          FirebaseAuth.instance.currentUser?.uid;
                      return ChatMessage(
                        message: message['message'],
                        time: DateTime.parse(
                          message['timestamp'],
                        ).toLocal().toString().substring(11, 16),
                        isSent: isSent,
                        isImage: false, // Add image support if needed
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
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
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
