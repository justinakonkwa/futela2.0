import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isRejected = user?.approvalStatus == 'rejected';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRejected
                      ? AppColors.error.withValues(alpha: 0.1)
                      : Colors.amber.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isRejected
                      ? CupertinoIcons.xmark_circle_fill
                      : CupertinoIcons.clock_fill,
                  size: 52,
                  color: isRejected ? AppColors.error : Colors.amber.shade700,
                ),
              ),
              const SizedBox(height: 28),

              // Titre
              Text(
                isRejected ? 'Demande refusée' : 'Compte en attente',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                      letterSpacing: -0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                isRejected
                    ? 'Votre demande de compte commissionnaire a été refusée. Veuillez contacter le support pour plus d\'informations.'
                    : 'Votre compte commissionnaire est en cours de validation par notre équipe. Vous serez notifié dès que votre compte sera approuvé.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Badge statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isRejected
                      ? AppColors.error.withValues(alpha: 0.1)
                      : Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isRejected
                        ? AppColors.error.withValues(alpha: 0.3)
                        : Colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRejected ? AppColors.error : Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRejected ? 'Refusé' : 'En attente d\'approbation',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isRejected ? AppColors.error : Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isRejected) ...[
                const SizedBox(height: 40),
                // Info délai
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.info_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'La validation prend généralement 24 à 48 heures ouvrables.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Bouton rafraîchir
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().refreshCurrentUser();
                  },
                  icon: const Icon(CupertinoIcons.refresh, size: 18),
                  label: const Text('Vérifier le statut'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
