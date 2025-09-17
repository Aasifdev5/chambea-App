import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chambea/services/api_service.dart'; // Your ApiService

class BilleteraScreen extends StatefulWidget {
  @override
  _BilleteraScreenState createState() => _BilleteraScreenState();
}

class _BilleteraScreenState extends State<BilleteraScreen> {
  String balance = '0.00';
  bool isLoading = true;
  String errorMessage = '';
  String whatsappNumber = '+59178528046';
  String whatsappMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _fetchRechargeInfo();
  }

  // Fetch balance using ApiService
  Future<void> _fetchBalance() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService.get('/api/balance');

      if (response['success']) {
        setState(() {
          balance = response['data']['balance'].toString();
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load balance');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      debugPrint('Error fetching balance: $e');
    }
  }

  // Fetch recharge info using ApiService
  Future<void> _fetchRechargeInfo() async {
    try {
      final response = await ApiService.get('/api/recharge-info');
      
      if (response['success']) {
        setState(() {
          whatsappNumber = response['data']['whatsapp_number'] ?? whatsappNumber;
          whatsappMessage = response['data']['whatsapp_message'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching recharge info: $e');
      // Use default values if API call fails
    }
  }

  // Launch WhatsApp with pre-filled message
  Future<void> _launchWhatsApp() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    String message = whatsappMessage.isNotEmpty 
        ? whatsappMessage 
        : 'Hola, quiero recargar mi saldo en la app Chambeador. ';
    
    message += '\n\nMi saldo actual: BOB. $balance\n\nPor favor, indícame los datos para el depósito.';

    // Ensure phone number is properly formatted (remove spaces, plus sign for URL)
    String cleanNumber = whatsappNumber.replaceAll(RegExp(r'[\s+]'), '');
    final whatsappUrl = 'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}';
    final whatsappUri = Uri.parse(whatsappUrl);

    debugPrint('Attempting to launch WhatsApp URL: $whatsappUrl');

    // First try to launch WhatsApp app
    bool canLaunchApp = await canLaunchUrl(whatsappUri);
    if (canLaunchApp) {
      debugPrint('Launching WhatsApp app');
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Fallback to browser-based WhatsApp
      debugPrint('WhatsApp app not installed, trying browser fallback');
      final browserUrl = 'https://web.whatsapp.com/send?phone=$cleanNumber&text=${Uri.encodeComponent(message)}';
      final browserUri = Uri.parse(browserUrl);
      
      if (await canLaunchUrl(browserUri)) {
        debugPrint('Launching WhatsApp in browser');
        await launchUrl(
          browserUri,
          mode: LaunchMode.platformDefault,
        );
      } else {
        throw 'No se pudo abrir WhatsApp ni en la aplicación ni en el navegador';
      }
    }
  } catch (e) {
    debugPrint('Error launching WhatsApp: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al abrir WhatsApp: ${e.toString().replaceFirst('Exception: ', '')}'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: _launchWhatsApp,
        ),
      ),
    );
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
          'Billetera',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            if (isLoading)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: _fetchBalance,
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'BOB. $balance',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (double.parse(balance.replaceAll(',', '.')) > 0)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {}, // Add functionality for using balance
                        child: Text(
                          'Usar Saldo',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            SizedBox(height: 24),
            if (!isLoading && errorMessage.isEmpty)
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: double.parse(balance.replaceAll(',', '.')) > 0 
                          ? null 
                          : _launchWhatsApp,
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Recargar Saldo',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: double.parse(balance.replaceAll(',', '.')) > 0 
                            ? Colors.grey
                            : Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    if (double.parse(balance.replaceAll(',', '.')) > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '¡Tienes saldo disponible!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Necesitas recargar tu saldo para poder seguir trabajando  con Chambea',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}