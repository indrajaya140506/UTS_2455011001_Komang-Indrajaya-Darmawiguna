class CountryModel {
  final String name;
  final String code;
  final String? flagUrl;
  final String? region;

  const CountryModel({
    required this.name,
    required this.code,
    this.flagUrl,
    this.region,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['names']?['common'] ?? '',
      code: json['codes']?['alpha_2'] ?? '',
      flagUrl: json['flag']?['emoji'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'names': {'common': name},
      'codes': {'alpha_2': code},
      'flag': {'emoji': flagUrl},
      'region': region,
    };
  }
}
