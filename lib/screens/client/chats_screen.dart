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
      setState(() {
        _accountType = accountType;
      });
    } catch (e) {
      print('Error fetching account type: $e');
      setState(() {
        _accountType = 'unknown';
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
        if (_accountType == 'Client') {
          return chat['client_id'] == user.uid;
        } else if (_accountType == 'Chambeador') {
          return chat['worker_id'] == user.uid;
        }
        return false;
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
        title: Text('Chats (${_accountType ?? "Cargando..."})'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
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
                    chat['updated_at']?.toString() ?? 'Desconocido',
                  ),
                  onTap: () {
                    if (workerId.isNotEmpty && requestId != 0) {
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
