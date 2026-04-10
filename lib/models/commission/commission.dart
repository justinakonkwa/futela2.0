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
      id: json['id'],
      commissionnaireId: json['commissionnaireId'],
      visitId: json['visitId'],
      propertyId: json['propertyId'],
      visitorId: json['visitorId'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: CommissionStatus.fromString(json['status']),
      verificationCode: json['verificationCode'],
      codeExpiresAt: json['codeExpiresAt'] != null 
          ? DateTime.parse(json['codeExpiresAt']) 
          : null,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt']) 
          : null,
      failedAttempts: json['failedAttempts'] ?? 0,
      isLocked: json['isLocked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
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