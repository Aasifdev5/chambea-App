import 'package:flutter/material.dart';
import 'dart:io';

class AntecedentesController extends ChangeNotifier {
  File? _certificate;

  File? get certificate => _certificate;

  void updateCertificate(File file) {
    _certificate = file;
    notifyListeners();
  }
}
