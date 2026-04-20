import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/visit.dart';
import '../../providers/visit_provider.dart';
import '../../providers/commission_provider.dart';
import '../../utils/app_colors.dart';
import 'visit_payment_pending_screen.dart';

/// Écran Détail de la visite avec code OTP de vérification.
class VisitDetailScreen extends StatefulWidget {
  final MyVisit visit;

  const VisitDetailScreen({super.key, required this.visit});

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  VisitPaymentStatus? _lastPaymentStatus;
  bool _loadingPayment = false;
  bool _cancelling = false;
  bool _loadingCode = false;
  Map<String, dynamic>? _verificationCode;
  late MyVisit _v;

  MyVisit get v => _v;

  @override
  void initState() {
    super.initState();
    _v = widget.visit;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_v.paymentTransactionId != null && _v.paymentTransactionId!.isNotEmpty) {
        _refreshPaymentStatus();
      }
      if (_v.isPaid) {
        _loadVerificationCode();
      }
    });
  }

  MyVisit? _findUpdatedVisit(VisitProvider p) {
    for (final x in p.visits) {
      if (x.id == _v.id) return x;
    }
    return null;
  }

  Future<void> _pullRefresh() async {
    final p = context.read<VisitProvider>();
    await p.loadMyVisits(refresh: true);
    final next = _findUpdatedVisit(p);
    if (next != null && mounted) setState(() => _v = next);
    await _refreshPaymentStatus();
    if (_v.isPaid) await _loadVerificationCode();
  }

  Future<void> _refreshPaymentStatus() async {
    final tx = v.paymentTransactionId;
    if (tx == null || tx.isEmpty) return;
    setState(() => _loadingPayment = true);
    try {
      final s = await context.read<VisitProvider>().fetchVisitPaymentStatus(v.id, tx);
      if (mounted) setState(() => _lastPaymentStatus = s);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingPayment = false);
    }
  }

  Future<void> _loadVerificationCode() async {
    setState(() => _loadingCode = true);
    try {
      final codes = await context.read<CommissionProvider>().loadVerificationCodesForVisit(v.id);
      if (mounted && codes.isNotEmpty) {
        setState(() => _verificationCode = codes.first);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingCode = false);
    }
  }

  Future<void> _confirmCancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Annuler la visite ?'),
        content: const Text('Cette action est définitive. Une visite déjà payée ne peut pas être annulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Annuler la visite'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await context.read<VisitProvider>().cancelVisit(v.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visite annulée')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Color _visitStatusColor(String? c) {
    switch (c) {
      case 'green': return AppColors.success;
      case 'red': return AppColors.error;
      case 'yellow': return AppColors.warning;
      case 'blue': return AppColors.info;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final visitLabel = v.statusLabel ?? v.status.replaceAll('_', ' ');
    final visitAccent = _visitStatusColor(v.statusColor);
    final scheduledStr = v.scheduledAt != null ? df.format(v.scheduledAt!.toLocal()) : '—';
    final p = _lastPaymentStatus;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Détail de la visite',
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: theme.textTheme.displayLarge?.color,
          ),
        ),
        backgroundColor: Colors.transparent,
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
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // Résumé visite
            _buildSummaryCard(theme, visitAccent, visitLabel, scheduledStr),
            const SizedBox(height: 16),

            // Code OTP (si visite payée)
            if (v.isPaid) ...[
              _buildOtpSection(theme),
              const SizedBox(height: 16),
            ],

            // Statut paiement
            _buildPaymentCard(theme, p, df),
            const SizedBox(height: 16),

            // Suivi paiement mobile
            if (v.needsPaymentPolling) ...[
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => VisitPaymentPendingScreen(
                        visitId: v.id,
                        transactionId: v.paymentTransactionId!,
                        displayAmount: v.paymentAmount ?? 0,
                        displayCurrency: v.paymentCurrency ?? '—',
                      ),
                    ),
                  ).then((_) {
                    if (!mounted) return;
                    context.read<VisitProvider>().loadMyVisits(refresh: true);
                    _refreshPaymentStatus();
                  });
                },
                icon: const Icon(Icons.phone_android_rounded),
                label: const Text('Suivre le paiement mobile'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            if (v.notes != null && v.notes!.isNotEmpty) ...[
              _buildSectionTitle(theme, 'Notes'),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  v.notes!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Annulation
            if (v.canCancelVisit) ...[
              _buildSectionTitle(theme, 'Actions'),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _cancelling ? null : _confirmCancel,
                  icon: _cancelling
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cancel_outlined),
                  label: Text(_cancelling ? 'Annulation…' : 'Annuler la visite'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.55)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, Color accent, String statusLabel, String scheduledStr) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calendar_month_rounded, color: accent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.propertyTitle ?? 'Propriété',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.displayLarge?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 6),
                    Text(
                      scheduledStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (v.paymentAmount != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${v.paymentAmount} ${v.paymentCurrency ?? ''}'.trim(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.displayLarge?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection(ThemeData theme) {
    if (_loadingCode) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    if (_verificationCode == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.clock, color: AppColors.warning, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code en cours de génération',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.displayLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Votre code de vérification sera disponible sous peu.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Gilroy',
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadVerificationCode,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.warning),
            ),
          ],
        ),
      );
    }

    final code = _verificationCode!['code'] as String? ?? '------';
    final expiresAtRaw = _verificationCode!['expiresAt'];
    final expiresAt = expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw.toString()) : null;
    final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpired
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpired
                ? AppColors.error.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isExpired
                  ? AppColors.error.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.qrcode,
                    color: isExpired ? AppColors.error : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code de vérification',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.displayLarge?.color,
                        ),
                      ),
                      Text(
                        isExpired ? 'Code expiré' : 'À montrer au commissionnaire',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isExpired ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? AppColors.error.withValues(alpha: 0.15)
                        : AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isExpired
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isExpired ? 'Expiré' : 'Actif',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isExpired ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copié !'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isExpired
                            ? [AppColors.grey400, AppColors.grey500]
                            : [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isExpired
                              ? Colors.black.withValues(alpha: 0.2)
                              : AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          code,
                          style: const TextStyle(
                            fontFamily: 'Gilroy',
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy_rounded, color: Colors.white60, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Appuyez pour copier',
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                color: Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (expiresAt != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 14,
                        color: isExpired ? AppColors.error : theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isExpired
                            ? 'Expiré le ${DateFormat('dd/MM/yyyy HH:mm').format(expiresAt.toLocal())}'
                            : 'Expire le ${DateFormat('dd/MM/yyyy HH:mm').format(expiresAt.toLocal())}',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 13,
                          color: isExpired ? AppColors.error : theme.textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                if (!isExpired) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.info_circle, color: AppColors.info, size: 16),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Montrez ce code au commissionnaire lors de votre visite.',
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              color: AppColors.info,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(ThemeData theme, VisitPaymentStatus? p, DateFormat df) {
    final hasTx = v.paymentTransactionId != null && v.paymentTransactionId!.isNotEmpty;
    if (!hasTx) return const SizedBox.shrink();

    Color accent;
    String headline;
    String detail;
    IconData icon;

    if (_loadingPayment && p == null) {
      accent = AppColors.primary;
      headline = 'Paiement';
      detail = 'Synchronisation…';
      icon = Icons.sync_rounded;
    } else if (p != null) {
      if (p.isCompleted) {
        accent = AppColors.success;
        headline = 'Paiement confirmé';
        detail = p.displayHeadline;
        icon = Icons.verified_rounded;
      } else if (p.isFailed) {
        accent = AppColors.error;
        headline = 'Paiement non abouti';
        detail = p.displayHeadline;
        icon = Icons.error_outline_rounded;
      } else {
        accent = AppColors.warning;
        headline = 'En attente de paiement';
        detail = p.displayHeadline;
        icon = Icons.schedule_rounded;
      }
    } else if (v.isPaid) {
      accent = AppColors.success;
      headline = 'Paiement';
      detail = 'Marqué comme payé';
      icon = Icons.verified_outlined;
    } else {
      accent = AppColors.textTertiary;
      headline = 'Paiement';
      detail = 'Aucun paiement enregistré';
      icon = Icons.payments_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _loadingPayment && p == null
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: accent),
                    )
                  : Icon(icon, color: accent, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.displayLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Gilroy',
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadingPayment ? null : _refreshPaymentStatus,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                color: accent,
              ),
            ],
          ),
          if (p != null) ...[
            Divider(height: 20, color: theme.dividerColor),
            if (p.externalId != null && p.externalId!.isNotEmpty)
              _receiptRow(theme, 'Référence opérateur', p.externalId!),
            if (p.amount != null && (p.amount ?? 0) != 0)
              _receiptRow(theme, 'Montant', '${p.amount} ${p.currency ?? v.paymentCurrency ?? ''}'),
            if (p.paidAt != null)
              _receiptRow(theme, 'Traité le', df.format(p.paidAt!.toLocal())),
          ],
        ],
      ),
    );
  }

  Widget _receiptRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w700,
                color: theme.textTheme.displayLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w700,
          color: theme.textTheme.displayLarge?.color,
        ),
      ),
    );
  }
}
