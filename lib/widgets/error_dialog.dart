import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Dialog élégant pour afficher les erreurs (connexion, réseau, etc.)
abstract final class ErrorDialog {
  /// Affiche un dialog pour les erreurs de connexion réseau
  static Future<void> showNetworkError(
    BuildContext context, {
    String? customMessage,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ErrorDialogContent(
        icon: Icons.wifi_off_rounded,
        iconColor: AppColors.warning,
        title: 'Problème de connexion',
        message: customMessage ??
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet et réessayez.',
        primaryButtonText: 'Réessayer',
        onPrimaryPressed: () => Navigator.of(ctx).pop(true),
        secondaryButtonText: 'Fermer',
        onSecondaryPressed: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  /// Affiche un dialog pour les erreurs d'authentification
  static Future<void> showAuthError(
    BuildContext context, {
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ErrorDialogContent(
        icon: Icons.lock_outline_rounded,
        iconColor: AppColors.error,
        title: 'Erreur de connexion',
        message: message,
        primaryButtonText: 'Compris',
        onPrimaryPressed: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  /// Affiche un dialog pour les erreurs génériques
  static Future<void> showGenericError(
    BuildContext context, {
    required String message,
    String title = 'Une erreur est survenue',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ErrorDialogContent(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        title: title,
        message: message,
        primaryButtonText: 'Fermer',
        onPrimaryPressed: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  /// Affiche un dialog pour les erreurs de timeout
  static Future<void> showTimeoutError(
    BuildContext context, {
    String? customMessage,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ErrorDialogContent(
        icon: Icons.schedule_rounded,
        iconColor: AppColors.warning,
        title: 'Délai dépassé',
        message: customMessage ??
            'Le serveur met trop de temps à répondre. Vérifiez votre connexion ou réessayez plus tard.',
        primaryButtonText: 'Réessayer',
        onPrimaryPressed: () => Navigator.of(ctx).pop(true),
        secondaryButtonText: 'Fermer',
        onSecondaryPressed: () => Navigator.of(ctx).pop(false),
      ),
    );
  }
}

class _ErrorDialogContent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const _ErrorDialogContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 22),

            // Titre
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 28),

            // Boutons
            Column(
              children: [
                // Bouton principal
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onPrimaryPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      primaryButtonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Bouton secondaire (optionnel)
                if (secondaryButtonText != null && onSecondaryPressed != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onSecondaryPressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).textTheme.displayLarge?.color,
                        side: BorderSide(
                          color: isDark
                              ? Colors.grey[700]!
                              : AppColors.border.withOpacity(0.9),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        secondaryButtonText!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
