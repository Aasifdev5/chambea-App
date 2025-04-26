import 'package:flutter/material.dart';

class BusquedaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Búsqueda'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildWorkerCard(
                  'Julio César Suárez',
                  'Limpieza',
                  '\$30/hr',
                  5.0,
                ),
                _buildWorkerCard('Lucille Garner', 'Limpieza', '\$30/hr', 5.0),
                _buildWorkerCard('Cesar Brooks', 'Limpieza', '\$30/hr', 5.0),
                _buildWorkerCard('Kellie Wise', 'Limpieza', '\$30/hr', 5.0),
                _buildWorkerCard('Wade Sanders', 'Limpieza', '\$30/hr', 5.0),
                _buildWorkerCard('Eugene Collins', 'Limpieza', '\$30/hr', 5.0),
                _buildWorkerCard('Emily Dean', 'Limpieza', '\$30/hr', 5.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(
    String name,
    String service,
    String price,
    double rating,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(service), Text(price)],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: const Color(0xFFFFC107),
            ), // Directly using the hex value

            Text(rating.toString()),
          ],
        ),
      ),
    );
  }
}
