import 'package:flutter/material.dart';
import '../models/country_model.dart';

class CountryProvider extends ChangeNotifier {
  List<CountryModel> _countries = [];

  List<CountryModel> get countries => List.unmodifiable(_countries);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setCountries(List<CountryModel> countries) {
    _countries = countries;
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
