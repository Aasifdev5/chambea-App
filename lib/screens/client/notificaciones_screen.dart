import 'package:flutter/material.dart';

class NotificacionesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem('Geoffrey Manning confirmed your booking request', '09:20 AM'),
          _buildNotificationItem('Geoffrey Manning confirmed your booking request', '09:20 AM'),
          _buildNotificationItem('Geoffrey Manning confirmed your booking request', '09:30 AM'),
          _buildNotificationItem('Geoffrey Manning confirmed your booking request', '09:30 AM'),
          _buildNotificationItem('Geoffrey Manning confirmed your booking request', '09:30 AM'),
          _buildNotificationItem('Geoffrey Manning confirmed your booking request', '09:30 AM'),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String message, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.person, color: Colors.white),
      ),
      title: Text(message),
      subtitle: Text(time),
    );
  }
}