import 'package:flutter/material.dart';

class MapPickerScreen extends StatelessWidget {
  const MapPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar ubicación en mapa')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simulate selected location
            Navigator.pop(context, 'Av. Siempre Viva 123, Ciudad Ejemplo');
          },
          child: const Text('Usar esta ubicación simulada'),
        ),
      ),
    );
  }
}
