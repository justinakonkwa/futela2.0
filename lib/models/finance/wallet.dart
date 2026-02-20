class Wallet {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final bool isActive;
  final DateTime? lastTransactionAt;
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.isActive,
    this.lastTransactionAt,
    required this.createdAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'],
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'],
      isActive: json['isActive'],
      lastTransactionAt: json['lastTransactionAt'] != null
          ? DateTime.parse(json['lastTransactionAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      'lastTransactionAt': lastTransactionAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
