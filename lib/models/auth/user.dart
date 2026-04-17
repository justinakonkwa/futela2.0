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
  final DateTime? lastLoginAt;
  final bool isAvailable;
  final String? companyId;
  final String? companyName;
  
  // Champs pour commissionnaires
  final bool profileCompleted;
  final String? approvalStatus;
  final String? approvalStatusLabel;
  final String? approvalStatusColor;
  final String? idDocumentType;
  final String? idDocumentNumber;
  final String? idDocumentPhotoUrl;
  final String? selfiePhotoUrl;
  final String? businessName;
  final String? businessAddress;
  final String? taxId;

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
    this.lastLoginAt,
    this.isAvailable = false,
    this.companyId,
    this.companyName,
    this.profileCompleted = false,
    this.approvalStatus,
    this.approvalStatusLabel,
    this.approvalStatusColor,
    this.idDocumentType,
    this.idDocumentNumber,
    this.idDocumentPhotoUrl,
    this.selfiePhotoUrl,
    this.businessName,
    this.businessAddress,
    this.taxId,
  });

  /// Parses ISO8601 date string, tolerating spaces in time part (e.g. "08: 00: 00").
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    final s = value is String ? value.replaceAll(' ', '') : value.toString();
    return DateTime.parse(s);
  }

  static DateTime? _parseDateOptional(dynamic value) {
    if (value == null) return null;
    try {
      final s = value is String ? value.replaceAll(' ', '') : value.toString();
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final phoneRaw = json['phone'] ?? json['phoneNumber'];
    final phone = phoneRaw?.toString().trim();
    final phoneStr = (phone != null && phone.isNotEmpty) ? phone : null;
    final isVerified = json['isVerified'] == true;
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: phoneStr,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      isEmailVerified: json['isEmailVerified'] == true || (json['isEmailVerified'] == null && isVerified),
      isPhoneVerified: json['isPhoneVerified'] == true || (json['isPhoneVerified'] == null && isVerified),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      lastLoginAt: _parseDateOptional(json['lastLoginAt']),
      isAvailable: json['isAvailable'] == true,
      companyId: json['companyId'] as String?,
      companyName: json['companyName'] as String?,
      profileCompleted: json['profileCompleted'] == true,
      approvalStatus: json['approvalStatus'] as String?,
      approvalStatusLabel: json['approvalStatusLabel'] as String?,
      approvalStatusColor: json['approvalStatusColor'] as String?,
      idDocumentType: json['idDocumentType'] as String?,
      idDocumentNumber: json['idDocumentNumber'] as String?,
      idDocumentPhotoUrl: json['idDocumentPhotoUrl'] as String?,
      selfiePhotoUrl: json['selfiePhotoUrl'] as String?,
      businessName: json['businessName'] as String?,
      businessAddress: json['businessAddress'] as String?,
      taxId: json['taxId'] as String?,
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
    final fromNames = '$firstName $lastName'.trim();
    return fromNames.isNotEmpty ? fromNames : 'Utilisateur';
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
