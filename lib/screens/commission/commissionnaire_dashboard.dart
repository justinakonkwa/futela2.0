import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/commission_provider.dart';
import '../../utils/app_colors.dart';
import 'commission_verification_screen.dart';
import 'wallet_screen.dart';
import 'commissions_list_screen.dart';
import 'withdrawals_screen.dart';

class CommissionnaireDashboard extends StatefulWidget {
  const CommissionnaireDashboard({super.key});

  @override
  State<CommissionnaireDashboard> createState() => _CommissionnaireDashboardState();
}

class _CommissionnaireDashboardState extends State<CommissionnaireDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<CommissionProvider>(context, listen: false);
    await Future.wait([
      provider.loadWallet(),
      provider.loadCommissions(refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Commissionnaire',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWalletCard(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildRecentCommissions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Consumer<CommissionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingWallet) {
          return _buildWalletSkeleton();
        }

        final wallet = provider.wallet;
        if (wallet == null) {
          return _buildErrorCard('Erreur de chargement du wallet');
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Solde disponible',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WalletScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      CupertinoIcons.info_circle,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${wallet.walletBalance.toStringAsFixed(2)} ${wallet.currency}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildWalletStat(
                      'Gains totaux',
                      '${wallet.totalEarnings.toStringAsFixed(2)} ${wallet.currency}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWalletStat(
                      'En attente',
                      '${wallet.pendingCommissions.toStringAsFixed(2)} ${wallet.currency}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletSkeleton() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: CupertinoIcons.qrcode_viewfinder,
                title: 'Vérifier code',
                subtitle: 'Scanner le code OTP',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CommissionVerificationScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer<CommissionProvider>(
                builder: (context, provider, child) {
                  final canWithdraw = provider.wallet?.canWithdraw ?? false;
                  return _buildActionCard(
                    icon: CupertinoIcons.money_dollar_circle,
                    title: 'Retirer',
                    subtitle: 'Demander un retrait',
                    onTap: canWithdraw ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WithdrawalsScreen(),
                        ),
                      );
                    } : null,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? AppColors.border : Colors.grey[300]!,
          ),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isEnabled ? AppColors.primary : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isEnabled ? AppColors.textPrimary : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled ? AppColors.textSecondary : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCommissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Commissions récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CommissionsListScreen(),
                  ),
                );
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<CommissionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingCommissions) {
              return _buildCommissionsSkeleton();
            }

            final recentCommissions = provider.commissions.take(3).toList();
            
            if (recentCommissions.isEmpty) {
              return _buildEmptyCommissions();
            }

            return Column(
              children: recentCommissions.map((commission) {
                return _buildCommissionCard(commission);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommissionCard(commission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(commission.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(commission.status),
              color: _getStatusColor(commission.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${commission.amount.toStringAsFixed(2)} ${commission.currency}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  commission.status.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(commission.status),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(commission.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionsSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyCommissions() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            CupertinoIcons.doc_text,
            size: 48,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'Aucune commission',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos commissions apparaîtront ici',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(status) {
    switch (status.value) {
      case 'verified':
        return AppColors.success;
      case 'code_sent':
        return AppColors.warning;
      case 'pending':
        return AppColors.info;
      case 'expired':
      case 'locked':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(status) {
    switch (status.value) {
      case 'verified':
        return CupertinoIcons.checkmark_circle_fill;
      case 'code_sent':
        return CupertinoIcons.clock_fill;
      case 'pending':
        return CupertinoIcons.hourglass;
      case 'expired':
      case 'locked':
      case 'cancelled':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.circle;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}