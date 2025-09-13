import 'package:flutter/material.dart';
import 'package:chambea/screens/client/chat_detail_screen.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:chambea/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chambea/services/fcm_service.dart';
import 'package:chambea/main.dart'; // Import main.dart for AuthUtils

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

  Future<bool> _onWillPop() async {
    // Use AuthUtils to handle back navigation, ensuring redirection to ClientHomeScreen
    final shouldExit = await AuthUtils.handleBackNavigation(context);
    if (!shouldExit && context.mounted) {
      // Explicitly navigate to ClientHomeScreen if not exiting
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
        (route) => false,
      );
    }
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Chats (Client)',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black54, size: screenWidth * 0.06),
            onPressed: () async {
              await _onWillPop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.black54, size: screenWidth * 0.06),
              onPressed: _fetchChats,
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.black54, size: screenWidth * 0.06),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Funcionalidad de búsqueda no implementada',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
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
                        Text(
                          'Error: $_error',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22c55e),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                          ),
                          onPressed: _fetchChats,
                          child: Text(
                            'Reintentar',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _chats.isEmpty
                    ? Center(
                        child: Text(
                          'No hay chats disponibles',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(screenWidth * 0.04),
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
                              radius: screenWidth * 0.05,
                              backgroundColor: Colors.grey.shade300,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
                            ),
                            title: Text(
                              workerName,
                              style: TextStyle(fontSize: screenWidth * 0.04),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              chat['last_message'] ?? 'Sin mensajes',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              _formatTimestamp(chat['updated_at']?.toString()),
                              style: TextStyle(fontSize: screenWidth * 0.03),
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
                                    content: Text(
                                      'Error: Datos de chat inválidos',
                                      style: TextStyle(fontSize: screenWidth * 0.035),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
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