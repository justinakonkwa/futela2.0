import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class AuthHelper {
  /// Vérifie si l'utilisateur est connecté et redirige vers la connexion si nécessaire
  /// Retourne true si l'utilisateur est connecté, false sinon
  static bool requireAuth(BuildContext context, {String? message}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      // Afficher un message optionnel
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Rediriger vers la page de connexion
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      
      return false;
    }
    
    return true;
  }

  /// Vérifie si l'utilisateur est connecté de manière asynchrone
  /// Utile pour les actions qui nécessitent une vérification avant exécution
  static Future<bool> requireAuthAsync(BuildContext context, {String? message}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      // Afficher un message optionnel
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Rediriger vers la page de connexion et attendre le résultat
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      
      // Vérifier si l'utilisateur s'est connecté
      return result == true && authProvider.isAuthenticated;
    }
    
    return true;
  }

  /// Affiche un dialog demandant à l'utilisateur de se connecter
  static Future<bool> showAuthDialog(BuildContext context, {
    String title = 'Connexion requise',
    String message = 'Vous devez vous connecter pour accéder à cette fonctionnalité.',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}