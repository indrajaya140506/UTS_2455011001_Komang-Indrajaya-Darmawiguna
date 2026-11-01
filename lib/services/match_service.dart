import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/match_model.dart';

class MatchService {
  static const String _baseUrl = 'https://live-volleyball-api.com/api/v1';

  // ID League VNL Men dan Women
  static const String _menLeagueId = '648ba992-eaff-4874-a00b-1d70bab76cb1';

  static const String _womenLeagueId = 'f9e7282d-35fc-ed46-afab-b5e5a460cb12';

  // ID Season 2026
  static const String _menSeasonId = '43b7fda2-ec3d-4222-9af3-2bb00a6a510d';

  static const String _womenSeasonId = '205c4779-51c0-4aa6-a1d4-e657264d74d2';

  //api key
  static const String _apiKey =
      '9db8e3cca9c85aea710acf661b66cbba152dd467a9bbc97e';

  Future<List<MatchModel>> fetchMatches() async {
    try {
      final results = await Future.wait([
        _fetchLeagueFixtures(
          leagueId: _menLeagueId,
          seasonId: _menSeasonId,
          category: 'Men',
        ),
        _fetchLeagueFixtures(
          leagueId: _womenLeagueId,
          seasonId: _womenSeasonId,
          category: 'Women',
        ),
      ]);

      return [...results[0], ...results[1]];
    } catch (e) {
      throw Exception('Gagal mengambil data pertandingan: $e');
    }
  }

  Future<List<MatchModel>> _fetchLeagueFixtures({
    required String leagueId,
    required String seasonId,
    required String category,
  }) async {
    final uri = Uri.parse('$_baseUrl/league_fixtures').replace(
      queryParameters: {
        'api_key': _apiKey,
        'league_id': leagueId,
        'season_id': seasonId,
        'lang': 'en',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode} saat mengambil VNL $category',
      );
    }

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (responseData['success'] != true) {
      throw Exception('API VNL $category mengembalikan kegagalan.');
    }

    final List<MatchModel> matches = [];

    void parseFixtures(dynamic item) {
      if (item == null) return;

      if (item is List) {
        for (final child in item) {
          parseFixtures(child);
        }
        return;
      }

      if (item is Map<String, dynamic>) {
        if (item.containsKey('team_A') && item.containsKey('team_B')) {
          matches.add(MatchModel.fromJson(item, category: category));
          return;
        }

        for (final value in item.values) {
          if (value is List || value is Map<String, dynamic>) {
            parseFixtures(value);
          }
        }
      }
    }

    parseFixtures(responseData['data']);

    return matches;
  }
}
