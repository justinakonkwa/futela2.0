import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/commission_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CommissionVerificationScreen extends StatefulWidget {
  const CommissionVerificationScreen({super.key});

  @override
  State<CommissionVerificationScreen> createState() => _CommissionVerificationScreenState();
}

class _CommissionVerificationScreenState extends State<CommissionVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Vérifier commission',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.back,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Par téléphone'),
            Tab(text: 'Code direct'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhoneVerificationTab(),
          _buildDirectCodeTab(),
        ],
      ),
    );
  }

  Widget _buildPhoneVerificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Demandez au visiteur son numéro de téléphone et le code OTP qu\'il a reçu.',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _phoneController,
              label: 'Numéro de téléphone du visiteur',
              hint: '+243 812 345 678',
              keyboardType: TextInputType.phone,
              prefixIconData: CupertinoIcons.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le numéro de téléphone';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _codeController,
              label: 'Code de vérification',
              hint: '123456',
              keyboardType: TextInputType.number,
              prefixIconData: CupertinoIcons.lock_shield,
              maxLength: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le code de vérification';
                }
                if (value.length != 6) {
                  return 'Le code doit contenir 6 chiffres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Consumer<CommissionProvider>(
              builder: (context, provider, child) {
                return CustomButton(
                  text: 'Vérifier la commission',
                  onPressed: provider.isVerifying ? null : _verifyByPhone,
                  isLoading: provider.isVerifying,
                  height: 52,
                  fullWidth: true,
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<CommissionProvider>(
              builder: (context, provider, child) {
                if (provider.verificationError != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: AppColors.error,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.verificationError!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cette méthode nécessite de connaître l\'ID de la commission. Utilisez plutôt la vérification par téléphone.',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Fonctionnalité à venir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'La vérification directe par ID de commission sera disponible prochainement.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _verifyByPhone() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<CommissionProvider>(context, listen: false);
    provider.clearErrors();

    final success = await provider.verifyCommissionByPhone(
      _phoneController.text.trim(),
      _codeController.text.trim(),
    );

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.success,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Commission vérifiée !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Le montant a été ajouté à votre solde.',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Continuer',
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialog
              Navigator.of(context).pop(); // Retourner au dashboard
            },
            height: 44,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}