import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/visit.dart';
import '../../providers/visit_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../widgets/futela_logo.dart';
import 'visit_detail_screen.dart';
import 'visit_payment_pending_screen.dart';

/// Liste `GET /api/me/visits` avec filtres `status` + pagination.
class MyVisitsScreen extends StatefulWidget {
  const MyVisitsScreen({super.key});

  @override
  State<MyVisitsScreen> createState() => _MyVisitsScreenState();
}

class _MyVisitsScreenState extends State<MyVisitsScreen> {
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitProvider>().loadMyVisits(
            refresh: true,
            updateStatusFilter: true,
            status: null,
            itemsPerPage: _pageSize,
          );
    });
  }

  Color _statusColor(String? c) {
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

  Future<void> _applyFilter(VisitProvider p, String? status) {
    return p.loadMyVisits(
      refresh: true,
      updateStatusFilter: true,
      status: status,
      itemsPerPage: _pageSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mes visites'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<VisitProvider>(
            builder: (context, p, _) {
              final f = p.listStatusFilter;
              Widget chip(String label, String? value) {
                final sel = f == value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: sel,
                    onSelected: (_) => _applyFilter(p, value),
                    selectedColor: AppColors.primary.withOpacity(0.18),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: sel ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: sel
                          ? AppColors.primary.withOpacity(0.45)
                          : AppColors.border,
                    ),
                  ),
                );
              }

              return Material(
                color: theme.scaffoldBackgroundColor,
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        chip('Toutes', null),
                        chip('Planifiées', 'scheduled'),
                        chip('Confirmées', 'confirmed'),
                        chip('Terminées', 'completed'),
                        chip('Annulées', 'cancelled'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<VisitProvider>(
              builder: (context, visitProvider, child) {
                if (visitProvider.isLoading && visitProvider.visits.isEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: PropertyCardShimmer(),
                      );
                    },
                  );
                }

                if (visitProvider.error != null &&
                    visitProvider.visits.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            visitProvider.error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Réessayer',
                            onPressed: () => visitProvider.loadMyVisits(
                              refresh: true,
                              itemsPerPage: _pageSize,
                            ),
                            backgroundColor: AppColors.primary,
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (visitProvider.visits.isEmpty) {
                  final hasFilter =
                      visitProvider.listStatusFilter != null;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutelaLogoWithBadge(
                            size: 120,
                            badgeIcon: hasFilter
                                ? Icons.filter_alt_outlined
                                : Icons.calendar_today,
                            badgeColor: AppColors.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            hasFilter
                                ? 'Aucune visite pour ce filtre'
                                : 'Aucune visite',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasFilter
                                ? 'Essayez un autre statut ou affichez toutes vos visites.'
                                : 'Demandez une visite depuis une annonce pour la voir ici.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (hasFilter) ...[
                            const SizedBox(height: 20),
                            OutlinedButton(
                              onPressed: () => _applyFilter(
                                visitProvider,
                                null,
                              ),
                              child: const Text('Voir toutes les visites'),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => visitProvider.loadMyVisits(
                    refresh: true,
                    itemsPerPage: _pageSize,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: visitProvider.visits.length +
                        1 +
                        (visitProvider.hasMoreVisits ? 1 : 0),
                    itemBuilder: (context, index) {
                      final n = visitProvider.visits.length;
                      if (index == n) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 12),
                          child: Text(
                            'Page ${visitProvider.currentPage} / ${visitProvider.totalPages} · ${visitProvider.totalItems} au total',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        );
                      }
                      if (index == n + 1) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Center(
                            child: visitProvider.isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : OutlinedButton(
                                    onPressed: () =>
                                        visitProvider.loadMoreVisits(),
                                    child: const Text('Charger plus'),
                                  ),
                          ),
                        );
                      }

                      final v = visitProvider.visits[index];
                      return _VisitCard(
                        visit: v,
                        statusColor: _statusColor,
                        onTap: () {
                          // Détail : résumé visite, reçu paiement, suivi FlexPay, annulation.
                          // Navigator.of(context)
                          //     .push(
                          //   MaterialPageRoute(
                          //     builder: (ctx) => VisitDetailScreen(visit: v),
                          //   ),
                          // )
                          //     .then((changed) {
                          //   if (changed == true) {
                          //     visitProvider.loadMyVisits(
                          //       refresh: true,
                          //       itemsPerPage: _pageSize,
                          //     );
                          //   }
                          // });
                        },
                        onOpenPayment: v.needsPaymentPolling
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        VisitPaymentPendingScreen(
                                      visitId: v.id,
                                      transactionId:
                                          v.paymentTransactionId!,
                                      displayAmount: v.paymentAmount ?? 0,
                                      displayCurrency:
                                          v.paymentCurrency ?? '—',
                                    ),
                                  ),
                                ).then((_) {
                                  visitProvider.loadMyVisits(
                                    refresh: true,
                                    itemsPerPage: _pageSize,
                                  );
                                });
                              }
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final MyVisit visit;
  final Color Function(String?) statusColor;
  final VoidCallback? onOpenPayment;
  final VoidCallback onTap;

  const _VisitCard({
    required this.visit,
    required this.statusColor,
    required this.onTap,
    this.onOpenPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final dateStr = visit.scheduledAt != null
        ? df.format(visit.scheduledAt!.toLocal())
        : 'Date à confirmer';
    final createdStr = visit.createdAt != null
        ? df.format(visit.createdAt!.toLocal())
        : null;

    final label = visit.statusLabel ??
        visit.status.replaceAll('_', ' ').toUpperCase();

    final locationLine = [
      if (visit.propertyCity != null && visit.propertyCity!.isNotEmpty)
        visit.propertyCity,
      if (visit.propertyAddress != null &&
          visit.propertyAddress!.isNotEmpty &&
          visit.propertyCity != visit.propertyAddress)
        visit.propertyAddress,
    ].whereType<String>().take(2).join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withOpacity(0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      color: statusColor(visit.statusColor).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.home_work_outlined,
                      color: statusColor(visit.statusColor),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.propertyTitle ?? 'Propriété',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (locationLine.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  locationLine,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dateStr,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (createdStr != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Demandée le $createdStr',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Réf. ${visit.id.length > 8 ? '…${visit.id.substring(visit.id.length - 8)}' : visit.id}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor(visit.statusColor)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor(visit.statusColor),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 8),
                      // Icon(
                      //   Icons.chevron_right,
                      //   color: AppColors.textTertiary,
                      // ),
                    ],
                  ),
                ],
              ),
              if (visit.paymentAmount != null) ...[
                const SizedBox(height: 10),
                Row(
                  children:  [
                    const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${visit.paymentAmount} ${visit.paymentCurrency ?? ''}'
                          .trim(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  visit.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    visit.isPaid ? Icons.verified : Icons.payments_outlined,
                    size: 16,
                    color: visit.isPaid
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      visit.isPaid
                          ? 'Paiement confirmé'
                          : 'Paiement en attente',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: visit.isPaid
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // TextButton(
                  //   onPressed: onTap,
                  //   child: const Text('Détail'),
                  // ),
                ],
              ),
              if (onOpenPayment != null) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onOpenPayment,
                    icon: const Icon(Icons.phone_android, size: 20),
                    label: const Text('Suivi du paiement'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                          color: AppColors.primary.withOpacity(0.6)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
