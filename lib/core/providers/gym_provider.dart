import 'package:flutter/material.dart';

class GymProvider extends ChangeNotifier {
  String? _currentGymId;
  String? _currentGymName;

  String? get currentGymId => _currentGymId;
  String? get currentGymName => _currentGymName;

  void setGym(String id, String name) {
    _currentGymId = id;
    _currentGymName = name;
    notifyListeners();
  }
}
