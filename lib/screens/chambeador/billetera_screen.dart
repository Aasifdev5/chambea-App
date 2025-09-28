import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chambea/services/api_service.dart';

class BilleteraScreen extends StatefulWidget {
  @override
  _BilleteraScreenState createState() => _BilleteraScreenState();
}

class _BilleteraScreenState extends State<BilleteraScreen> {
  double balance = 0.0;
  bool isLoading = true;
  String errorMessage = '';
  String workerStatus = ''; // status from API: approved, rejected, pending
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
        setState(() {
          workerStatus = response['data']?['worker_status'] ?? '';
          errorMessage = response['message'] ?? 'Error al cargar el saldo';
          isLoading = false;
        });
        return;
      }

      final data = response['data'] ?? {};

      setState(() {
        balance = double.tryParse(data['balance']?.toString() ?? '0') ?? 0.0;
        workerStatus = data['worker_status'] ?? '';
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
      if (response['success'] == true) {
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
    if (!canRecharge()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario no autenticado')));
      return;
    }

    String message = whatsappMessage.isNotEmpty
        ? whatsappMessage
        : 'Hola, quiero recargar mi saldo en la app Chambeador.';

    message +=
        '\n\nMi saldo actual: BOB. $balance\n\nPor favor, indícame los datos para el depósito.';

    String cleanNumber = whatsappNumber.replaceAll(RegExp(r'[\s+]'), '');
    final whatsappUri = Uri.parse(
      'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      final browserUri = Uri.parse(
        'https://web.whatsapp.com/send?phone=$cleanNumber&text=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(browserUri)) {
        await launchUrl(browserUri, mode: LaunchMode.platformDefault);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo abrir WhatsApp ni en la aplicación ni en el navegador',
            ),
          ),
        );
      }
    }
  }

  bool canRecharge() {
    // Enabled only if worker is approved
    return workerStatus == 'approved';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(errorMessage),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _fetchBalance,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
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
                        const Text(
                          'Saldo disponible',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'BOB. ${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estado: ${workerStatus.isEmpty ? "pendiente" : workerStatus}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            if (!isLoading && errorMessage.isEmpty)
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: canRecharge() ? _launchWhatsApp : null,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Recargar Saldo',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canRecharge()
                            ? Colors.green
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    if (!canRecharge())
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          workerStatus == 'rejected'
                              ? 'Tus documentos han sido rechazados. Revisa tu perfil.'
                              : 'Tus documentos están en revisión. Una vez aprobados podrás acceder a tu cuenta de trabajador.',
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
