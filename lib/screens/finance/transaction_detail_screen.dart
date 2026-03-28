import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/finance/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';

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
    final theme = Theme.of(context);
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Détail transaction'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_tx == null)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Impossible de charger la transaction.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              Builder(builder: (context) {
                final tx = _tx!;
                final accent = _colorFromStatus(tx.statusColor);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent.withOpacity(0.22)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            tx.isCompleted
                                ? Icons.verified_rounded
                                : tx.isFailed
                                    ? Icons.error_outline_rounded
                                    : Icons.schedule_rounded,
                            color: accent,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _typeLabel(tx.type),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tx.displayStatus,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(title: 'Informations'),
                    _InfoRow(
                      icon: Icons.tag,
                      label: 'Transaction',
                      value: tx.id,
                    ),
                    _InfoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Wallet',
                      value: tx.walletId,
                    ),
                    if (tx.gateway.isNotEmpty)
                      _InfoRow(
                        icon: Icons.link,
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
                        icon: Icons.subject_outlined,
                        label: 'Description',
                        value: tx.description!,
                      ),
                    if (tx.relatedEntityType != null &&
                        tx.relatedEntityType!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.merge_type_outlined,
                        label: 'Entité liée',
                        value:
                            '${tx.relatedEntityType} · ${tx.relatedEntity ?? '—'}',
                      ),
                    if (tx.processedAt != null)
                      _InfoRow(
                        icon: Icons.done_all,
                        label: 'Traitée le',
                        value: df.format(tx.processedAt!.toLocal()),
                      ),
                    _InfoRow(
                      icon: Icons.access_time,
                      label: 'Créée le',
                      value: df.format(tx.createdAt.toLocal()),
                    ),
                    if (tx.userName != null && tx.userName!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _SectionTitle(title: 'Utilisateur'),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Nom',
                        value: tx.userName!,
                      ),
                      if (tx.userId != null && tx.userId!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.badge_outlined,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
      ),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

