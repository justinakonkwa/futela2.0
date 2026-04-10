class PublicProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? avatar;
  final List<String> roles;
  final bool isVerified;
  final bool isAvailable;
  final bool isCertified;
  final String approvalStatus;
  final String? businessName;
  final int propertyCount;
  final DateTime createdAt;

  PublicProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.avatar,
    required this.roles,
    required this.isVerified,
    required this.isAvailable,
    required this.isCertified,
    required this.approvalStatus,
    this.businessName,
    required this.propertyCount,
    required this.createdAt,
  });

  bool get isCommissionnaire => roles.contains('ROLE_COMMISSIONNAIRE');

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    return PublicProfile(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatar: json['avatar'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isVerified: json['isVerified'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      isCertified: json['isCertified'] as bool? ?? false,
      approvalStatus: json['approvalStatus'] as String? ?? '',
      businessName: json['businessName'] as String?,
      propertyCount: json['propertyCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class PublicPropertyItem {
  final String id;
  final String type;
  final String title;
  final String description;
  final double? pricePerDay;
  final double? pricePerMonth;
  final bool isAvailable;
  final String? listingType;
  final String? photo;
  final String? town;
  final String? city;

  PublicPropertyItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.pricePerDay,
    this.pricePerMonth,
    required this.isAvailable,
    this.listingType,
    this.photo,
    this.town,
    this.city,
  });

  String get formattedPrice {
    final price = pricePerMonth ?? pricePerDay;
    if (price == null) return 'Prix non défini';
    return '\$${price.toStringAsFixed(0)}';
  }

  String get location {
    final parts = [town, city].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(', ');
  }

  factory PublicPropertyItem.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return PublicPropertyItem(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      pricePerMonth: (json['pricePerMonth'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? false,
      listingType: json['listingType'] as String?,
      photo: json['photo'] as String?,
      town: address?['town'] as String?,
      city: address?['city'] as String?,
    );
  }
}
