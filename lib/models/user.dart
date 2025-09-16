class User {
  final String id;
  final DateTime updatedTimestamp;
  final DateTime createdTimestamp;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String email;
  final String phone;
  final bool isIdVerified;
  final bool isDesactivated;
  final String? nationalId;
  final String? nationalIdType;
  final String? nationalIdPhotoFilePath;
  final String? profilePictureFilePath;
  final String role;

  User({
    required this.id,
    required this.updatedTimestamp,
    required this.createdTimestamp,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    required this.phone,
    required this.isIdVerified,
    required this.isDesactivated,
    this.nationalId,
    this.nationalIdType,
    this.nationalIdPhotoFilePath,
    this.profilePictureFilePath,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      updatedTimestamp: DateTime.parse(json['updatedTimestamp'] ?? DateTime.now().toIso8601String()),
      createdTimestamp: DateTime.parse(json['createdTimestamp'] ?? DateTime.now().toIso8601String()),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      middleName: json['middleName'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isIdVerified: json['isIdVerified'] ?? false,
      isDesactivated: json['isDesactivated'] ?? false,
      nationalId: json['nationalId'],
      nationalIdType: json['nationalIdType'],
      nationalIdPhotoFilePath: json['nationalIdPhotoFilePath'],
      profilePictureFilePath: json['profilePictureFilePath'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updatedTimestamp': updatedTimestamp.toIso8601String(),
      'createdTimestamp': createdTimestamp.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'email': email,
      'phone': phone,
      'isIdVerified': isIdVerified,
      'isDesactivated': isDesactivated,
      'nationalId': nationalId,
      'nationalIdType': nationalIdType,
      'nationalIdPhotoFilePath': nationalIdPhotoFilePath,
      'profilePictureFilePath': profilePictureFilePath,
      'role': role,
    };
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  User copyWith({
    String? id,
    DateTime? updatedTimestamp,
    DateTime? createdTimestamp,
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? phone,
    bool? isIdVerified,
    bool? isDesactivated,
    String? nationalId,
    String? nationalIdType,
    String? nationalIdPhotoFilePath,
    String? profilePictureFilePath,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      updatedTimestamp: updatedTimestamp ?? this.updatedTimestamp,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isIdVerified: isIdVerified ?? this.isIdVerified,
      isDesactivated: isDesactivated ?? this.isDesactivated,
      nationalId: nationalId ?? this.nationalId,
      nationalIdType: nationalIdType ?? this.nationalIdType,
      nationalIdPhotoFilePath: nationalIdPhotoFilePath ?? this.nationalIdPhotoFilePath,
      profilePictureFilePath: profilePictureFilePath ?? this.profilePictureFilePath,
      role: role ?? this.role,
    );
  }
}
