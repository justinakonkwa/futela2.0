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
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      pendingCommissions: (json['pendingCommissions'] as num).toDouble(),
      totalWithdrawn: (json['totalWithdrawn'] as num).toDouble(),
      pendingWithdrawals: (json['pendingWithdrawals'] as num).toDouble(),
      walletBalance: (json['walletBalance'] as num).toDouble(),
      currency: json['currency'],
      totalCommissions: json['totalCommissions'] ?? 0,
      verifiedCommissions: json['verifiedCommissions'] ?? 0,
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