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
      name: json['name']?['common'] ?? '',
      code: json['cca2'] ?? '',
      flagUrl: json['flags']?['png'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'cca2': code, 'flagUrl': flagUrl, 'region': region};
  }
}
