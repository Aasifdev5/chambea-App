import 'package:flutter/material.dart';

class InformacionBasicaController extends ChangeNotifier {
  String _name = '';
  String _lastName = '';
  String _profession = '';
  String _birthDate = '';
  String _phone = '';
  String _email = '';
  String _gender = '';
  String _address = '';

  String get name => _name;
  String get lastName => _lastName;
  String get profession => _profession;
  String get birthDate => _birthDate;
  String get phone => _phone;
  String get email => _email;
  String get gender => _gender;
  String get address => _address;

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  void updateProfession(String value) {
    _profession = value;
    notifyListeners();
  }

  void updateBirthDate(String value) {
    _birthDate = value;
    notifyListeners();
  }

  void updatePhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void updateGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void updateAddress(String value) {
    _address = value;
    notifyListeners();
  }
}
