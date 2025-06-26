import 'package:flutter/material.dart';

class PerfilChambeadorController extends ChangeNotifier {
  String _aboutMe = '';
  List<String> _skills = [];
  String _category = '';
  Map<String, bool> _subcategories = {};

  String get aboutMe => _aboutMe;
  List<String> get skills => _skills;
  String get category => _category;
  Map<String, bool> get subcategories => _subcategories;

  void updateAboutMe(String value) {
    _aboutMe = value;
    notifyListeners();
  }

  void addSkill(String skill) {
    _skills.add(skill);
    notifyListeners();
  }

  void removeSkill(int index) {
    _skills.removeAt(index);
    notifyListeners();
  }

  void updateCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void updateSubcategory(String key, bool value) {
    _subcategories[key] = value;
    notifyListeners();
  }
}
