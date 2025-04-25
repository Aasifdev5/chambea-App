import 'package:flutter/material.dart';

class PerfilChambeadorScreen extends StatefulWidget {
  @override
  _PerfilChambeadorScreenState createState() => _PerfilChambeadorScreenState();
}

class _PerfilChambeadorScreenState extends State<PerfilChambeadorScreen> {
  // State variables for profile fields
  String _aboutMe =
      'Soy un electricista con más de 10 años de experiencia, especializado en instalaciones y reparaciones. Me enorgullezco de ofrecer un servicio seguro y eficiente, garantizando la satisfacción de mis clientes en cada proyecto.';
  List<String> _skills = ['Instalación', 'Diagnóstico'];
  String _selectedCategory = 'Electricidad';
  Map<String, bool> _subcategories = {
    'Iluminación': true,
    'Cortocircuitos': false,
    'Tomacorrientes': false,
    'PANELES': true,
    'Seguridad': true,
    'Cableado': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed:
              () => Navigator.pop(context), // Navigate back to previous screen
        ),
        title: Text(
          'Perfil Chambeador',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Andrés Villamontes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Maquilladora',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Sobre mi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Soy un electricista con más de 10 años de experiencia...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              controller: TextEditingController(text: _aboutMe),
              onChanged: (value) {
                setState(() {
                  _aboutMe = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Habilidades*',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Placeholder for adding new skills
                    setState(() {
                      _skills.add('Nueva Habilidad ${_skills.length + 1}');
                    });
                  },
                  child: Text(
                    'Añadir',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children:
                  _skills
                      .asMap()
                      .entries
                      .map(
                        (entry) => Chip(
                          label: Text(entry.value),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _skills.removeAt(entry.key);
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Categorias de Servicio*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                hintText: 'Electricidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  ['Electricidad', 'Plomería', 'Carpintería']
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Subcategorías*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Placeholder for adding more subcategories
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Funcionalidad para añadir subcategorías'),
                  ),
                );
              },
              child: Text(
                'Añadir 3 subcategorías',
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
            ),
            ..._subcategories.entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: (value) {
                  setState(() {
                    _subcategories[entry.key] = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Save the profile details
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Perfil guardado')));
                Navigator.pop(
                  context,
                ); // Return to previous screen after saving
              },
              child: Text(
                'Guardar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
