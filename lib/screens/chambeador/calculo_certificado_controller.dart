import 'package:flutter/material.dart';
import 'dart:io';

class CalculoCertificadoController extends ChangeNotifier {
  String _idNumber = '';
  File? _frontImage;
  File? _backImage;

  String get idNumber => _idNumber;
  File? get frontImage => _frontImage;
  File? get backImage => _backImage;

  void updateIdNumber(String value) {
    _idNumber = value;
    notifyListeners();
  }

  void updateFrontImage(File? image) {
    _frontImage = image;
    notifyListeners();
  }

  void updateBackImage(File? image) {
    _backImage = image;
    notifyListeners();
  }
}
