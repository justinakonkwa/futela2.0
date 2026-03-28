// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../models/visit.dart';
// import '../../providers/visit_provider.dart';
// import '../../utils/app_colors.dart';
// import 'visit_payment_pending_screen.dart';

// /// Écran **Détail de la visite** (entrée : liste *Mes visites* → carte ou lien « Détail »).
// ///
// /// **Données affichées**
// /// - [MyVisit] passé au constructeur : statut visite, planning, IDs, `isPaid`, montant
// ///   demandé, `paymentTransactionId`, notes.
// /// - **Statut paiement temps réel** : si une transaction est liée, appel
// ///   [VisitProvider.fetchVisitPaymentStatus] pour afficher confirmé / échoué / en attente.
// ///   Peut différer de `isPaid` → bandeau d’écart (_MismatchNotice).
// ///
// /// **Actions**
// /// - Pull-to-refresh : [VisitProvider.loadMyVisits] puis resynchronisation du [MyVisit] et du paiement.
// /// - **Suivre le paiement mobile** : [VisitPaymentPendingScreen] si `needsPaymentPolling`.
// /// - **Annuler la visite** : [VisitProvider.cancelVisit] (POST cancel), masqué selon `canCancelVisit`.
// class VisitDetailScreen extends StatefulWidget {
//   final MyVisit visit;

//   const VisitDetailScreen({super.key, required this.visit});

//   @override
//   State<VisitDetailScreen> createState() => _VisitDetailScreenState();
// }

// class _PaymentUiData {
//   final String headline;
//   final String detail;
//   final Color accent;
//   final IconData icon;
//   final bool loading;
//   /// Liste `isPaid` ne correspond pas au statut opérateur (FlexPay / API).
//   final bool dataMismatch;

//   const _PaymentUiData({
//     required this.headline,
//     required this.detail,
//     required this.accent,
//     required this.icon,
//     this.loading = false,
//     this.dataMismatch = false,
//   });
// }

// class _VisitDetailScreenState extends State<VisitDetailScreen> {
//   /// Dernier statut renvoyé par l’API paiement (prioritaire sur `isPaid` pour l’affichage).
//   VisitPaymentStatus? _lastPaymentStatus;
//   bool _loadingPayment = false;
//   bool _cancelling = false;
//   /// Copie mutable : mise à jour après refresh liste visites (même id).
//   late MyVisit _v;

//   MyVisit get v => _v;

//   @override
//   void initState() {
//     super.initState();
//     _v = widget.visit;
//     // Charge tout de suite le statut opérateur si une transaction est connue.
//     if (_v.paymentTransactionId != null &&
//         _v.paymentTransactionId!.isNotEmpty) {
//       WidgetsBinding.instance
//           .addPostFrameCallback((_) => _refreshPaymentStatus());
//     }
//   }

//   /// Retrouve la visite dans le provider après `loadMyVisits` (données plus fraîches).
//   MyVisit? _findUpdatedVisit(VisitProvider p) {
//     for (final x in p.visits) {
//       if (x.id == _v.id) return x;
//     }
//     return null;
//   }

//   Future<void> _pullRefresh() async {
//     final p = context.read<VisitProvider>();
//     await p.loadMyVisits(refresh: true);
//     final next = _findUpdatedVisit(p);
//     if (next != null && mounted) setState(() => _v = next);
//     await _refreshPaymentStatus();
//   }

//   /// Construit le libellé / couleur du bloc « Paiement » (carte sous le résumé).
//   ///
//   /// Règle : si `paymentTransactionId` est présent, on s’appuie d’abord sur
//   /// [_lastPaymentStatus] ; sinon repli sur `v.isPaid` / message par défaut.
//   _PaymentUiData _paymentUi() {
//     final hasTx = v.paymentTransactionId != null &&
//         v.paymentTransactionId!.isNotEmpty;

//     if (hasTx) {
//       if (_loadingPayment && _lastPaymentStatus == null) {
//         return const _PaymentUiData(
//           headline: 'Paiement',
//           detail: 'Synchronisation avec l’opérateur…',
//           accent: AppColors.primary,
//           icon: Icons.sync_rounded,
//           loading: true,
//         );
//       }
//       if (_lastPaymentStatus != null) {
//         final p = _lastPaymentStatus!;
//         if (p.isCompleted) {
//           return _PaymentUiData(
//             headline: 'Paiement confirmé',
//             detail: p.displayHeadline,
//             accent: AppColors.success,
//             icon: Icons.verified_rounded,
//             dataMismatch: !v.isPaid,
//           );
//         }
//         if (p.isFailed) {
//           return _PaymentUiData(
//             headline: 'Paiement non abouti',
//             detail: p.displayHeadline,
//             accent: AppColors.error,
//             icon: Icons.error_outline_rounded,
//             dataMismatch: v.isPaid,
//           );
//         }
//         return _PaymentUiData(
//           headline: 'En attente de paiement',
//           detail: p.displayHeadline,
//           accent: AppColors.warning,
//           icon: Icons.schedule_rounded,
//         );
//       }
//     }

