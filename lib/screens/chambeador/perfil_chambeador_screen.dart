import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_event.dart';
import 'package:chambea/blocs/chambeador/chambeador_state.dart';

class PerfilChambeadorScreen extends StatefulWidget {
  const PerfilChambeadorScreen({super.key});

  @override
  _PerfilChambeadorScreenState createState() => _PerfilChambeadorScreenState();
}

class _PerfilChambeadorScreenState extends State<PerfilChambeadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aboutMeController = TextEditingController();
  final _skillController = TextEditingController();
  final _subcategoryController = TextEditingController();
  String _selectedCategory = 'Plomería'; // Updated default to match API
  Map<String, bool> _subcategories = {};

  @override
  void initState() {
    super.initState();
    context.read<ChambeadorBloc>().add(FetchProfileEvent());
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    _skillController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ChambeadorBloc, ChambeadorState>(
      listener: (context, state) {
        print('Listener received state: $state'); // Debug
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (!state.isLoading) {
          _aboutMeController.text = state.aboutMe;
          _selectedCategory = state.category.isEmpty
              ? 'Plomería'
              : state.category;
          _subcategories = Map<String, bool>.from(state.subcategories);
          print('Updated _subcategories: $_subcategories'); // Debug
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
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
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.08,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: state.profilePhotoPath != null
                                  ? NetworkImage(state.profilePhotoPath!)
                                  : null,
                              child: state.profilePhotoPath == null
                                  ? Icon(
                                      Icons.person,
                                      size: screenWidth * 0.08,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.name} ${state.lastName}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  state.profession.isEmpty
                                      ? 'Profesión no especificada'
                                      : state.profession,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Sobre mi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _aboutMeController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                'Describe tu experiencia y habilidades...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Este campo es requerido' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
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
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Añadir Habilidad'),
                                    content: TextField(
                                      controller: _skillController,
                                      decoration: const InputDecoration(
                                        hintText: 'Ingresa una habilidad',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (_skillController
                                              .text
                                              .isNotEmpty) {
                                            final updatedSkills = [
                                              ...state.skills,
                                              _skillController.text,
                                            ];
                                            print(
                                              'Adding skill: ${updatedSkills.last}',
                                            ); // Debug
                                            context.read<ChambeadorBloc>().add(
                                              UpdateProfileEvent(
                                                name: state.name,
                                                lastName: state.lastName,
                                                profession: state.profession,
                                                birthDate: state.birthDate,
                                                phone: state.phone,
                                                email: state.email,
                                                gender: state.gender,
                                                address: state.address,
                                                aboutMe: state.aboutMe,
                                                skills: updatedSkills,
                                                category: state.category,
                                                subcategories: state
                                                    .subcategories
                                                    .keys
                                                    .where(
                                                      (key) => state
                                                          .subcategories[key]!,
                                                    )
                                                    .toList(),
                                              ),
                                            );
                                            _skillController.clear();
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Añadir'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                'Añadir',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          children: state.skills
                              .asMap()
                              .entries
                              .map(
                                (entry) => Chip(
                                  label: Text(entry.value),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    final updatedSkills = List<String>.from(
                                      state.skills,
                                    )..removeAt(entry.key);
                                    print(
                                      'Removing skill: ${entry.value}',
                                    ); // Debug
                                    context.read<ChambeadorBloc>().add(
                                      UpdateProfileEvent(
                                        name: state.name,
                                        lastName: state.lastName,
                                        profession: state.profession,
                                        birthDate: state.birthDate,
                                        phone: state.phone,
                                        email: state.email,
                                        gender: state.gender,
                                        address: state.address,
                                        aboutMe: state.aboutMe,
                                        skills: updatedSkills,
                                        category: state.category,
                                        subcategories: state.subcategories.keys
                                            .where(
                                              (key) =>
                                                  state.subcategories[key]!,
                                            )
                                            .toList(),
                                      ),
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Categorías de Servicio*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            hintText: 'Plomería',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['Electricidad', 'Plomería', 'Carpintería']
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
                          validator: (value) =>
                              value == null ? 'Este campo es requerido' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Subcategorías*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Añadir Subcategoría'),
                                content: TextField(
                                  controller: _subcategoryController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ingresa una subcategoría',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (_subcategoryController
                                          .text
                                          .isNotEmpty) {
                                        print(
                                          'Adding subcategory: ${_subcategoryController.text}',
                                        ); // Debug
                                        context.read<ChambeadorBloc>().add(
                                          AddSubcategoryEvent(
                                            subcategory:
                                                _subcategoryController.text,
                                          ),
                                        );
                                        _subcategoryController.clear();
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Añadir'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            'Añadir subcategoría',
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
                              final subcategoriesList = _subcategories.keys
                                  .where((key) => _subcategories[key]!)
                                  .toList();
                              print(
                                'Updating subcategory: ${entry.key} to $value',
                              ); // Debug
                              context.read<ChambeadorBloc>().add(
                                UpdateProfileEvent(
                                  name: state.name,
                                  lastName: state.lastName,
                                  profession: state.profession,
                                  birthDate: state.birthDate,
                                  phone: state.phone,
                                  email: state.email,
                                  gender: state.gender,
                                  address: state.address,
                                  aboutMe: _aboutMeController.text,
                                  skills: state.skills,
                                  category: _selectedCategory,
                                  subcategories: subcategoriesList,
                                ),
                              );
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                        SizedBox(height: screenHeight * 0.03),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                _subcategories.isNotEmpty) {
                              final subcategoriesList = _subcategories.keys
                                  .where((key) => _subcategories[key]!)
                                  .toList();
                              print(
                                'Saving profile with subcategories: $subcategoriesList',
                              ); // Debug
                              context.read<ChambeadorBloc>().add(
                                UpdateProfileEvent(
                                  name: state.name,
                                  lastName: state.lastName,
                                  profession: state.profession,
                                  birthDate: state.birthDate,
                                  phone: state.phone,
                                  email: state.email,
                                  gender: state.gender,
                                  address: state.address,
                                  aboutMe: _aboutMeController.text,
                                  skills: state.skills,
                                  category: _selectedCategory,
                                  subcategories: subcategoriesList,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil guardado'),
                                ),
                              );
                              Navigator.pushNamed(context, '/antecedentes');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, completa todos los campos requeridos y añade al menos una subcategoría',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Siguiente',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        const Center(
                          child: Text(
                            'Si tienes preguntas, por favor, contacte servicio de asistencia',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
