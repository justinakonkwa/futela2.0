class CommissionnaireWallet {
  final double totalEarnings;
  final int pendingCommissions;   // nombre de commissions en attente (count)
  final int verifiedCount;        // nombre de commissions vérifiées
  final double walletBalance;
  final String currency;
  // Champs étendus (si disponibles)
  final double totalWithdrawn;
  final double pendingWithdrawals;
  final int totalCommissions;

  CommissionnaireWallet({
    required this.totalEarnings,
    required this.pendingCommissions,
    required this.verifiedCount,
    required this.walletBalance,
    required this.currency,
    this.totalWithdrawn = 0,
    this.pendingWithdrawals = 0,
    this.totalCommissions = 0,
  });

  factory CommissionnaireWallet.fromJson(Map<String, dynamic> json) {
    return CommissionnaireWallet(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      pendingCommissions: (json['pendingCommissions'] as num?)?.toInt() ?? 0,
      verifiedCount: (json['verifiedCount'] as num?)?.toInt() ??
          (json['verifiedCommissions'] as num?)?.toInt() ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      pendingWithdrawals: (json['pendingWithdrawals'] as num?)?.toDouble() ?? 0.0,
      totalCommissions: (json['totalCommissions'] as num?)?.toInt() ?? 0,
    );
  }

  factory CommissionnaireWallet.empty() {
    return CommissionnaireWallet(
      totalEarnings: 0,
      pendingCommissions: 0,
      verifiedCount: 0,
      walletBalance: 0,
      currency: 'USD',
    );
  }

  bool get canWithdraw => walletBalance > 0;
}