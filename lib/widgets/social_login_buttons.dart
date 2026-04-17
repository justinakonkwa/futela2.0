import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../screens/auth/profile_completion_wrapper.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogleSuccess;
  final VoidCallback? onAppleSuccess;
  final bool showDivider;
  final bool Function()? validateBeforeAction;

  const SocialLoginButtons({
    super.key,
    this.onGoogleSuccess,
    this.onAppleSuccess,
    this.showDivider = true,
    this.validateBeforeAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) ...[
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.grey300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ou',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.grey300)),
            ],
          ),
          const SizedBox(height: 20),
        ],
        // Boutons de connexion sociale avec icônes uniquement
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton Google
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey300),
                    color: AppColors.white,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(35),
                      onTap: authProvider.isLoading
                          ? null
                          : () async {
                              // Validation avant action si fournie
                              if (validateBeforeAction != null &&
                                  !validateBeforeAction!()) {
                                return;
                              }

                              final success =
                                  await authProvider.signInWithGoogle();
                              if (success && context.mounted) {
                                if (onGoogleSuccess != null) {
                                  onGoogleSuccess!();
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileCompletionWrapper(),
                                    ),
                                  );
                                }
                              } else if (context.mounted &&
                                  authProvider.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.error!),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                      child: Center(
                        child: Image.asset(
                          'assets/icons/google_logo.png',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Bouton Apple (iOS uniquement)
                if (Theme.of(context).platform == TargetPlatform.iOS)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.grey300),
                      color: AppColors.white,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(35),
                        onTap: authProvider.isLoading
                            ? null
                            : () async {
                                // Validation avant action si fournie
                                if (validateBeforeAction != null &&
                                    !validateBeforeAction!()) {
                                  return;
                                }

                                print(
                                    '🖱️ [Login UI] Bouton Apple Sign-In cliqué');
                                final success =
                                    await authProvider.signInWithApple();
                                if (success && context.mounted) {
                                  print(
                                      '✅ [Login UI] Connexion Apple réussie, navigation vers MainNavigation');
                                  if (onAppleSuccess != null) {
                                    onAppleSuccess!();
                                  } else {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileCompletionWrapper(),
                                      ),
                                    );
                                  }
                                } else if (context.mounted &&
                                    authProvider.error != null) {
                                  print(
                                      '❌ [Login UI] Erreur Apple Sign-In: ${authProvider.error}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(authProvider.error!),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                        child: Center(
                          child: Image.asset(
                            'assets/icons/ios_logo.png',
                           
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
