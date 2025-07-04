import 'package:flutter/material.dart';
import 'package:chambea/screens/client/chat_detail_screen.dart';
import 'package:chambea/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chambea/services/fcm_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _error = 'Debe iniciar sesión';
        });
        return;
      }

      final response = await ApiService.get('/api/chats');
      final chats = List<Map<String, dynamic>>.from(response['data'] ?? []);
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching chats: $e');
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
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality if needed
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _chats.isEmpty
          ? const Center(child: Text('No hay chats disponibles'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return _buildChatItem(
                  context,
                  chat['worker_name'] ?? 'Usuario ${chat['worker_id']}',
                  chat['last_message'] ?? 'Sin mensajes',
                  chat['last_message_time']?.toString() ?? 'Desconocido',
                  chat['worker_id'],
                  chat['service_request_id'],
                );
              },
            ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    String name,
    String message,
    String time,
    int workerId,
    int requestId,
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
          MaterialPageRoute(
            builder: (context) =>
                ChatDetailScreen(workerId: workerId, requestId: requestId),
          ),
        );
      },
    );
  }
}
