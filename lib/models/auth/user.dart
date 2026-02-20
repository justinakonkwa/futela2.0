class User {
  final String id;
  final String email;
  final String? phoneNumber;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      roles: List<String>.from(json['roles'] ?? []),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Compatibility getters
  String get fullName {
    return '$firstName $lastName'.trim();
  }

  String get phone => phoneNumber ?? '';

  // Assuming the first role is the primary display role
  String get role => roles.isNotEmpty ? roles.first : 'User';

  // Placeholder for profile picture as it's not in the new API spec yet
  String? get profilePictureFilePath => null;
  bool get isIdVerified => false; // Placeholder if not in JSON

  // Getters required by screens
  String? get middleName => null; // Placeholder
}
