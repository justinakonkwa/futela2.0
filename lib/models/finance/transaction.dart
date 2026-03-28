class Transaction {
  final String id;
  final String? userId;
  final String? userName;
  final String walletId;
  final String type; // payment, deposit, withdrawal
  final double amount;
  final String currency;
  final String status;
  final String? statusLabel;
  final String? statusColor;
  final String gateway;
  final String? externalId;
  final String? description;
  final String? relatedEntity;
  final String? relatedEntityType;
  final DateTime? processedAt;
  final DateTime createdAt;

  Transaction({
    required this.id,
    this.userId,
    this.userName,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.statusLabel,
    this.statusColor,
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
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      walletId: json['walletId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['statusLabel']?.toString(),
      statusColor: json['statusColor']?.toString(),
      gateway: json['gateway']?.toString() ?? '',
      externalId: json['externalId']?.toString(),
      description: json['description']?.toString(),
      relatedEntity: json['relatedEntity']?.toString(),
      relatedEntityType: json['relatedEntityType']?.toString(),
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'walletId': walletId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'statusLabel': statusLabel,
      'statusColor': statusColor,
      'gateway': gateway,
      'externalId': externalId,
      'description': description,
      'relatedEntity': relatedEntity,
      'relatedEntityType': relatedEntityType,
      'processedAt': processedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  String get displayStatus => statusLabel?.trim().isNotEmpty == true
      ? statusLabel!
      : status;
}

class PaginatedTransactionsResponse {
  final List<Transaction> member;
  final int totalItems;
  final int page;
  final int itemsPerPage;
  final int totalPages;

  PaginatedTransactionsResponse({
    required this.member,
    required this.totalItems,
    required this.page,
    required this.itemsPerPage,
    required this.totalPages,
  });

  factory PaginatedTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['member'] as List?) ?? const [];
    final list = raw
        .whereType<Map<String, dynamic>>()
        .map((e) => Transaction.fromJson(e))
        .toList();

    return PaginatedTransactionsResponse(
      member: list,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? list.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 30,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
