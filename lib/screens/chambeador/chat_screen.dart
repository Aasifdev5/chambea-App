import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/buscar_screen.dart';
import 'package:chambea/screens/chambeador/chat_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/services/fcm_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;
  String? _error;
  String? _accountType;

  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
    _fetchAccountType();
    _fetchChats();
  }

  Future<void> _fetchAccountType() async {
    try {
      final accountType = await ApiService.getAccountType();
      setState(() {
        _accountType = accountType;
      });
    } catch (e) {
      print('Error fetching account type: $e');
      setState(() {
        _accountType = 'Chambeador'; // Fallback for Chambeador
      });
    }
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

      final chats = await ApiService.getChats();
      final filteredChats = chats.where((chat) {
        return chat['worker_id'] == user.uid &&
            chat['worker_account_type'] == 'Chambeador';
      }).toList();

      setState(() {
        _chats = filteredChats;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chats (Chambeador)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
                final clientId = chat['client_id'] ?? '';
                final requestId =
                    int.tryParse(chat['request_id']?.toString() ?? '0') ?? 0;
                final clientName = chat['client_account_type'] == 'Client'
                    ? (chat['worker_name'] ?? 'Usuario $clientId')
                    : 'Usuario Desconocido';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(clientName),
                  subtitle: Text(chat['last_message'] ?? 'Sin mensajes'),
                  trailing: Text(
                    chat['updated_at']?.toString() ?? 'Desconocido',
                  ),
                  onTap: () {
                    if (clientId.isNotEmpty && requestId != 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            workerId: clientId,
                            requestId: requestId,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error: Datos de chat inválidos'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
