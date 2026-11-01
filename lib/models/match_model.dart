class MatchModel {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final String? competition;
  final DateTime? matchDate;
  final String? status;
  final int? homeScore;
  final int? awayScore;

  const MatchModel({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo,
    this.awayTeamLogo,
    this.competition,
    this.matchDate,
    this.status,
    this.homeScore,
    this.awayScore,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id']?.toString() ?? '',
      homeTeam: json['home_team'] ?? '',
      awayTeam: json['away_team'] ?? '',
      homeTeamLogo: json['home_team_logo'],
      awayTeamLogo: json['away_team_logo'],
      competition: json['competition'],
      matchDate: json['match_date'] != null
          ? DateTime.tryParse(json['match_date'])
          : null,
      status: json['status'],
      homeScore: (json['home_score'] as num?)?.toInt(),
      awayScore: (json['away_score'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'home_team_logo': homeTeamLogo,
      'away_team_logo': awayTeamLogo,
      'competition': competition,
      'match_date': matchDate?.toIso8601String(),
      'status': status,
      'home_score': homeScore,
      'away_score': awayScore,
    };
  }
}
