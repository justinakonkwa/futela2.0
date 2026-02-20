class Address {
  final String id;
  final String street;
  final String? number;
  final String? additionalInfo;
  final double? latitude;
  final double? longitude;
  final bool hasCoordinates;
  final String townId;
  final String townName;
  final String? cityId;
  final String cityName;
  final String provinceName;
  final String countryName;
  final String? districtId;
  final String? districtName;
  final String formattedAddress;
  final String? shortAddress;
  final DateTime createdAt;

  Address({
    required this.id,
    required this.street,
    this.number,
    this.additionalInfo,
    this.latitude,
    this.longitude,
    required this.hasCoordinates,
    required this.townId,
    required this.townName,
    this.cityId,
    required this.cityName,
    required this.provinceName,
    required this.countryName,
    this.districtId,
    this.districtName,
    required this.formattedAddress,
    this.shortAddress,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    // Gérer les formats imbriqués (town: {id, name}, city: {id, name})
    final townData = json['town'] is Map ? json['town'] as Map<String, dynamic> : null;
    final cityData = json['city'] is Map ? json['city'] as Map<String, dynamic> : null;
    final provinceData = json['province'] is Map ? json['province'] as Map<String, dynamic> : null;
    final countryData = json['country'] is Map ? json['country'] as Map<String, dynamic> : null;
    final districtData = json['district'] is Map ? json['district'] as Map<String, dynamic> : null;

    // Extraire les valeurs des formats plats ou imbriqués
    final townId = json['townId']?.toString() ?? townData?['id']?.toString() ?? '';
    final townName = json['townName']?.toString() ?? townData?['name']?.toString() ?? '';
    final cityId = json['cityId']?.toString() ?? cityData?['id']?.toString();
    final cityName = json['cityName']?.toString() ?? cityData?['name']?.toString() ?? '';
    final provinceName = json['provinceName']?.toString() ?? provinceData?['name']?.toString() ?? '';
    final countryName = json['countryName']?.toString() ?? countryData?['name']?.toString() ?? '';
    final districtId = json['districtId']?.toString() ?? districtData?['id']?.toString();
    final districtName = json['districtName']?.toString() ?? districtData?['name']?.toString();

    // Construire formattedAddress si absent
    String formattedAddress = json['formattedAddress']?.toString() ?? '';
    if (formattedAddress.isEmpty) {
      final parts = <String>[];
      if (json['street']?.toString().isNotEmpty == true) parts.add(json['street'].toString());
      if (json['number']?.toString().isNotEmpty == true) parts.add(json['number'].toString());
      if (districtName?.isNotEmpty == true) parts.add(districtName!);
      if (townName.isNotEmpty) parts.add(townName);
      if (cityName.isNotEmpty) parts.add(cityName);
      if (provinceName.isNotEmpty) parts.add(provinceName);
      if (countryName.isNotEmpty) parts.add(countryName);
      formattedAddress = parts.join(', ');
    }

    return Address(
      id: json['id']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      number: json['number']?.toString(),
      additionalInfo: json['additionalInfo']?.toString(),
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      hasCoordinates: json['hasCoordinates'] ?? (json['latitude'] != null && json['longitude'] != null),
      townId: townId,
      townName: townName,
      cityId: cityId,
      cityName: cityName,
      provinceName: provinceName,
      countryName: countryName,
      districtId: districtId,
      districtName: districtName,
      formattedAddress: formattedAddress,
      shortAddress: json['shortAddress']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(), // Fallback
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'number': number,
      'additionalInfo': additionalInfo,
      'latitude': latitude,
      'longitude': longitude,
      'hasCoordinates': hasCoordinates,
      'townId': townId,
      'townName': townName,
      'cityId': cityId,
      'cityName': cityName,
      'provinceName': provinceName,
      'countryName': countryName,
      'districtId': districtId,
      'districtName': districtName,
      'formattedAddress': formattedAddress,
      'shortAddress': shortAddress,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
