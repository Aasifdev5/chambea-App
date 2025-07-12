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
  final String workerId; // Worker UID for Client
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
        'DEBUG: Client initializing chat for user ${user.uid}, requestId: ${widget.requestId}, workerId: ${widget.workerId}',
      );

      // Verify client account type
      final clientResponse = await retry(
        () => ApiService.get('/api/users/${user.uid}'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      print('DEBUG: Client response: $clientResponse');
      if (clientResponse['status'] != 'success' ||
          clientResponse['data'] == null) {
        throw Exception(clientResponse['message'] ?? 'Client not found');
      }
      if (clientResponse['data']['account_type'] != 'Client') {
        throw Exception('User is not a Client');
      }

      // Fetch worker details
      final workerResponse = await retry(
        () => ApiService.get('/api/users/${widget.workerId}'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );
      print('DEBUG: Worker response: $workerResponse');
      if (workerResponse['status'] != 'success' ||
          workerResponse['data'] == null) {
        throw Exception(workerResponse['message'] ?? 'Worker not found');
      }
      final workerData = workerResponse['data'] as Map<String, dynamic>;
      if (workerData['account_type'] != 'Chambeador') {
        throw Exception('Worker is not a Chambeador');
      }

      // Initialize chat
      final chatResponse = await retry(
        () => ApiService.post('/api/chats/initialize', {
          'request_id': widget.requestId,
          'worker_id': widget.workerId,
          'account_type': 'Client',
          'client_id': user.uid,
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

      final expectedChatId =
          'chat_${widget.requestId}_${user.uid}_${widget.workerId}';
      if (chatData['chat_id'] != expectedChatId) {
        print(
          'DEBUG: Client chat_id mismatch! Expected: $expectedChatId, Got: ${chatData['chat_id']}',
        );
        throw Exception(
          'Chat ID mismatch. Please check backend initialization logic.',
        );
      }

      setState(() {
        _chatId = chatData['chat_id'] as String;
        _workerName =
            workerData['name'] as String? ?? 'Usuario ${widget.workerId}';
        _isLoading = false;
      });

      print('DEBUG: Client chat initialized with chat_id: $_chatId');
      _listenForMessages();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: $e';
      });
      print('DEBUG: Client chat initialization failed: $e');
    }
  }

  void _listenForMessages() {
    if (_chatId == null) {
      setState(() {
        _error = 'Chat ID not initialized';
      });
      print('DEBUG: Client cannot listen for messages, chatId is null');
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
                print(
                  'DEBUG: Client fetched message ${doc.id}, sender: ${data['sender_id']}, account_type: ${data['sender_account_type']}',
                );
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
            print('DEBUG: Client messages updated: ${_messages.length}');
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              print('DEBUG: Client user not authenticated in message listener');
              return;
            }
            for (var message in _messages) {
              if (message['sender_id'] != user.uid && !message['read']) {
                ApiService.post('/api/chats/mark-read', {
                  'chat_id': _chatId,
                  'message_id': message['id'],
                }).catchError((e) {
                  print('DEBUG: Client failed to mark message as read: $e');
                });
              }
            }
          },
          onError: (e) {
            setState(() {
              _error = 'Failed to load messages: $e';
            });
            print('DEBUG: Client message stream error: $e');
          },
        );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _chatId == null) {
      print('DEBUG: Client cannot send message, text or chatId is empty/null');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await ApiService.post('/api/chats/send', {
        'chat_id': _chatId,
        'message': _messageController.text,
        'account_type': 'Client',
        'is_image': false,
      });
      print('DEBUG: Client send message response: $response');
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to send message');
      }

      setState(() {
        _messageController.clear();
      });
      print('DEBUG: Client message sent successfully');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      print('DEBUG: Client failed to send message: $e');
    }
  }

  Future<void> _sendImage() async {
    if (_chatId == null) {
      print('DEBUG: Client cannot send image, chatId is null');
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
        print('DEBUG: Client no image selected');
        return;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('$_chatId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();

      final response = await ApiService.post('/api/chats/send', {
        'chat_id': _chatId,
        'message': url,
        'account_type': 'Client',
        'is_image': true,
      });
      print('DEBUG: Client send image response: $response');
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to send image');
      }
      print('DEBUG: Client image sent successfully');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending image: $e')));
      print('DEBUG: Client failed to send image: $e');
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
                      print(
                        'DEBUG: Client rendering message ${message['id']}, isSent: $isSent, sender_id: ${message['sender_id']}, user: ${FirebaseAuth.instance.currentUser?.uid}, sender_account_type: ${message['sender_account_type']}',
                      );
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
