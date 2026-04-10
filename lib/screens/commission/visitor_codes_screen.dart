import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/commission_provider.dart';
import '../../utils/app_colors.dart';

class VisitorCodesScreen extends StatefulWidget {
  const VisitorCodesScreen({super.key});

  @override
  State<VisitorCodesScreen> createState() => _VisitorCodesScreenState();
}

class _VisitorCodesScreenState extends State<VisitorCodesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommissionProvider>(context, listen: false)
          .loadVerificationCodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mes codes de visite',
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<CommissionProvider>(context, listen: false)
              .loadVerificationCodes();
        },
        child: Consumer<CommissionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingCodes) {
              return _buildLoadingSkeleton();
            }

            if (provider.verificationCodes.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.verificationCodes.length,
              itemBuilder: (context, index) {
                final codeData = provider.verificationCodes[index];
                return _buildCodeCard(codeData);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCodeCard(Map<String, dynamic> codeData) {
    final code = codeData['code'] as String?;
    final propertyTitle = codeData['propertyTitle'] as String? ?? 'Propriété inconnue';
    final amount = codeData['amount'] as double? ?? 0.0;
    final currency = codeData['currency'] as String? ?? 'USD';
    final expiresAt = codeData['expiresAt'] != null 
        ? DateTime.parse(codeData['expiresAt']) 
        : null;
    final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired ? AppColors.error.withOpacity(0.3) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  propertyTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isExpired 
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isExpired 
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isExpired ? 'Expiré' : 'Actif',
                  style: TextStyle(
                    color: isExpired ? AppColors.error : AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Code de vérification
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isExpired 
                    ? [Colors.grey[400]!, Colors.grey[500]!]
                    : [AppColors.primary, const Color(0xFF4A90E2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Code de vérification',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  code ?? '------',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Montrez ce code au commissionnaire',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Informations de la visite
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: CupertinoIcons.money_dollar,
                  label: 'Montant payé',
                  value: '${amount.toStringAsFixed(2)} $currency',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: CupertinoIcons.clock,
                  label: expiresAt != null ? 'Expire' : 'Statut',
                  value: expiresAt != null 
                      ? _formatExpiration(expiresAt)
                      : 'Permanent',
                ),
              ),
            ],
          ),
          
          if (!isExpired) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle,
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Présentez ce code au commissionnaire lors de votre visite pour qu\'il puisse valider sa commission.',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.qrcode,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun code disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vos codes de vérification apparaîtront ici après avoir payé une visite.',
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiration(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    
    if (difference.isNegative) {
      return 'Expiré';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h restantes';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min restantes';
    } else {
      return 'Expire bientôt';
    }
  }
}