class Withdrawal {
  final String id;
  final String commissionnaireId;
  final double amount;
  final String currency;
  final String phoneNumber;
  final WithdrawalStatus status;
  final String? rejectionReason;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Withdrawal({
    required this.id,
    required this.commissionnaireId,
    required this.amount,
    required this.currency,
    required this.phoneNumber,
    required this.status,
    this.rejectionReason,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'],
      commissionnaireId: json['commissionnaireId'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      phoneNumber: json['phoneNumber'],
      status: WithdrawalStatus.fromString(json['status']),
      rejectionReason: json['rejectionReason'],
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commissionnaireId': commissionnaireId,
      'amount': amount,
      'currency': currency,
      'phoneNumber': phoneNumber,
      'status': status.value,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum WithdrawalStatus {
  pending('pending'),
  approved('approved'),
  processing('processing'),
  completed('completed'),
  rejected('rejected'),
  failed('failed');

  const WithdrawalStatus(this.value);
  final String value;

  static WithdrawalStatus fromString(String value) {
    return WithdrawalStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => WithdrawalStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case WithdrawalStatus.pending:
        return 'En attente';
      case WithdrawalStatus.approved:
        return 'Approuvé';
      case WithdrawalStatus.processing:
        return 'En cours';
      case WithdrawalStatus.completed:
        return 'Terminé';
      case WithdrawalStatus.rejected:
        return 'Rejeté';
      case WithdrawalStatus.failed:
        return 'Échoué';
    }
  }
}