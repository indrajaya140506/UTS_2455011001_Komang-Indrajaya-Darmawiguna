import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  List<WeatherModel> _weatherList = [];

  int _currentIndex = 0;

  bool _isLoading = false;
  String? _errorMessage;

  Timer? _cityTimer;
  Timer? _refreshTimer;

  List<WeatherModel> get weatherList => _weatherList;

  int get currentIndex => _currentIndex;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  WeatherModel? get currentWeather {
    if (_weatherList.isEmpty) return null;

    return _weatherList[_currentIndex];
  }

  // Mengambil data cuaca dari REST API.
  Future<void> fetchWeather() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _weatherService.fetchWeather();

      _weatherList = result;

      if (_currentIndex >= _weatherList.length) {
        _currentIndex = 0;
      }
    } catch (e) {
      _errorMessage = 'Gagal mengambil data cuaca.';
      debugPrint('Weather Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengganti kota setiap 3 detik.
  void startCityRotation() {
    _cityTimer?.cancel();

    _cityTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_weatherList.isEmpty) return;

      _currentIndex = (_currentIndex + 1) % _weatherList.length;
      notifyListeners();
    });
  }

  // Memperbarui data API setiap 15 menit.
  void startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      fetchWeather();
    });
  }

  // Memulai seluruh proses cuaca.
  Future<void> initialize() async {
    await fetchWeather();

    startCityRotation();
    startAutoRefresh();
  }

  // Menghentikan timer ketika provider tidak digunakan.
  @override
  void dispose() {
    _cityTimer?.cancel();
    _refreshTimer?.cancel();

    super.dispose();
  }
}
