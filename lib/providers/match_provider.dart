import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchProvider extends ChangeNotifier {
  List<MatchModel> _matches = [];

  List<MatchModel> get matches => List.unmodifiable(_matches);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setMatches(List<MatchModel> matches) {
    _matches = matches;
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
}
