import 'package:flutter/material.dart';
import '../models/auth_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setUser(AuthModel? user) {
    _user = user;
    _errorMessage = null;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
