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
      print('DEBUG: Account type fetched: $accountType');
      setState(() {
        _accountType = accountType;
      });
    } catch (e) {
      print('DEBUG: Error fetching account type: $e');
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
        print('DEBUG: User not authenticated');
        return;
      }

      final chats = await ApiService.getChats();
      print('DEBUG: Raw chats from API: $chats');
      final filteredChats = chats.where((chat) {
        final isWorkerChat =
            chat['worker_id'] == user.uid &&
            chat['worker_account_type'] == 'Chambeador';
        print(
          'DEBUG: Checking chat ${chat['chat_id']}: isWorkerChat=$isWorkerChat, client_id=${chat['client_id']}, worker_id=${chat['worker_id']}, worker_account_type=${chat['worker_account_type']}',
        );
        return isWorkerChat;
      }).toList();

      print('DEBUG: Filtered chats: $filteredChats');

      setState(() {
        _chats = filteredChats;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error fetching chats: $e');
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar los chats. Por favor, intenta de nuevo.';
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
            icon: Icon(Icons.refresh, color: Colors.black54),
            onPressed: _fetchChats,
          ),
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchChats,
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _chats.isEmpty
          ? Center(child: Text('No hay chats disponibles'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final clientId = chat['client_id'] ?? '';
                final requestId =
                    int.tryParse(chat['request_id']?.toString() ?? '0') ?? 0;
                final clientName = chat['client_account_type'] == 'Client'
                    ? (chat['client_name'] ?? 'Usuario $clientId')
                    : 'Usuario Desconocido';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(clientName),
                  subtitle: Text(chat['last_message'] ?? 'Sin mensajes'),
                  trailing: Text(
                    _formatTimestamp(chat['updated_at']?.toString()),
                  ),
                  onTap: () {
                    if (clientId.isNotEmpty && requestId != 0) {
                      print(
                        'DEBUG: Navigating to ChatDetailScreen with clientId=$clientId, requestId=$requestId',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            clientId: clientId,
                            requestId: requestId,
                          ),
                        ),
                      );
                    } else {
                      print(
                        'DEBUG: Invalid chat data: clientId=$clientId, requestId=$requestId',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
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

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Desconocido';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Desconocido';
    }
  }
}
