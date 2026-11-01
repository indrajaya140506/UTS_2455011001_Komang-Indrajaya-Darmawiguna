class MatchModel {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamCode;
  final String awayTeamCode;
  final int? homeScore;
  final int? awayScore;
  final String category;

  const MatchModel({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamCode,
    required this.awayTeamCode,
    this.homeScore,
    this.awayScore,
    required this.category,
  });

  factory MatchModel.fromJson(
    Map<String, dynamic> json, {
    required String category,
  }) {
    final teamA = json['team_A'] as Map<String, dynamic>? ?? {};
    final teamB = json['team_B'] as Map<String, dynamic>? ?? {};

    final rawScores = json['scores'] as List<dynamic>? ?? [];

    // API mengirim skor dalam bentuk [[3, 1]].
    final List<dynamic> scores;

    if (rawScores.isNotEmpty && rawScores.first is List) {
      scores = rawScores.first as List<dynamic>;
    } else {
      scores = rawScores;
    }

    return MatchModel(
      id: json['mid']?.toString() ?? '',
      homeTeam: teamA['short_name']?.toString() ?? 'Unknown',
      awayTeam: teamB['short_name']?.toString() ?? 'Unknown',
      homeTeamCode: teamA['tla_name']?.toString() ?? '',
      awayTeamCode: teamB['tla_name']?.toString() ?? '',
      homeScore: scores.isNotEmpty ? int.tryParse(scores[0].toString()) : null,
      awayScore: scores.length > 1 ? int.tryParse(scores[1].toString()) : null,
      category: category,
    );
  }
}
