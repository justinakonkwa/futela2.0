class CommissionnaireWallet {
  final double totalEarnings;
  final double pendingCommissions;
  final double totalWithdrawn;
  final double pendingWithdrawals;
  final double walletBalance;
  final String currency;
  final int totalCommissions;
  final int verifiedCommissions;

  CommissionnaireWallet({
    required this.totalEarnings,
    required this.pendingCommissions,
    required this.totalWithdrawn,
    required this.pendingWithdrawals,
    required this.walletBalance,
    required this.currency,
    required this.totalCommissions,
    required this.verifiedCommissions,
  });

  factory CommissionnaireWallet.fromJson(Map<String, dynamic> json) {
    return CommissionnaireWallet(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      pendingCommissions: (json['pendingCommissions'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      pendingWithdrawals: (json['pendingWithdrawals'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      totalCommissions: (json['totalCommissions'] as num?)?.toInt() ?? 0,
      verifiedCommissions: (json['verifiedCommissions'] as num?)?.toInt() ?? 0,
    );
  }

  /// Wallet vide par défaut quand l'endpoint n'est pas disponible
  factory CommissionnaireWallet.empty() {
    return CommissionnaireWallet(
      totalEarnings: 0,
      pendingCommissions: 0,
      totalWithdrawn: 0,
      pendingWithdrawals: 0,
      walletBalance: 0,
      currency: 'USD',
      totalCommissions: 0,
      verifiedCommissions: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'pendingCommissions': pendingCommissions,
      'totalWithdrawn': totalWithdrawn,
      'pendingWithdrawals': pendingWithdrawals,
      'walletBalance': walletBalance,
      'currency': currency,
      'totalCommissions': totalCommissions,
      'verifiedCommissions': verifiedCommissions,
    };
  }

  bool get canWithdraw => walletBalance > 0;
  
  double get pendingTotal => pendingCommissions + pendingWithdrawals;
}