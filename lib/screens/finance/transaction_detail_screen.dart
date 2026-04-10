import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/finance/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/transaction_detail_shimmer.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Transaction? _tx;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = context.read<TransactionProvider>();
    final tx = await p.getTransactionDetail(widget.transactionId);
    if (!mounted) return;
    setState(() {
      _tx = tx;
      _loading = false;
    });
  }

  Color _colorFromStatus(String? c) {
    switch (c) {
      case 'green':
        return AppColors.success;
      case 'red':
        return AppColors.error;
      case 'yellow':
        return AppColors.warning;
      case 'blue':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'payment':
        return 'Paiement';
      case 'deposit':
        return 'Dépôt';
      case 'withdrawal':
        return 'Retrait';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Détail transaction',
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading)
              const TransactionDetailShimmer()
            else if (_tx == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.error.withValues(alpha: 0.1),
                              AppColors.error.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Transaction introuvable',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Impossible de charger les détails de cette transaction.',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Builder(builder: (context) {
                final tx = _tx!;
                final accent = _colorFromStatus(tx.statusColor);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card moderne
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.08),
                            accent.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    tx.isCompleted
                                        ? Icons.verified_rounded
                                        : tx.isFailed
                                            ? Icons.error_outline_rounded
                                            : Icons.schedule_rounded,
                                    color: accent,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _typeLabel(tx.type),
                                        style: const TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: accent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          tx.displayStatus,
                                          style: TextStyle(
                                            fontFamily: 'Gilroy',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Montant',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                                  style: const TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _SectionTitle(title: 'Informations'),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.tag_rounded,
                      label: 'Transaction',
                      value: tx.id,
                    ),
                    _InfoRow(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Wallet',
                      value: tx.walletId,
                    ),
                    if (tx.gateway.isNotEmpty)
                      _InfoRow(
                        icon: Icons.link_rounded,
                        label: 'Passerelle',
                        value: tx.gateway,
                      ),
                    if (tx.externalId != null && tx.externalId!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.receipt_long_rounded,
                        label: 'Réf. externe',
                        value: tx.externalId!,
                      ),
                    if (tx.description != null && tx.description!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.subject_rounded,
                        label: 'Description',
                        value: tx.description!,
                      ),
                    if (tx.relatedEntityType != null &&
                        tx.relatedEntityType!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.merge_type_rounded,
                        label: 'Entité liée',
                        value:
                            '${tx.relatedEntityType} · ${tx.relatedEntity ?? '—'}',
                      ),
                    if (tx.processedAt != null)
                      _InfoRow(
                        icon: Icons.done_all_rounded,
                        label: 'Traitée le',
                        value: df.format(tx.processedAt!.toLocal()),
                      ),
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Créée le',
                      value: df.format(tx.createdAt.toLocal()),
                    ),
                    if (tx.userName != null && tx.userName!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Utilisateur'),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person_rounded,
                        label: 'Nom',
                        value: tx.userName!,
                      ),
                      if (tx.userId != null && tx.userId!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.badge_rounded,
                          label: 'ID',
                          value: tx.userId!,
                        ),
                    ],
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
