import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'visit_payment_pending_screen.dart';

class RequestVisitScreen extends StatefulWidget {
  final String propertyId;

  const RequestVisitScreen({
    super.key,
    required this.propertyId,
  });

  @override
  State<RequestVisitScreen> createState() => _RequestVisitScreenState();
}

class _RequestVisitScreenState extends State<RequestVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _paymentPhoneController = TextEditingController();
  final _paymentAmountController = TextEditingController(text: '5');

  DateTime? _visitDate;
  TimeOfDay _visitTime = const TimeOfDay(hour: 14, minute: 0);
  String _paymentCurrency = 'USD';
  bool _payNow = true;

  @override
  void dispose() {
    _notesController.dispose();
    _paymentPhoneController.dispose();
    _paymentAmountController.dispose();
    super.dispose();
  }

  /// ISO 8601 pour l’API (UTC).
  String _scheduledAtIso() {
    final d = _visitDate!;
    final dt = DateTime.utc(
      d.year,
      d.month,
      d.day,
      _visitTime.hour,
      _visitTime.minute,
    );
    return dt.toIso8601String().replaceAll(RegExp(r'\.\d+Z'), '+00:00');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Demander une visite'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Planifiez votre passage',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choisissez la date et l’heure souhaitées. Le propriétaire sera notifié.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _sectionCard(
              context,
              icon: Icons.event_rounded,
              title: 'Date et heure',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dateTile(context),
                  const SizedBox(height: 12),
                  _timeTile(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              context,
              icon: Icons.notes_rounded,
              title: 'Message (optionnel)',
              child: CustomTextField(
                controller: _notesController,
                label: 'Précisions pour le propriétaire',
                hint: 'Ex. : disponible en fin de journée, visite en couple…',
                maxLines: 3,
                validator: null,
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              context,
              icon: Icons.payments_rounded,
              title: 'Frais de visite',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Payer maintenant par Mobile Money'),
                    subtitle: Text(
                      _payNow
                          ? 'FlexPay : vous recevrez une demande sur votre téléphone.'
                          : 'Aucun paiement à l’envoi — selon les règles du bien.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _payNow,
                    activeTrackColor: AppColors.primary.withOpacity(0.45),
                    activeColor: AppColors.white,
                    onChanged: (v) => setState(() => _payNow = v),
                  ),
                  if (_payNow) ...[
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _paymentAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (!_payNow) return null;
                              if (value == null || value.isEmpty) {
                                return 'Requis';
                              }
                              if (num.tryParse(
                                      value.replaceAll(',', '.')) ==
                                  null) {
                                return 'Invalide';
                              }
                              return null;
                            },
                            decoration: _paymentAlignedDecoration(
                              context,
                              labelText: 'Montant',
                              hintText: '5',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _paymentCurrency,
                            isExpanded: true,
                            decoration: _paymentAlignedDecoration(
                              context,
                              labelText: 'Devise',
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'USD', child: Text('USD')),
                              DropdownMenuItem(
                                  value: 'CDF', child: Text('CDF')),
                              DropdownMenuItem(
                                  value: 'EUR', child: Text('EUR')),
                            ],
                            onChanged: (v) =>
                                setState(() => _paymentCurrency = v ?? 'USD'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _paymentPhoneController,
                      label: 'Numéro Mobile Money',
                      hint: '+243 970 000 000',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (!_payNow) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'Numéro requis pour le paiement';
                        }
                        if (value.replaceAll(RegExp(r'\d'), '').length ==
                            value.length) {
                          return 'Numéro invalide';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            Consumer<VisitProvider>(
              builder: (context, visitProvider, _) {
                return CustomButton(
                  text: _payNow
                      ? 'Envoyer la demande et lancer le paiement'
                      : 'Envoyer la demande',
                  onPressed:
                      visitProvider.isLoading ? null : _submitVisitRequest,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  isLoading: visitProvider.isLoading,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _dateTile(BuildContext context) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date de la visite',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          _visitDate != null
              ? '${_visitDate!.day.toString().padLeft(2, '0')}/'
                  '${_visitDate!.month.toString().padLeft(2, '0')}/'
                  '${_visitDate!.year}'
              : 'Choisir une date',
          style: TextStyle(
            color: _visitDate != null
                ? AppColors.textPrimary
                : AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _timeTile(BuildContext context) {
    return InkWell(
      onTap: _pickTime,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Heure',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.schedule_rounded),
        ),
        child: Text(
          _visitTime.format(context),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _visitTime,
    );
    if (picked != null) setState(() => _visitTime = picked);
  }

  Future<void> _submitVisitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_visitDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir la date de la visite'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour demander une visite'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final visitProvider = context.read<VisitProvider>();
    num? amount;
    if (_payNow) {
      amount = num.tryParse(
        _paymentAmountController.text.trim().replaceAll(',', '.'),
      );
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Montant invalide'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final result = await visitProvider.createVisit(
        propertyId: widget.propertyId,
        scheduledAt: _scheduledAtIso(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        paymentAmount: _payNow ? amount : null,
        paymentCurrency: _payNow ? _paymentCurrency : null,
        paymentPhone: _payNow ? _paymentPhoneController.text.trim() : null,
      );

      if (!mounted) return;

      if (result.hasPaymentFlow) {
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (ctx) => VisitPaymentPendingScreen(
              visitId: result.id,
              transactionId: result.paymentTransactionId!,
              displayAmount: amount ?? 0,
              displayCurrency: _paymentCurrency,
            ),
          ),
        );
        if (mounted) Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande de visite envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Même style de champ pour Montant et Devise (labels flottants alignés, hauteur cohérente).
InputDecoration _paymentAlignedDecoration(
  BuildContext context, {
  required String labelText,
  String? hintText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: true,
    fillColor: AppColors.grey50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.grey200, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.grey200, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w400,
        ),
    errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w500,
        ),
  );
}
