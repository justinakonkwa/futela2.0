import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/visit.dart';
import '../../providers/visit_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/payment_result_dialog.dart';

/// Après création d’une visite avec paiement : GET statut toutes les 5 s, durée max 2 min.
class VisitPaymentPendingScreen extends StatefulWidget {
  final String visitId;
  final String transactionId;
  final num displayAmount;
  final String displayCurrency;

  const VisitPaymentPendingScreen({
    super.key,
    required this.visitId,
    required this.transactionId,
    required this.displayAmount,
    required this.displayCurrency,
  });

  @override
  State<VisitPaymentPendingScreen> createState() =>
      _VisitPaymentPendingScreenState();
}

class _VisitPaymentPendingScreenState extends State<VisitPaymentPendingScreen> {
  Timer? _timer;
  DateTime? _startedAt;
  VisitPaymentStatus? _lastStatus;
  bool _polling = true;
  bool _requestInFlight = false;

  static const _interval = Duration(seconds: 5);
  static const _maxWait = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _tick();
    _timer = Timer.periodic(_interval, (_) => _tick());
  }

  Future<void> _tick() async {
    if (!mounted || !_polling) return;

    if (DateTime.now().difference(_startedAt!) > _maxWait) {
      _stopPolling();
      if (!mounted) return;
      await PaymentResultDialog.showFailure(
        context,
        title: 'Délai dépassé',
        message:
            'Le paiement n’a pas été confirmé à temps. Vérifiez votre téléphone ou réessayez depuis Mes visites.',
      );
      if (mounted) Navigator.of(context).pop(false);
      return;
    }

    if (_requestInFlight) return;
    _requestInFlight = true;
    final provider = context.read<VisitProvider>();
    try {
      final s = await provider.fetchVisitPaymentStatus(
        widget.visitId,
        widget.transactionId,
      );
      if (!mounted) return;
      setState(() => _lastStatus = s);

      if (s.isCompleted) {
        _stopPolling();
        await provider.loadMyVisits(refresh: true);
        if (!mounted) return;
        await _showSuccessThenPop();
      } else if (s.isFailed) {
        _stopPolling();
        await provider.loadMyVisits(refresh: true);
        if (!mounted) return;
        await PaymentResultDialog.showFailure(
          context,
          message: s.displayHeadline,
        );
        if (mounted) Navigator.of(context).pop(false);
      }
    } catch (e) {
      // Erreur réseau : continuer le polling (guide)
      debugPrint('visit payment poll: $e');
    } finally {
      _requestInFlight = false;
    }
  }

  void _stopPolling() {
    _polling = false;
    _timer?.cancel();
    _timer = null;
  }

  String get _amountLine {
    final a = _lastStatus?.amount ?? widget.displayAmount;
    final c = _lastStatus?.currency ?? widget.displayCurrency;
    if (a == 0 && (c == '—' || c.isEmpty)) {
      return '—';
    }
    return '$a $c';
  }

  Future<void> _showSuccessThenPop() async {
    await PaymentResultDialog.showSuccess(context);
    if (mounted) Navigator.of(context).pop(true);
  }

  Color _badgeColor(String? c) {
    switch (c) {
      case 'green':
        return AppColors.success;
      case 'red':
        return AppColors.error;
      case 'yellow':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Paiement en cours'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmLeave(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant à valider',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _amountLine,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Étapes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _StepTile(
                number: 1,
                title: 'Vérifiez votre téléphone',
                subtitle:
                    'Un paiement mobile (FlexPay) vous a été envoyé. Saisissez votre code PIN sur l’appareil associé au numéro indiqué.',
                done: _lastStatus?.isCompleted == true,
                active: _polling && (_lastStatus == null || _lastStatus!.isPending),
              ),
              const SizedBox(height: 12),
              _StepTile(
                number: 2,
                title: 'Confirmation automatique',
                subtitle:
                    'Dès que le paiement est accepté, cette page se met à jour automatiquement (quelques secondes).',
                done: _lastStatus?.isCompleted == true,
                active: _lastStatus?.isPending == true,
              ),
              const SizedBox(height: 28),
              if (_polling) ...[
                if (_lastStatus != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: _polling && _lastStatus!.isPending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _lastStatus!.isCompleted
                                  ? Icons.check_circle
                                  : Icons.schedule,
                              size: 18,
                              color: _badgeColor(_lastStatus!.statusColor),
                            ),
                      label: Text(
                        _lastStatus!.statusLabel ??
                            (_lastStatus!.isPending
                                ? 'En attente de confirmation'
                                : _lastStatus!.status),
                      ),
                      backgroundColor:
                          _badgeColor(_lastStatus!.statusColor).withOpacity(0.12),
                      side: BorderSide.none,
                    ),
                  ),
                if (_lastStatus == null || _lastStatus!.isPending)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: AppColors.grey200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
              const Spacer(),
              Text(
                'Vérification automatique pendant 2 minutes maximum (toutes les 5 secondes).',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter ?'),
        content: const Text(
          'Le paiement peut encore être en cours. Vous pourrez suivre l’état dans Mes visites.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Rester'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      _stopPolling();
      Navigator.of(context).pop(false);
    }
  }
}

class _StepTile extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final bool done;
  final bool active;

  const _StepTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = done
        ? AppColors.success
        : active
            ? AppColors.primary
            : AppColors.textTertiary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: done
              ? Icon(Icons.check, size: 18, color: color)
              : Text(
                  '$number',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
