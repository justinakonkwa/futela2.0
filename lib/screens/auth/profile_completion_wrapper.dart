import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_navigation.dart';
import 'role_selection_screen.dart';

/// Wrapper qui vérifie si le profil est complété après une connexion OAuth
/// et redirige vers l'écran de sélection de rôle si nécessaire
class ProfileCompletionWrapper extends StatelessWidget {
  const ProfileCompletionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        // Si pas d'utilisateur, ne devrait pas arriver ici
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si le profil n'est pas complété, rediriger vers la sélection de rôle
        if (!user.profileCompleted) {
          return const RoleSelectionScreen();
        }

        // Sinon, afficher la navigation principale
        return const MainNavigation();
      },
    );
  }
}
