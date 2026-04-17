import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/commission_provider.dart';
import '../../models/commission/commission.dart';
import '../../utils/app_colors.dart';

class CommissionVerificationScreen extends StatefulWidget {
  const CommissionVerificationScreen({super.key});

  @override
  State<CommissionVerificationScreen> createState() =>
      _CommissionVerificationScreenState();
}

class _CommissionVerificationScreenState
    extends State<CommissionVerificationScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _codeFocus = FocusNode();

  // Étape 1 = saisie téléphone, Étape 2 = saisie code OTP
  int _step = 1;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Vérifier une commission',
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_step == 2) {
              _goBackToStep1();
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                    : AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: Theme.of(context).textTheme.displayLarge?.color,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
          child: _step == 1
              ? _buildStep1(key: const ValueKey('step1'))
              : _buildStep2(key: const ValueKey('step2')),
        ),
      ),
    );
  }

  // ─── ÉTAPE 1 : Saisie du numéro de téléphone ───────────────────────────────

  Widget _buildStep1({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepIndicator(current: 1),
          const SizedBox(height: 28),

          // Illustration
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primaryDark.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.phone_fill,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Numéro du visiteur',
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Saisissez le numéro de téléphone local du visiteur pour retrouver sa commission.',
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Champ téléphone
          _buildInputCard(
            controller: _phoneController,
            focusNode: _phoneFocus,
            label: 'Numéro de téléphone',
            hint: 'ex: 0812345678',
            icon: CupertinoIcons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          // Bouton rechercher
          Consumer<CommissionProvider>(
            builder: (context, provider, _) {
              if (provider.searchError != null) {
                return Column(
                  children: [
                    _buildErrorBanner(provider.searchError!),
                    const SizedBox(height: 16),
                    _buildPrimaryButton(
                      label: 'Rechercher',
                      icon: CupertinoIcons.search,
                      isLoading: provider.isSearchingByPhone,
                      onPressed: _searchByPhone,
                    ),
                  ],
                );
              }
              return _buildPrimaryButton(
                label: 'Rechercher la commission',
                icon: CupertinoIcons.search,
                isLoading: provider.isSearchingByPhone,
                onPressed: _searchByPhone,
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── ÉTAPE 2 : Affichage commission + saisie code OTP ──────────────────────

  Widget _buildStep2({Key? key}) {
    return Consumer<CommissionProvider>(
      key: key,
      builder: (context, provider, _) {
        final commission = provider.foundCommission;
        if (commission == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStepIndicator(current: 2),
              const SizedBox(height: 28),

              // Card commission trouvée
              _buildCommissionCard(commission),
              const SizedBox(height: 24),

              // Saisie code OTP
              const Text(
                'Code de vérification',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Demandez au visiteur le code à 6 chiffres qu\'il a reçu.',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              _buildOtpInput(),
              const SizedBox(height: 24),

              if (provider.verificationError != null) ...[
                _buildErrorBanner(provider.verificationError!),
                const SizedBox(height: 16),
              ],

              _buildPrimaryButton(
                label: 'Confirmer la commission',
                icon: CupertinoIcons.checkmark_shield_fill,
                isLoading: provider.isVerifying,
                onPressed: _verifyCode,
              ),
              const SizedBox(height: 12),

              // Bouton retour
              TextButton(
                onPressed: _goBackToStep1,
                child: const Text(
                  'Changer de numéro',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommissionCard(Commission commission) {
    final statusColor = _colorFromString(commission.verificationStatusColor);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header vert "Commission trouvée"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_circle_fill,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Commission trouvée',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    commission.verificationStatusLabel,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: CupertinoIcons.building_2_fill,
                  label: 'Propriété',
                  value: commission.propertyTitle ?? '—',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: CupertinoIcons.person_fill,
                  label: 'Visiteur',
                  value: commission.visitorName ?? '—',
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountChip(
                        label: 'Votre commission',
                        value: commission.displayAmount,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAmountChip(
                        label: 'Taux',
                        value: '${commission.commissionRate.toStringAsFixed(0)}%',
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _codeController,
        focusNode: _codeFocus,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 10,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          hintText: '------',
          hintStyle: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 10,
            color: AppColors.border,
          ),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  // ─── Widgets helpers ───────────────────────────────────────────────────────

  Widget _buildStepIndicator({required int current}) {
    return Row(
      children: [
        _buildStepDot(1, current),
        Expanded(
          child: Container(
            height: 2,
            color: current >= 2
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.4),
          ),
        ),
        _buildStepDot(2, current),
      ],
    );
  }

  Widget _buildStepDot(int step, int current) {
    final isActive = current >= step;
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : theme.scaffoldBackgroundColor,
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: isActive && current > step
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : Text(
                '$step',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            fontFamily: 'Gilroy',
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.exclamationmark_circle, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Gilroy',
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromString(String color) {
    switch (color) {
      case 'green':
        return AppColors.success;
      case 'blue':
        return AppColors.info;
      case 'orange':
      case 'yellow':
        return AppColors.warning;
      case 'red':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _searchByPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    final provider = Provider.of<CommissionProvider>(context, listen: false);
    final found = await provider.findCommissionByPhone(phone);

    if (found && mounted) {
      setState(() => _step = 2);
      Future.delayed(const Duration(milliseconds: 350), () {
        _codeFocus.requestFocus();
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le code doit contenir 6 chiffres')),
      );
      return;
    }

    final provider = Provider.of<CommissionProvider>(context, listen: false);
    final commissionId = provider.foundCommission?.id ?? '';

    final success = await provider.verifyCommission(commissionId, code);

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _goBackToStep1() {
    final provider = Provider.of<CommissionProvider>(context, listen: false);
    provider.clearFoundCommission();
    _codeController.clear();
    setState(() => _step = 1);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Commission confirmée !',
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Le montant a été ajouté à votre solde.',
              style: TextStyle(
                fontFamily: 'Gilroy',
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
