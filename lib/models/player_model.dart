class PlayerModel {
  final String id;
  final String name;
  final int jerseyNumber;
  final String position;
  final double height;
  final String? countryName;
  final String? countryCode;
  final String? photoUrl;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.jerseyNumber,
    required this.position,
    required this.height,
    this.countryName,
    this.countryCode,
    this.photoUrl,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      jerseyNumber: (json['jersey_number'] as num?)?.toInt() ?? 0,
      position: json['position'] ?? '',
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      countryName: json['country_name'],
      countryCode: json['country_code'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'jersey_number': jerseyNumber,
      'position': position,
      'height': height,
      'country_name': countryName,
      'country_code': countryCode,
      'photo_url': photoUrl,
    };
  }
}
