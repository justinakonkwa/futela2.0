import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/finance/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/transaction_card_shimmer.dart';
import '../finance/transaction_detail_screen.dart';

/// Historique des transactions (doc v2 : `GET /api/transactions`).
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions(refresh: true);
    });
  }

  Future<void> _pickStartDate(
      BuildContext context, TransactionProvider p) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5);
    DateTime last = DateTime(now.year, now.month, now.day);
    if (p.endDate != null && p.endDate!.isNotEmpty) {
      final e = DateTime.tryParse(p.endDate!);
      if (e != null) {
        last = DateTime(e.year, e.month, e.day);
        if (last.isAfter(DateTime(now.year, now.month, now.day))) {
          last = DateTime(now.year, now.month, now.day);
        }
      }
    }
    DateTime initial = last;
    if (p.startDate != null && p.startDate!.isNotEmpty) {
      final s = DateTime.tryParse(p.startDate!);
      if (s != null) initial = DateTime(s.year, s.month, s.day);
    }
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && context.mounted) {
      p.setStartDate(DateFormat('yyyy-MM-dd').format(picked));
      await p.loadTransactions(refresh: true);
    }
  }

  Future<void> _pickEndDate(BuildContext context, TransactionProvider p) async {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month, now.day);
    final first = DateTime(now.year - 5);
    DateTime firstD = first;
    if (p.startDate != null && p.startDate!.isNotEmpty) {
      final s = DateTime.tryParse(p.startDate!);
      if (s != null) firstD = DateTime(s.year, s.month, s.day);
    }
    DateTime initial = lastDay;
    if (p.endDate != null && p.endDate!.isNotEmpty) {
      final e = DateTime.tryParse(p.endDate!);
      if (e != null) initial = DateTime(e.year, e.month, e.day);
    }
    if (initial.isBefore(firstD)) initial = firstD;
    if (initial.isAfter(lastDay)) initial = lastDay;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstD,
      lastDate: lastDay,
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && context.mounted) {
      p.setEndDate(DateFormat('yyyy-MM-dd').format(picked));
      await p.loadTransactions(refresh: true);
    }
  }

  Widget _buildFilterBar(
      BuildContext context, ThemeData theme, TransactionProvider p) {
    Widget typeChip(String label, String? value) {
      final sel = p.typeFilter == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(label),
          selected: sel,
          onSelected: (_) async {
            p.setTypeFilter(value);
            await p.loadTransactions(refresh: true);
          },
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundColor: AppColors.white,
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            fontFamily: 'Gilroy',
            color: sel ? AppColors.primary : AppColors.textPrimary,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
          side: BorderSide(
            color: sel
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
            width: sel ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    String fmtDisplay(String? ymd) {
      if (ymd == null || ymd.isEmpty) return '—';
      final d = DateTime.tryParse(ymd);
      if (d == null) return ymd;
      return DateFormat('dd/MM/yyyy').format(d);
    }

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filtrer',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  typeChip('Tous', null),
                  typeChip('Paiements', 'payment'),
                  typeChip('Dépôts', 'deposit'),
                  typeChip('Retraits', 'withdrawal'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickStartDate(context, p),
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(
                      'Du ${fmtDisplay(p.startDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickEndDate(context, p),
                    icon: const Icon(Icons.event_outlined, size: 18),
                    label: Text(
                      'Au ${fmtDisplay(p.endDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            if (p.hasActiveFilters)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    p.clearFilters();
                    await p.loadTransactions(refresh: true);
                  },
                  child: const Text('Réinitialiser les filtres'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusTint(Transaction t) {
    switch (t.statusColor) {
      case 'green':
        return AppColors.success;
      case 'red':
        return AppColors.error;
      case 'yellow':
        return AppColors.warning;
      case 'blue':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Historique des paiements',
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
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilterBar(context, theme, txProvider),
              Expanded(
                child: _buildTransactionList(
                  context,
                  theme,
                  df,
                  txProvider,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    ThemeData theme,
    DateFormat df,
    TransactionProvider txProvider,
  ) {
    if (txProvider.isLoading && txProvider.transactions.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => const TransactionCardShimmer(),
      );
    }

    if (txProvider.error != null && txProvider.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                'Erreur de chargement',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                txProvider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => txProvider.loadTransactions(refresh: true),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      child: const Text(
                        'Réessayer',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = txProvider.transactions;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                txProvider.hasActiveFilters
                    ? 'Aucun résultat pour ces filtres'
                    : 'Aucune transaction pour l’instant',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                txProvider.hasActiveFilters
                    ? 'Modifiez le type ou les dates, ou réinitialisez les filtres.'
                    : 'Vos transactions (paiements, dépôts, retraits) apparaîtront ici.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              if (txProvider.hasActiveFilters) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    txProvider.clearFilters();
                    await txProvider.loadTransactions(refresh: true);
                  },
                  child: const Text('Réinitialiser les filtres'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => txProvider.loadTransactions(refresh: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Column(
                children: [
                  if (txProvider.hasMoreTransactions) ...[
                    if (txProvider.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      TextButton.icon(
                        onPressed: () => txProvider.loadMoreTransactions(),
                        icon: const Icon(Icons.expand_more),
                        label: const Text('Charger plus'),
                      ),
                  ],
                  if (txProvider.totalPages > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Page ${txProvider.currentPage} / ${txProvider.totalPages} · ${txProvider.totalItems} au total',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          final t = items[index];
          final tint = _statusTint(t);
          final when = t.processedAt ?? t.createdAt;
          final whenStr = df.format(when.toLocal());
          final amountStr =
              '${t.amount.toStringAsFixed(2)} ${t.currency}'.trim();
          final txShort = t.id.length > 10
              ? '…${t.id.substring(t.id.length - 8)}'
              : t.id;
          final typeLabel = switch (t.type) {
            'payment' => 'Paiement',
            'deposit' => 'Dépôt',
            'withdrawal' => 'Retrait',
            _ => t.type,
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: AppColors.cardBackground,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppColors.primary.withOpacity(0.12),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (ctx) =>
                          TransactionDetailScreen(transactionId: t.id),
                    ),
                  )
                      .then((changed) {
                    if (changed == true && context.mounted) {
                      txProvider.loadTransactions(refresh: true);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: tint.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              t.isCompleted
                                  ? Icons.verified_outlined
                                  : t.isFailed
                                      ? Icons.error_outline_rounded
                                      : Icons.schedule,
                              color: tint,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  typeLabel,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  whenStr,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniBadge(
                            label: t.displayStatus,
                            color: tint,
                          ),
                          if (amountStr.isNotEmpty)
                            _MiniBadge(
                              label: amountStr,
                              color: AppColors.textSecondary,
                              outlined: true,
                            ),
                        ],
                      ),
                      if (txShort.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Transaction $txShort',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                      if (t.description != null &&
                          t.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const _MiniBadge({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: outlined ? Border.all(color: AppColors.border) : null,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: outlined ? AppColors.textSecondary : color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
