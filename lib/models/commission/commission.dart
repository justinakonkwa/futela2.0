class Commission {
  final String id;
  final String visitId;
  final String? propertyTitle;
  final String? commissionnaireId;
  final String? commissionnaireName;
  final String? visitorId;
  final String? visitorName;
  final double commissionRate;
  final double commissionAmount;
  final double? platformFee;
  final String currency;
  final String verificationStatus;
  final String verificationStatusLabel;
  final String verificationStatusColor;
  final int failedAttempts;
  final bool isLocked;
  final DateTime? verifiedAt;
  final DateTime? attributedAt;
  final DateTime createdAt;

  Commission({
    required this.id,
    required this.visitId,
    this.propertyTitle,
    this.commissionnaireId,
    this.commissionnaireName,
    this.visitorId,
    this.visitorName,
    required this.commissionRate,
    required this.commissionAmount,
    this.platformFee,
    required this.currency,
    required this.verificationStatus,
    required this.verificationStatusLabel,
    required this.verificationStatusColor,
    required this.failedAttempts,
    required this.isLocked,
    this.verifiedAt,
    this.attributedAt,
    required this.createdAt,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      id: json['id']?.toString() ?? '',
      visitId: json['visitId']?.toString() ?? '',
      propertyTitle: json['propertyTitle']?.toString(),
      commissionnaireId: json['commissionnaireId']?.toString(),
      commissionnaireName: json['commissionnaireName']?.toString(),
      visitorId: json['visitorId']?.toString(),
      visitorName: json['visitorName']?.toString(),
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.0,
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platformFee'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      verificationStatus: json['verificationStatus']?.toString() ?? 'pending',
      verificationStatusLabel: json['verificationStatusLabel']?.toString() ?? '',
      verificationStatusColor: json['verificationStatusColor']?.toString() ?? 'grey',
      failedAttempts: (json['failedAttempts'] as num?)?.toInt() ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
      verifiedAt: _parseDate(json['verifiedAt']),
      attributedAt: _parseDate(json['attributedAt']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString().replaceAll(' ', ''));
    } catch (_) {
      return null;
    }
  }

  bool get isVerified => verificationStatus == 'verified';
  bool get isCodeSent => verificationStatus == 'code_sent';
  bool get isPending => verificationStatus == 'pending';
  bool get canVerify => isCodeSent && !isLocked;

  String get displayAmount => '${commissionAmount.toStringAsFixed(2)} $currency';
}
