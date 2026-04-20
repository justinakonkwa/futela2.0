import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/visit.dart';
import '../../providers/visit_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../widgets/futela_logo.dart';
import 'visit_payment_pending_screen.dart';
import 'visit_detail_screen.dart';

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
        title: Text(
          'Mes visites',
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: theme.textTheme.displayLarge?.color,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: theme.textTheme.displayLarge?.color,
              ),
            ),
          ),
        ),
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
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundColor: theme.cardColor,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontFamily: 'Gilroy',
                      color: sel ? AppColors.primary : theme.textTheme.bodyMedium?.color,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : theme.dividerColor,
                      width: sel ? 1.5 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (ctx) => VisitDetailScreen(visit: v),
                            ),
                          )
                              .then((changed) {
                            if (changed == true) {
                              visitProvider.loadMyVisits(
                                refresh: true,
                                itemsPerPage: _pageSize,
                              );
                            }
                          });
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

    final label = visit.isPaid
        ? 'Payé ✓'
        : (visit.statusLabel ?? visit.status.replaceAll('_', ' ').toUpperCase());

    // Si payé, on force la couleur verte pour le badge
    Color Function(String?) effectiveStatusColor = visit.isPaid
        ? (_) => AppColors.success
        : statusColor;

    final locationLine = [
      if (visit.propertyCity != null && visit.propertyCity!.isNotEmpty)
        visit.propertyCity,
      if (visit.propertyAddress != null &&
          visit.propertyAddress!.isNotEmpty &&
          visit.propertyCity != visit.propertyAddress)
        visit.propertyAddress,
    ].whereType<String>().take(2).join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: statusColor(visit.statusColor).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header avec gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveStatusColor(visit.statusColor).withValues(alpha: 0.08),
                    effectiveStatusColor(visit.statusColor).withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: effectiveStatusColor(visit.statusColor).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      visit.isPaid ? Icons.verified_rounded : Icons.home_work_rounded,
                      color: effectiveStatusColor(visit.statusColor),
                      size: 24,
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
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  locationLine,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'Gilroy',
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: effectiveStatusColor(visit.statusColor).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: effectiveStatusColor(visit.statusColor).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'Gilroy',
                        color: effectiveStatusColor(visit.statusColor),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date et heure
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date de visite',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: 'Gilroy',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Gilroy',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  if (visit.paymentAmount != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.payments_rounded,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Montant',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${visit.paymentAmount} ${visit.paymentCurrency ?? ''}'.trim(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: visit.isPaid
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                visit.isPaid ? Icons.verified_rounded : Icons.pending_rounded,
                                size: 14,
                                color: visit.isPaid ? AppColors.success : AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                visit.isPaid ? 'Payé' : 'En attente',
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  color: visit.isPaid ? AppColors.success : AppColors.warning,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 16,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              visit.notes!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'Gilroy',
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  if (onOpenPayment != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onOpenPayment,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.phone_android_rounded,
                                    size: 20,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Suivi du paiement',
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  if (createdStr != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Demandée le $createdStr · Réf. ${visit.id.length > 8 ? '…${visit.id.substring(visit.id.length - 8)}' : visit.id}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'Gilroy',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
