import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chambea/services/api_service.dart'; // Your ApiService

class BilleteraScreen extends StatefulWidget {
  @override
  _BilleteraScreenState createState() => _BilleteraScreenState();
}

class _BilleteraScreenState extends State<BilleteraScreen> {
  double balance = 0.0;
  bool isLoading = true;
  String errorMessage = '';
  String workerStatus = ''; // Track worker status from API
  String whatsappNumber = '+59178528046';
  String whatsappMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _fetchRechargeInfo();
  }

  Future<void> _fetchBalance() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService.get('/api/balance');

      if (response['status'] == 'error') {
        // API returned an error, get status if available
        setState(() {
          workerStatus = response['worker_status'] ?? '';
          errorMessage = response['message'] ?? 'Error al cargar el saldo';
          isLoading = false;
        });
        return;
      }

      // Success
      setState(() {
        balance = double.tryParse(response['balance'].toString()) ?? 0;
        workerStatus = response['worker_status'] ?? '';
        errorMessage = '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al conectar con el servidor';
        isLoading = false;
      });
      debugPrint('Error fetching balance: $e');
    }
  }

  Future<void> _fetchRechargeInfo() async {
    try {
      final response = await ApiService.get('/api/recharge-info');
      if (response['success']) {
        setState(() {
          whatsappNumber =
              response['data']['whatsapp_number'] ?? whatsappNumber;
          whatsappMessage = response['data']['whatsapp_message'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching recharge info: $e');
    }
  }

  Future<void> _launchWhatsApp() async {
    try {
      if (workerStatus != 'approved' || balance <= 0) return; // prevent launch

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      String message = whatsappMessage.isNotEmpty
          ? whatsappMessage
          : 'Hola, quiero recargar mi saldo en la app Chambeador.';
      message +=
          '\n\nMi saldo actual: BOB. $balance\n\nPor favor, indícame los datos para el depósito.';

      String cleanNumber = whatsappNumber.replaceAll(RegExp(r'[\s+]'), '');
      final whatsappUrl =
          'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}';
      final whatsappUri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        final browserUrl =
            'https://web.whatsapp.com/send?phone=$cleanNumber&text=${Uri.encodeComponent(message)}';
        final browserUri = Uri.parse(browserUrl);

        if (await canLaunchUrl(browserUri)) {
          await launchUrl(browserUri, mode: LaunchMode.platformDefault);
        } else {
          throw 'No se pudo abrir WhatsApp ni en la aplicación ni en el navegador';
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir WhatsApp: ${e.toString()}'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canRecharge = workerStatus == 'approved' && balance > 0;

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
              Center(child: CircularProgressIndicator())
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
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(errorMessage),
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
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'BOB. ${balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Estado: $workerStatus',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
                      onPressed: canRecharge ? _launchWhatsApp : null,
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Recargar Saldo',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canRecharge
                            ? Colors.green
                            : Colors.grey,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    if (!canRecharge)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          workerStatus != 'approved'
                              ? 'Tus documentos están en revisión. Una vez aprobados podrás acceder a tu cuenta de trabajador.'
                              : 'Tu saldo es cero. Por favor, recarga tu saldo para aplicar a este trabajo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
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
