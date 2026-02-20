import 'city.dart';

class Town {
  final String id;
  final String name;
  final String? zipCode;
  final bool isActive;
  final String cityId;
  final String cityName;
  final String provinceName;
  final String countryName;
  final String fullName;
  final DateTime createdAt;
  final City? city;

  Town({
    required this.id,
    required this.name,
    this.zipCode,
    required this.isActive,
    required this.cityId,
    required this.cityName,
    required this.provinceName,
    required this.countryName,
    required this.fullName,
    required this.createdAt,
    this.city,
  });

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      id: json['id'],
      name: json['name'],
      zipCode: json['zipCode'],
      isActive: json['isActive'],
      cityId: json['cityId'],
      cityName: json['cityName'],
      provinceName: json['provinceName'],
      countryName: json['countryName'],
      fullName: json['fullName'],
      createdAt: DateTime.parse(json['createdAt']),
      city: json['city'] != null ? City.fromJson(json['city']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'zipCode': zipCode,
      'isActive': isActive,
      'cityId': cityId,
      'cityName': cityName,
      'provinceName': provinceName,
      'countryName': countryName,
      'fullName': fullName,
      'city': city?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
