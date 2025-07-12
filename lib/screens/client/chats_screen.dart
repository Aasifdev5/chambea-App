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
        _accountType = 'Client'; // Fallback for Client
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
        final isClientChat =
            chat['client_id'] == user.uid &&
            chat['client_account_type'] == 'Client';
        print(
          'DEBUG: Checking chat ${chat['chat_id']}: isClientChat=$isClientChat, client_id=${chat['client_id']}, worker_id=${chat['worker_id']}, worker_account_type=${chat['worker_account_type']}',
        );
        return isClientChat;
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
        title: Text('Chats (Client)'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black54),
            onPressed: _fetchChats,
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Funcionalidad de búsqueda no implementada'),
                ),
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
                final workerId = chat['worker_id'] ?? '';
                final requestId =
                    int.tryParse(chat['request_id']?.toString() ?? '0') ?? 0;
                final workerName = chat['worker_account_type'] == 'Chambeador'
                    ? (chat['worker_name'] ?? 'Usuario $workerId')
                    : 'Usuario Desconocido';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(workerName),
                  subtitle: Text(chat['last_message'] ?? 'Sin mensajes'),
                  trailing: Text(
                    _formatTimestamp(chat['updated_at']?.toString()),
                  ),
                  onTap: () {
                    if (workerId.isNotEmpty && requestId != 0) {
                      print(
                        'DEBUG: Navigating to ChatDetailScreen with workerId=$workerId, requestId=$requestId',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            workerId: workerId,
                            requestId: requestId,
                          ),
                        ),
                      );
                    } else {
                      print(
                        'DEBUG: Invalid chat data: workerId=$workerId, requestId=$requestId',
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
