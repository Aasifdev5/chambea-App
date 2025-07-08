import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/widgets/chat_message.dart';
import 'package:retry/retry.dart';

class ChatDetailScreen extends StatefulWidget {
  final String workerId; // Client UID for Chambeador
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
  StreamSubscription<QuerySnapshot>? _messageSubscription;

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
        throw Exception('User not authenticated. Please log in.');
      }

      print(
        'DEBUG: Initializing chat for user ${user.uid}, requestId: ${widget.requestId}, workerId: ${widget.workerId}',
      );

      // Determine account type with retry
      final userResponse = await retry(
        () => ApiService.get('/api/users/${user.uid}'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      print('DEBUG: User response: $userResponse');
      if (userResponse['status'] != 'success' || userResponse['data'] == null) {
        throw Exception(userResponse['message'] ?? 'User not found');
      }
      final accountType =
          userResponse['data']['account_type'] as String? ?? 'Chambeador';
      if (accountType != 'Chambeador') {
        throw Exception('User is not a Chambeador');
      }

      // Fetch client details
      final otherUserResponse = await retry(
        () => ApiService.get('/api/users/${widget.workerId}'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      print('DEBUG: Other user response: $otherUserResponse');
      if (otherUserResponse['status'] != 'success' ||
          otherUserResponse['data'] == null) {
        throw Exception(otherUserResponse['message'] ?? 'Client not found');
      }
      final otherUserData = otherUserResponse['data'] as Map<String, dynamic>;
      if (otherUserData['account_type'] != 'Client') {
        throw Exception('Recipient is not a Client');
      }

      // Initialize chat
      final chatResponse = await retry(
        () => ApiService.post('/api/chats/initialize', {
          'request_id': widget.requestId,
          'worker_id': widget.workerId,
          'account_type': accountType,
        }),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      print('DEBUG: Chat response: $chatResponse');
      if (chatResponse['status'] != 'success' || chatResponse['data'] == null) {
        throw Exception(chatResponse['message'] ?? 'Failed to initialize chat');
      }
      final chatData = chatResponse['data'] as Map<String, dynamic>?;
      if (chatData == null || chatData['chat_id'] == null) {
        throw Exception('Invalid chat response structure');
      }

      setState(() {
        _chatId = chatData['chat_id'] as String;
        _workerName =
            otherUserData['name'] as String? ?? 'Usuario ${widget.workerId}';
        _isLoading = false;
      });

      print('DEBUG: Chat initialized with chat_id: $_chatId');
      _listenForMessages();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: $e';
      });
      print('DEBUG: Chat initialization failed: $e');
    }
  }

  void _listenForMessages() {
    if (_chatId == null) {
      setState(() {
        _error = 'Chat ID not initialized';
      });
      print('DEBUG: Cannot listen for messages, chatId is null');
      return;
    }
    _messageSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            setState(() {
              _messages = snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'sender_id': data['sender_id'],
                  'message': data['message'],
                  'timestamp': data['timestamp'],
                  'read': data['read'] ?? false,
                  'sender_account_type': data['sender_account_type'],
                  'is_image': data['is_image'] ?? false,
                };
              }).toList();
            });
            print('DEBUG: Messages updated: ${_messages.length}');
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;
            for (var message in _messages) {
              if (message['sender_id'] != user.uid && !message['read']) {
                ApiService.post('/api/chats/mark-read', {
                  'chat_id': _chatId,
                  'message_id': message['id'],
                }).catchError((e) {
                  print('DEBUG: Failed to mark message as read: $e');
                });
              }
            }
          },
          onError: (e) {
            setState(() {
              _error = 'Failed to load messages: $e';
            });
            print('DEBUG: Message stream error: $e');
          },
        );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _chatId == null) {
      print('DEBUG: Cannot send message, text or chatId is empty/null');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userResponse = await ApiService.get('/api/users/${user.uid}');
      print('DEBUG: User response for send: $userResponse');
      if (userResponse['status'] != 'success' || userResponse['data'] == null) {
        throw Exception(userResponse['message'] ?? 'User not found');
      }
      final accountType =
          userResponse['data']['account_type'] as String? ?? 'Chambeador';

      final response = await ApiService.post('/api/chats/send', {
        'chat_id': _chatId,
        'message': _messageController.text,
        'account_type': accountType,
        'is_image': false,
      });
      print('DEBUG: Send message response: $response');
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to send message');
      }

      setState(() {
        _messageController.clear();
      });
      print('DEBUG: Message sent successfully');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      print('DEBUG: Failed to send message: $e');
    }
  }

  Future<void> _sendImage() async {
    if (_chatId == null) {
      print('DEBUG: Cannot send image, chatId is null');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        print('DEBUG: No image selected');
        return;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('$_chatId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();

      final userResponse = await ApiService.get('/api/users/${user.uid}');
      print('DEBUG: User response for send image: $userResponse');
      if (userResponse['status'] != 'success' || userResponse['data'] == null) {
        throw Exception(userResponse['message'] ?? 'User not found');
      }
      final accountType =
          userResponse['data']['account_type'] as String? ?? 'Chambeador';

      final response = await ApiService.post('/api/chats/send', {
        'chat_id': _chatId,
        'message': url,
        'account_type': accountType,
        'is_image': true,
      });
      print('DEBUG: Send image response: $response');
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to send image');
      }
      print('DEBUG: Image sent successfully');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending image: $e')));
      print('DEBUG: Failed to send image: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              _workerName ?? 'Chat',
              style: const TextStyle(
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
            icon: const Icon(Icons.image, color: Colors.black54),
            onPressed: _sendImage,
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad de búsqueda no implementada'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opciones adicionales')),
              );
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
                    reverse: true,
                    padding: const EdgeInsets.all(16),
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
                        isImage: message['is_image'] ?? false,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
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
