import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  // Function to launch WhatsApp
  Future<void> _launchWhatsApp() async {
    const whatsappUrl =
        "https://wa.me/1234567890"; // Replace with your WhatsApp number
    final Uri url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Soporte técnico',
          style: TextStyle(
            color: Colors.black,
            fontSize:
                screenWidth * 0.045, // Matches font size from previous screens
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Headset with question mark icon
                Icon(
                  Icons
                      .headset_mic, // Using a similar icon; you can replace with a custom SVG if needed
                  size: screenWidth * 0.3,
                  color: Colors.green,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Heading: "Consulta por WhatsApp"
                Text(
                  'Consulta por WhatsApp',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Description text
                Text(
                  'Solicita más información de forma rápida y directa a través de nuestro canal de WhatsApp. ¡Estamos para ayudarte!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                // WhatsApp Button
                ElevatedButton.icon(
                  onPressed: _launchWhatsApp,
                  icon: const Icon(
                    Icons
                        .chat, // Using a chat icon; replace with WhatsApp icon if you have it
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Canal de WhatsApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.038,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF25D366,
                    ), // WhatsApp green color
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
