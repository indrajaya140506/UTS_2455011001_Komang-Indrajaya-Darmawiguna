import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const List<Map<String, dynamic>> cities = [
    {'name': 'Jakarta', 'latitude': -6.2088, 'longitude': 106.8456},
    {'name': 'Bandung', 'latitude': -6.9175, 'longitude': 107.6191},
    {'name': 'Surabaya', 'latitude': -7.2575, 'longitude': 112.7521},
    {'name': 'Denpasar', 'latitude': -8.6705, 'longitude': 115.2126},
    {'name': 'Medan', 'latitude': 3.5952, 'longitude': 98.6722},
    {'name': 'Makassar', 'latitude': -5.1477, 'longitude': 119.4327},
  ];

  Future<List<WeatherModel>> fetchWeather() async {
    final results = await Future.wait(
      cities.map((city) => _fetchCityWeather(city)),
    );

    return results;
  }

  Future<WeatherModel> _fetchCityWeather(Map<String, dynamic> city) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': city['latitude'].toString(),
      'longitude': city['longitude'].toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
      'timezone': 'Asia/Jakarta',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil cuaca ${city['name']}. '
        'HTTP ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return WeatherModel.fromJson(data, city: city['name'] as String);
  }
}
