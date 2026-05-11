import 'package:flutter/material.dart';

enum UserRole { owner, trainer, member }

class NavigationProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.member;
  int _selectedIndex = 0;

  UserRole get currentRole => _currentRole;
  int get selectedIndex => _selectedIndex;

  void setRole(UserRole role) {
    _currentRole = role;
    _selectedIndex = 0;
    notifyListeners();
  }

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
