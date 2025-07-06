import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chambea/services/api_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String workerId; // Changed to String for Firebase UID
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
  bool _isLoading = true;
  String? _error;

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

      setState(() {
        _chatId = chatResponse['data']['chat_id'];
        _workerName = workerData['name'] ?? 'Usuario ${widget.workerId}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_workerName ?? 'Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Center(child: Text('Chat with ${_workerName ?? widget.workerId}')),
    );
  }
}