//     if (v.isPaid) {
//       return const _PaymentUiData(
//         headline: 'Paiement',
//         detail: 'Marqué comme payé sur votre compte',
//         accent: AppColors.success,
//         icon: Icons.verified_outlined,
//       );
//     }
//     return const _PaymentUiData(
//       headline: 'Paiement',
//       detail: 'Aucun paiement enregistré pour cette visite',
//       accent: AppColors.textTertiary,
//       icon: Icons.payments_outlined,
//     );
//   }

//   Future<void> _refreshPaymentStatus() async {
//     final tx = v.paymentTransactionId;
//     if (tx == null || tx.isEmpty) return;
//     setState(() => _loadingPayment = true);
//     try {
//       final s = await context.read<VisitProvider>().fetchVisitPaymentStatus(
//             v.id,
//             tx,
//           );
//       if (mounted) setState(() => _lastPaymentStatus = s);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Impossible d’actualiser le paiement : $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _loadingPayment = false);
//     }
//   }

//   Future<void> _confirmCancel() async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Annuler la visite ?'),
//         content: const Text(
//           'Cette action est définitive. Une visite déjà payée ne peut pas être annulée.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Non'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: FilledButton.styleFrom(backgroundColor: AppColors.error),
//             child: const Text('Annuler la visite'),
//           ),
//         ],
//       ),
//     );
//     if (ok != true || !mounted) return;

//     setState(() => _cancelling = true);
//     try {
//       await context.read<VisitProvider>().cancelVisit(v.id);
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Visite annulée')),
//       );
//       Navigator.of(context).pop(true);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('$e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _cancelling = false);
//     }
//   }

//   Color _visitStatusColor(String? c) {
//     switch (c) {
//       case 'green':
//         return AppColors.success;
//       case 'red':
//         return AppColors.error;
//       case 'yellow':
//         return AppColors.warning;
//       case 'blue':
//         return AppColors.info;
//       default:
//         return AppColors.primary;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final df = DateFormat('dd/MM/yyyy HH:mm');
//     final visitLabel = v.statusLabel ?? v.status.replaceAll('_', ' ');
//     final pay = _paymentUi();
//     final p = _lastPaymentStatus;

