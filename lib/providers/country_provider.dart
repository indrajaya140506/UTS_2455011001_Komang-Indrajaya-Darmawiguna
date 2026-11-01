import 'package:flutter/material.dart';

import '../models/country_model.dart';
import '../services/country_service.dart';

class CountryProvider extends ChangeNotifier {
  final CountryService _countryService = CountryService();

  List<CountryModel> _countries = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<CountryModel> get countries => _countries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCountries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _countries = await _countryService.fetchCountries();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCountries(List<CountryModel> countries) {
    _countries = countries;
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
