import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_navigation.dart';
import 'role_selection_screen.dart';

/// Wrapper qui vérifie si le profil est complété après une connexion OAuth.
/// Seuls les commissionnaires avec profileCompleted=false sont bloqués.
/// Les visiteurs (ROLE_USER) accèdent directement à l'app.
class ProfileCompletionWrapper extends StatelessWidget {
  const ProfileCompletionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Commissionnaire sans profil complété → complétion obligatoire
        final isCommissionnaire = user.roles.contains('ROLE_COMMISSIONNAIRE');
        if (isCommissionnaire && !user.profileCompleted) {
          return const RoleSelectionScreen();
        }

        // Tous les autres (visiteurs, propriétaires, etc.) → accès direct
        return const MainNavigation();
      },
    );
  }
}