//     final visitAccent = _visitStatusColor(v.statusColor);
//     final scheduledStr =
//         v.scheduledAt != null ? df.format(v.scheduledAt!.toLocal()) : '—';
//     String? summaryAmountLine;
//     if (v.paymentAmount != null) {
//       final cur = (v.paymentCurrency ?? '').trim();
//       final n = v.paymentAmount is num
//           ? (v.paymentAmount as num).toDouble()
//           : double.tryParse('${v.paymentAmount}') ?? 0;
//       summaryAmountLine = '${n.toStringAsFixed(2)} $cur'.trim();
//     } else if (p != null &&
//         p.amount != null &&
//         (p.amount ?? 0) != 0) {
//       summaryAmountLine =
//           '${p.amount} ${p.currency ?? v.paymentCurrency ?? ''}'.trim();
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Détail de la visite'),
//         elevation: 0,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _pullRefresh,
//         child: ListView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(20),
//           children: [
//             // --- Résumé (style proche détail transaction) ---
//             _VisitSummaryCard(
//               accent: visitAccent,
//               statusLabel: visitLabel,
//               propertyTitle: v.propertyTitle ?? 'Propriété',
//               scheduledLabel: scheduledStr,
//               addressLine: [
//                 if (v.propertyAddress != null && v.propertyAddress!.isNotEmpty)
//                   v.propertyAddress,
//                 if (v.propertyCity != null && v.propertyCity!.isNotEmpty)
//                   v.propertyCity,
//               ].whereType<String>().join(' · '),
//               amountLine: summaryAmountLine,
//             ),
//             const SizedBox(height: 16),
//             // --- Paiement : synthèse + éventuel avertissement isPaid ≠ opérateur ---
//             _PaymentStatusTile(data: pay),
//             if (pay.dataMismatch) ...[
//               const SizedBox(height: 12),
//               _MismatchNotice(onRefresh: _pullRefresh),
//             ],
//             const SizedBox(height: 24),
//             // --- Dates visite (création, confirmation, fin, annulation) ---
//             _SectionTitle(title: 'Planning'),
//             _InfoRow(icon: Icons.event, label: 'Date prévue', value: v.scheduledAt != null ? df.format(v.scheduledAt!.toLocal()) : '—'),
//             _InfoRow(icon: Icons.add_circle_outline, label: 'Créée le', value: v.createdAt != null ? df.format(v.createdAt!.toLocal()) : '—'),
//             if (v.confirmedAt != null)
//               _InfoRow(icon: Icons.check_circle_outline, label: 'Confirmée le', value: df.format(v.confirmedAt!.toLocal())),
//             if (v.completedAt != null)
//               _InfoRow(icon: Icons.done_all, label: 'Terminée le', value: df.format(v.completedAt!.toLocal())),
//             if (v.cancelledAt != null)
//               _InfoRow(icon: Icons.cancel_outlined, label: 'Annulée le', value: df.format(v.cancelledAt!.toLocal())),
//             const SizedBox(height: 8),
//             // --- IDs techniques (support / debug) ---
//             _SectionTitle(title: 'Identifiants'),
//             _InfoRow(icon: Icons.tag, label: 'Visite', value: v.id),
//             _InfoRow(icon: Icons.home_work_outlined, label: 'Propriété', value: v.propertyId),
//             if (v.visitorName != null && v.visitorName!.isNotEmpty)
//               _InfoRow(icon: Icons.person_outline, label: 'Visiteur', value: v.visitorName!),
//             if (v.notes != null && v.notes!.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               _SectionTitle(title: 'Message / notes'),
//               Text(
//                 v.notes!,
//                 style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
//               ),
//             ],
//             const SizedBox(height: 24),
//             // --- Reçu : id transaction + lignes issues du statut opérateur ---
//             _SectionTitle(title: 'Reçu de paiement'),
//             if (v.paymentTransactionId != null &&
//                 v.paymentTransactionId!.isNotEmpty) ...[
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.06),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: AppColors.primary.withOpacity(0.14),
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.85),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             Icons.receipt_long_rounded,
//                             color: pay.accent,
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 14),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Transaction',
//                                 style: theme.textTheme.labelMedium?.copyWith(
//                                   color: AppColors.textSecondary,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               SelectableText(
//                                 v.paymentTransactionId!,
//                                 style: theme.textTheme.bodyMedium?.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                   height: 1.25,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (v.paymentAmount != null) ...[
//                       const SizedBox(height: 14),
//                       Divider(height: 1, color: AppColors.divider.withOpacity(0.9)),
//                       const SizedBox(height: 12),
//                       _ReceiptRow(
//                         label: 'Montant demandé',
//                         value:
//                             '${v.paymentAmount} ${v.paymentCurrency ?? ''}'.trim(),
//                       ),
//                     ],
//                     if (p != null) ...[
//                       if (p.amount != null && (p.amount ?? 0) != 0) ...[
//                         const SizedBox(height: 8),
//                         _ReceiptRow(
//                           label: 'Montant (opérateur)',
//                           value:
//                               '${p.amount} ${p.currency ?? v.paymentCurrency ?? ''}'.trim(),
//                         ),
//                       ],
//                       if (p.externalId != null && p.externalId!.isNotEmpty) ...[
//                         const SizedBox(height: 8),
//                         _ReceiptRow(
//                           label: 'Référence opérateur',
//                           value: p.externalId!,
//                         ),
//                       ],
//                       if (p.paidAt != null) ...[
//                         const SizedBox(height: 8),
//                         _ReceiptRow(
//                           label: 'Date de traitement',
//                           value: df.format(p.paidAt!.toLocal()),
//                         ),
//                       ],
//                     ],
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton.icon(
//                         onPressed: _loadingPayment ? null : _refreshPaymentStatus,
//                         icon: _loadingPayment
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Icon(Icons.refresh_rounded, size: 20),
//                         label: Text(
//                           _loadingPayment ? 'Actualisation…' : 'Actualiser',
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: AppColors.primary,
//                           side: BorderSide(
//                             color: AppColors.primary.withOpacity(0.45),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ] else
//               // Pas de `paymentTransactionId` : pas de reçu détaillé
//               Text(
//                 'Aucune transaction n’est associée à cette visite.',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             // Paiement en cours côté mobile : ouvre l’écran de suivi / polling
//             if (v.needsPaymentPolling) ...[
//               const SizedBox(height: 14),
//               FilledButton.icon(
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (ctx) => VisitPaymentPendingScreen(
//                         visitId: v.id,
//                         transactionId: v.paymentTransactionId!,
//                         displayAmount: v.paymentAmount ?? 0,
//                         displayCurrency: v.paymentCurrency ?? '—',
//                       ),
//                     ),
//                   ).then((_) {
//                     if (!mounted) return;
//                     context.read<VisitProvider>().loadMyVisits(refresh: true);
//                     _refreshPaymentStatus();
//                   });
//                 },
//                 icon: const Icon(Icons.phone_android_rounded),
//                 label: const Text('Suivre le paiement mobile'),
//                 style: FilledButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 32),
//             // Annulation API (non proposée si visite payée ou règles `canCancelVisit`)
//             if (v.canCancelVisit) ...[
//               _SectionTitle(title: 'Actions'),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: _cancelling ? null : _confirmCancel,
//                   icon: _cancelling
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Icon(Icons.cancel_outlined),
//                   label: Text(_cancelling ? 'Annulation…' : 'Annuler la visite'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppColors.error,
//                     side: BorderSide(color: AppColors.error.withOpacity(0.55)),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// En-tête type « Détail transaction » : statut visite + bien + date (+ montant sur une ligne).
// class _VisitSummaryCard extends StatelessWidget {
//   final Color accent;
//   final String statusLabel;
//   final String propertyTitle;
//   final String scheduledLabel;
//   final String addressLine;
//   final String? amountLine;

//   const _VisitSummaryCard({
//     required this.accent,
//     required this.statusLabel,
//     required this.propertyTitle,
//     required this.scheduledLabel,
//     required this.addressLine,
//     this.amountLine,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: accent.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: accent.withOpacity(0.22)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.calendar_month_rounded,
//             color: accent,
//             size: 28,
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Visite',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   statusLabel,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   propertyTitle,
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     height: 1.25,
//                   ),
//                 ),
//                 if (addressLine.isNotEmpty) ...[
//                   const SizedBox(height: 6),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(
//                         Icons.place_outlined,
//                         size: 16,
//                         color: AppColors.textSecondary,
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           addressLine,
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: AppColors.textSecondary,
//                             height: 1.3,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.schedule_rounded,
//                       size: 16,
//                       color: AppColors.textSecondary,
//                     ),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         scheduledLabel,
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: AppColors.textSecondary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (amountLine != null && amountLine!.trim().isNotEmpty) ...[
//                   const SizedBox(height: 12),
//                   Text(
//                     amountLine!.trim(),
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.w800,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PaymentStatusTile extends StatelessWidget {
//   final _PaymentUiData data;

//   const _PaymentStatusTile({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: data.accent.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: data.accent.withOpacity(0.22)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (data.loading)
//             Padding(
//               padding: const EdgeInsets.only(top: 2),
//               child: SizedBox(
//                 width: 22,
//                 height: 22,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.2,
//                   color: data.accent,
//                 ),
//               ),
//             )
//           else
//             Icon(data.icon, color: data.accent, size: 26),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   data.headline,
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   data.detail,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: AppColors.textSecondary,
//                     height: 1.35,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MismatchNotice extends StatelessWidget {
//   final VoidCallback onRefresh;

//   const _MismatchNotice({required this.onRefresh});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Material(
//       color: AppColors.warning.withOpacity(0.1),
//       borderRadius: BorderRadius.circular(14),
//       child: InkWell(
//         onTap: onRefresh,
//         borderRadius: BorderRadius.circular(14),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Écart d’information',
//                       style: theme.textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Le statut côté Futela et celui de l’opérateur de paiement ne correspondent pas. '
//                       'Tirez vers le bas pour actualiser, ou contactez le support si cela continue.',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: AppColors.textSecondary,
//                         height: 1.35,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Appuyez pour actualiser',
//                       style: theme.textTheme.labelMedium?.copyWith(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ReceiptRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _ReceiptRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 2,
//           child: Text(
//             label,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: AppColors.textSecondary,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 3,
//           child: SelectableText(
//             value,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: AppColors.textPrimary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final String title;

//   const _SectionTitle({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Text(
//         title,
//         style: Theme.of(context).textTheme.titleSmall?.copyWith(
//               fontWeight: FontWeight.w800,
//               color: AppColors.textPrimary,
//             ),
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _InfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: AppColors.textSecondary),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: theme.textTheme.labelMedium?.copyWith(
//                     color: AppColors.textSecondary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 SelectableText(
//                   value,
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
