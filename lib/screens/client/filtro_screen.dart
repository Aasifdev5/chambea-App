import 'package:flutter/material.dart';

class FiltroScreen extends StatefulWidget {
  @override
  _FiltroScreenState createState() => _FiltroScreenState();
}

class _FiltroScreenState extends State<FiltroScreen> {
  bool _isAvailableToday = true;
  String? _selectedCategory;
  String? _selectedGender;
  String? _selectedExperience;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Filtro'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Disponibilidad', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Disponible hoy'),
                Switch(
                  value: _isAvailableToday,
                  onChanged: (value) => setState(() => _isAvailableToday = value),
                  activeColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Construcción'),
              value: 'Construcción',
              groupValue: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            RadioListTile<String>(
              title: const Text('Electricidad'),
              value: 'Electricidad',
              groupValue: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            RadioListTile<String>(
              title: const Text('Mantenimiento General'),
              value: 'Mantenimiento General',
              groupValue: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            RadioListTile<String>(
              title: const Text('Limpieza'),
              value: 'Limpieza',
              groupValue: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            RadioListTile<String>(
              title: const Text('Plomería'),
              value: 'Plomería',
              groupValue: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            RadioListTile<String>(
              title: const Text('Carpintería'),
              value: 'Carpintería',
              groupValue: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 16),
            const Text('Género', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Hombre'),
              value: 'Hombre',
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            RadioListTile<String>(
              title: const Text('Mujer'),
              value: 'Mujer',
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 16),
            const Text('Experiencia laboral (años)', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: _selectedExperience,
              hint: const Text('1 - 5 años'),
              items: ['1 - 5 años', '5 - 10 años', '10+ años'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (value) => setState(() => _selectedExperience = value),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: const Text('Aplicar filtro'),
            ),
          ],
        ),
      ),
    );
  }
}