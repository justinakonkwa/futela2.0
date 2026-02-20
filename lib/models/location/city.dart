import 'province.dart';

class City {
  final String id;
  final String name;
  final String? zipCode;
  final bool isActive;
  final String provinceId;
  final String provinceName;
  final String countryName;
  final DateTime createdAt;
  final Province? province;

  City({
    required this.id,
    required this.name,
    this.zipCode,
    required this.isActive,
    required this.provinceId,
    required this.provinceName,
    required this.countryName,
    required this.createdAt,
    this.province,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      zipCode: json['zipCode']?.toString(),
      isActive: json['isActive'] == true,
      provinceId: json['provinceId']?.toString() ?? '',
      provinceName: json['provinceName']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      province:
          json['province'] != null ? Province.fromJson(json['province']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'zipCode': zipCode,
      'isActive': isActive,
      'provinceId': provinceId,
      'provinceName': provinceName,
      'countryName': countryName,
      'province': province?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
