class ClubModel {
  final String id;
  final String clubName;
  final String coachName;
  final String? logoUrl;
  final String? description;
  final DateTime? createdAt;

  const ClubModel({
    required this.id,
    required this.clubName,
    required this.coachName,
    this.logoUrl,
    this.description,
    this.createdAt,
  });

  // Mengubah data JSON menjadi objek ClubModel
  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id']?.toString() ?? '',
      clubName: json['club_name'] ?? '',
      coachName: json['coach_name'] ?? '',
      logoUrl: json['logo_url'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  // Mengubah objek ClubModel menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_name': clubName,
      'coach_name': coachName,
      'logo_url': logoUrl,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
