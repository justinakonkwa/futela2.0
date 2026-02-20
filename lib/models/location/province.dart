import 'country.dart';

class Province {
  final String id;
  final String name;
  final String code;
  final bool isActive;
  final String countryId;
  final String countryName;
  final DateTime createdAt;
  final Country? country;

  Province({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.countryId,
    required this.countryName,
    required this.createdAt,
    this.country,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      isActive: json['isActive'],
      countryId: json['countryId'],
      countryName: json['countryName'],
      createdAt: DateTime.parse(json['createdAt']),
      country:
          json['country'] != null ? Country.fromJson(json['country']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'isActive': isActive,
      'countryId': countryId,
      'countryName': countryName,
      'country': country?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
