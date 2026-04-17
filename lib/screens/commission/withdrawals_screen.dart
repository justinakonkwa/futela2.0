import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/commission_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class WithdrawalsScreen extends StatefulWidget {
  final bool showHistory;
  
  const WithdrawalsScreen({
    super.key,
    this.showHistory = false,
  });

  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.showHistory ? 1 : 0,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CommissionProvider>(context, listen: false);
      provider.loadWithdrawals();
      if (!widget.showHistory) {
        provider.loadWallet();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Retraits',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Nouveau retrait'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewWithdrawalTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildNewWithdrawalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Consumer<CommissionProvider>(
        builder: (context, provider, child) {
          final wallet = provider.wallet;
          
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wallet != null) _buildBalanceCard(wallet),
                const SizedBox(height: 20),
                _buildWithdrawalForm(wallet),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(wallet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.success, Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solde disponible',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${wallet.walletBalance.toStringAsFixed(2)} ${wallet.currency}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                wallet.canWithdraw 
                    ? CupertinoIcons.checkmark_circle_fill 
                    : CupertinoIcons.exclamationmark_circle_fill,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                wallet.canWithdraw 
                    ? 'Prêt pour retrait'
                    : 'Solde insuffisant',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm(wallet) {
    final canWithdraw = wallet?.canWithdraw ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _amountController,
          label: 'Montant à retirer',
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIconData: CupertinoIcons.money_dollar,
          suffixIcon: wallet != null ? Text(
            wallet.currency,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ) : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un montant';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Montant invalide';
            }
            if (wallet != null && amount > wallet.walletBalance) {
              return 'Montant supérieur au solde disponible';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: 'Numéro Mobile Money',
          hint: '+243 812 345 678',
          keyboardType: TextInputType.phone,
          prefixIconData: CupertinoIcons.device_phone_portrait,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre numéro Mobile Money';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Container(
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
                    'Informations importantes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoItem('• Les retraits sont traités manuellement'),
              _buildInfoItem('• Délai de traitement : 24-48h ouvrables'),
              _buildInfoItem('• Vérifiez votre numéro Mobile Money'),
              _buildInfoItem('• Aucuns frais de retrait'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Consumer<CommissionProvider>(
          builder: (context, provider, child) {
            return CustomButton(
              text: 'Demander le retrait',
              onPressed: canWithdraw ? () => _requestWithdrawal(provider) : null,
              height: 52,
              fullWidth: true,
              icon: const Icon(CupertinoIcons.arrow_up_circle, color: Colors.white, size: 20),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.info,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<CommissionProvider>(context, listen: false)
            .loadWithdrawals(refresh: true);
      },
      child: Consumer<CommissionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingWithdrawals) {
            return _buildHistorySkeleton();
          }

          if (provider.withdrawals.isEmpty) {
            return _buildEmptyHistory();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.withdrawals.length,
            itemBuilder: (context, index) {
              final withdrawal = provider.withdrawals[index];
              return _buildWithdrawalCard(withdrawal);
            },
          );
        },
      ),
    );
  }

  Widget _buildWithdrawalCard(withdrawal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
              Text(
                '${withdrawal.amount.toStringAsFixed(2)} ${withdrawal.currency}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(withdrawal.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(withdrawal.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  withdrawal.status.displayName,
                  style: TextStyle(
                    color: _getStatusColor(withdrawal.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.device_phone_portrait,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 8),
              Text(
                withdrawal.phoneNumber,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(withdrawal.createdAt),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (withdrawal.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      withdrawal.rejectionReason!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistorySkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildEmptyHistory() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.arrow_up_circle,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun retrait',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos demandes de retrait apparaîtront ici',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestWithdrawal(CommissionProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final phoneNumber = _phoneController.text.trim();

    final success = await provider.requestWithdrawal(
      amount: amount,
      phoneNumber: phoneNumber,
    );

    if (success && mounted) {
      _showSuccessDialog();
      _amountController.clear();
      _phoneController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la demande de retrait'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.success,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Demande envoyée !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre demande de retrait a été envoyée. Vous recevrez une notification une fois traitée.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Voir l\'historique',
            onPressed: () {
              Navigator.of(context).pop();
              _tabController.animateTo(1);
            },
            height: 44,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(status) {
    switch (status.value) {
      case 'completed':
        return AppColors.success;
      case 'approved':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}