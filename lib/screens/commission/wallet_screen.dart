import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/commission_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'withdrawals_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommissionProvider>(context, listen: false).loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mon Wallet',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).textTheme.displayLarge?.color,
              size: 20,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<CommissionProvider>(context, listen: false).loadWallet();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Consumer<CommissionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingWallet) {
                return _buildLoadingSkeleton();
              }

              final wallet = provider.wallet;
              if (wallet == null) {
                return _buildErrorState();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBalanceCard(wallet),
                  const SizedBox(height: 20),
                  _buildStatsGrid(wallet),
                  const SizedBox(height: 20),
                  _buildActionButtons(wallet),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(wallet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  wallet.currency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            wallet.walletBalance.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            wallet.canWithdraw 
                ? 'Prêt pour retrait'
                : 'Aucun montant disponible',
            style: TextStyle(
              color: wallet.canWithdraw ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(wallet) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Gains totaux',
          value: '${wallet.totalEarnings.toStringAsFixed(2)} ${wallet.currency}',
          icon: CupertinoIcons.money_dollar_circle,
          color: AppColors.success,
        ),
        _buildStatCard(
          title: 'En attente',
          value: '${wallet.pendingCommissions} commission${wallet.pendingCommissions > 1 ? 's' : ''}',
          icon: CupertinoIcons.clock,
          color: AppColors.warning,
        ),
        _buildStatCard(
          title: 'Vérifiées',
          value: '${wallet.verifiedCount} commission${wallet.verifiedCount > 1 ? 's' : ''}',
          icon: CupertinoIcons.checkmark_circle,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.displayLarge?.color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(wallet) {
    return Column(
      children: [
        CustomButton(
          text: 'Demander un retrait',
          onPressed: wallet.canWithdraw ? () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WithdrawalsScreen(),
              ),
            );
          } : null,
          height: 52,
          fullWidth: true,
          icon: const Icon(CupertinoIcons.money_dollar_circle, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WithdrawalsScreen(showHistory: true),
              ),
            );
          },
          icon: const Icon(CupertinoIcons.list_bullet, size: 20),
          label: const Text('Historique des retraits'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.info_circle,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Comment ça marche ?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('1. Les visiteurs paient leurs visites'),
          _buildInfoItem('2. Vous recevez une commission automatiquement'),
          _buildInfoItem('3. Vérifiez avec le code OTP du visiteur'),
          _buildInfoItem('4. Le montant est ajouté à votre solde'),
          _buildInfoItem('5. Demandez un retrait quand vous voulez'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.info,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    
    return Column(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: List.generate(4, (index) {
            return Container(
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Impossible de charger les informations du wallet',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Réessayer',
            onPressed: () {
              Provider.of<CommissionProvider>(context, listen: false).loadWallet();
            },
            height: 44,
          ),
        ],
      ),
    );
  }
}