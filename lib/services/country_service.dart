import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country_model.dart';

class CountryService {
  static const String _baseUrl = 'https://api.restcountries.com/countries/v5';

  static const String _apiKey = 'rc_live_ebce34443fc142ff961aaa0ab2c57432';

  Future<List<CountryModel>> fetchCountries() async {
    try {
      final List<dynamic> allCountries = [];
      int offset = 0;
      bool hasMore = true;

      while (hasMore) {
        final url = Uri.parse(
          '$_baseUrl?limit=100&offset=$offset'
          '&response_fields=names.common,codes.alpha_2,flag.emoji',
        );

        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }

        final Map<String, dynamic> body = jsonDecode(response.body);

        final dynamic rawData = body['data'];

        final List<dynamic> pageData = rawData is Map
            ? (rawData['objects'] as List? ?? [])
            : [];

        if (pageData.isEmpty) break;

        allCountries.addAll(pageData);

        // META BERADA DI DALAM DATA
        final meta = rawData['meta'] as Map<String, dynamic>?;

        hasMore = meta?['more'] == true;

        offset += pageData.length;

        print('Offset: $offset');
        print('Masih ada data: $hasMore');
      }

      final countries = allCountries
          .map((json) => CountryModel.fromJson(json))
          .where(
            (country) => country.name.isNotEmpty && country.code.isNotEmpty,
          )
          .toList();

      countries.sort((a, b) => a.name.compareTo(b.name));

      print('Total negara berhasil dimuat: ${countries.length}');
      print('Indonesia ditemukan: ${countries.any((c) => c.code == 'ID')}');

      return countries;
    } catch (e) {
      throw Exception('Gagal mengambil data negara: $e');
    }
  }
}
