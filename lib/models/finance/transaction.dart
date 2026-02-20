class Transaction {
  final String id;
  final String walletId;
  final String type; // payment, deposit, withdrawal
  final double amount;
  final String currency;
  final String status;
  final String gateway;
  final String? externalId;
  final String? description;
  final String? relatedEntity;
  final String? relatedEntityType;
  final DateTime? processedAt;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.gateway,
    this.externalId,
    this.description,
    this.relatedEntity,
    this.relatedEntityType,
    this.processedAt,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      walletId: json['walletId'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      gateway: json['gateway'],
      externalId: json['externalId'],
      description: json['description'],
      relatedEntity: json['relatedEntity'],
      relatedEntityType: json['relatedEntityType'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'gateway': gateway,
      'externalId': externalId,
      'description': description,
      'relatedEntity': relatedEntity,
      'relatedEntityType': relatedEntityType,
      'processedAt': processedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
