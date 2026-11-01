import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/auth_model.dart';
import '../services/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengubah data user Supabase menjadi AuthModel.
  void _setAuthenticatedUser(User user) {
    _user = AuthModel.fromJson({
      'user_id': user.id,
      'email': user.email ?? '',
      'created_at': user.createdAt,
      'last_sign_in_at': user.lastSignInAt,
    });

    notifyListeners();
  }

  // REGISTER

  Future<bool> register({
    required String clubName,
    required String password,
    required String coachName,
    Uint8List? logoBytes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signUp(
        clubName: clubName,
        password: password,
        coachName: coachName,
        logoBytes: logoBytes,
      );

      _setAuthenticatedUser(user);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // LOGIN
  Future<bool> login({
    required String clubName,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(
        clubName: clubName,
        password: password,
      );

      _setAuthenticatedUser(user);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MEMULIHKAN SESSION SAAT APLIKASI DIBUKA
  Future<void> restoreSession() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      _setAuthenticatedUser(user);
    }
  }

  // LOGOUT
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // METHOD UNTUK KOMPATIBILITAS DENGAN KODE LAMA
  void setUser(AuthModel? user) {
    _user = user;
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
}
