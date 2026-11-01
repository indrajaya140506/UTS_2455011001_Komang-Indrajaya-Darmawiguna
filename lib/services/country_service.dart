import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/country_model.dart';

class CountryService {
  static const String _baseUrl = 'https://restcountries.com/v3.1';

  Future<List<CountryModel>> fetchCountries() async {
    final url = Uri.parse('$_baseUrl/all?fields=name,cca2,flags,region');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final countries = data
            .map((json) => CountryModel.fromJson(json as Map<String, dynamic>))
            .toList();

        countries.sort((a, b) => a.name.compareTo(b.name));

        return countries;
      }

      throw Exception('Gagal mengambil data negara: ${response.statusCode}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
