import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_model.dart';
import '../services/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  late final StreamSubscription<AuthState> _authSubscription;

  AuthModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser != null) {
      _user = _createAuthModel(currentUser);
    }

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final user = data.session?.user;

      if (user != null) {
        _user = _createAuthModel(user);
      } else {
        _user = null;
      }

      notifyListeners();
    });
  }

  AuthModel _createAuthModel(User user) {
    return AuthModel.fromJson({
      'user_id': user.id,
      'email': user.email ?? '',
      'created_at': user.createdAt,
      'last_sign_in_at': user.lastSignInAt,
    });
  }

  void _setAuthenticatedUser(User user) {
    _user = _createAuthModel(user);
    notifyListeners();
  }

  // Register
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
    } on AuthException catch (e) {
      if (e.code == 'user_already_exists') {
        _errorMessage = 'Email sudah terdaftar. Silakan login.';
      } else {
        _errorMessage = e.message;
      }

      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
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

  Future<void> restoreSession() async {
    final user = Supabase.instance.client.auth.currentUser;

    _user = user != null ? _createAuthModel(user) : null;
    notifyListeners();
  }

  // Logout
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

  // KOMPATIBILITAS DENGAN KODE LAMA
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

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
