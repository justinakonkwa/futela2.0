class Country {
  final String id;
  final String name;
  final String code;
  final String phoneCode;
  final bool isActive;
  final DateTime createdAt;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.phoneCode,
    required this.isActive,
    required this.createdAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      phoneCode: json['phoneCode'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'phoneCode': phoneCode,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
