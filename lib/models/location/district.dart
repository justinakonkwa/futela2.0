import 'town.dart';

class District {
  final String id;
  final String name;
  final bool isActive;
  final String townId;
  final String townName;
  final String? cityId;
  final String? cityName;
  final String fullName;
  final DateTime createdAt;
  final Town? town;

  District({
    required this.id,
    required this.name,
    required this.isActive,
    required this.townId,
    required this.townName,
    this.cityId,
    this.cityName,
    required this.fullName,
    required this.createdAt,
    this.town,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'],
      townId: json['townId'],
      townName: json['townName'],
      cityId: json['cityId'],
      cityName: json['cityName'],
      fullName: json['fullName'],
      createdAt: DateTime.parse(json['createdAt']),
      town: json['town'] != null ? Town.fromJson(json['town']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'townId': townId,
      'townName': townName,
      'cityId': cityId,
      'cityName': cityName,
      'fullName': fullName,
      'town': town?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
