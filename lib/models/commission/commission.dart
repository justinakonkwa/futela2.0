class Commission {
  final String id;
  final String commissionnaireId;
  final String visitId;
  final String propertyId;
  final String visitorId;
  final double amount;
  final String currency;
  final CommissionStatus status;
  final String? verificationCode;
  final DateTime? codeExpiresAt;
  final DateTime? verifiedAt;
  final int failedAttempts;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Commission({
    required this.id,
    required this.commissionnaireId,
    required this.visitId,
    required this.propertyId,
    required this.visitorId,
    required this.amount,
    required this.currency,
    required this.status,
    this.verificationCode,
    this.codeExpiresAt,
    this.verifiedAt,
    required this.failedAttempts,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      id: json['id']?.toString() ?? '',
      commissionnaireId: json['commissionnaireId']?.toString() ?? '',
      visitId: json['visitId']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      visitorId: json['visitorId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      status: CommissionStatus.fromString(json['status']?.toString() ?? ''),
      verificationCode: json['verificationCode']?.toString(),
      codeExpiresAt: _parseDate(json['codeExpiresAt']),
      verifiedAt: _parseDate(json['verifiedAt']),
      failedAttempts: (json['failedAttempts'] as num?)?.toInt() ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      // Nettoyer les espaces dans les dates : "2026-04-10T15: 10: 16+02: 00" → "2026-04-10T15:10:16+02:00"
      final s = value.toString().replaceAll(' ', '');
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commissionnaireId': commissionnaireId,
      'visitId': visitId,
      'propertyId': propertyId,
      'visitorId': visitorId,
      'amount': amount,
      'currency': currency,
      'status': status.value,
      'verificationCode': verificationCode,
      'codeExpiresAt': codeExpiresAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'failedAttempts': failedAttempts,
      'isLocked': isLocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isCodeExpired {
    if (codeExpiresAt == null) return false;
    return DateTime.now().isAfter(codeExpiresAt!);
  }

  bool get canVerify {
    return status == CommissionStatus.codeSent && 
           !isLocked && 
           !isCodeExpired;
  }
}

enum CommissionStatus {
  pending('pending'),
  codeSent('code_sent'),
  verified('verified'),
  expired('expired'),
  locked('locked'),
  cancelled('cancelled');

  const CommissionStatus(this.value);
  final String value;

  static CommissionStatus fromString(String value) {
    return CommissionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CommissionStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case CommissionStatus.pending:
        return 'En attente';
      case CommissionStatus.codeSent:
        return 'Code envoyé';
      case CommissionStatus.verified:
        return 'Vérifiée';
      case CommissionStatus.expired:
        return 'Expirée';
      case CommissionStatus.locked:
        return 'Verrouillée';
      case CommissionStatus.cancelled:
        return 'Annulée';
    }
  }
}