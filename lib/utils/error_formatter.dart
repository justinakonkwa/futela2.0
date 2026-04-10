class ErrorFormatter {
  /// Traduit une erreur technique en message lisible pour l'utilisateur
  static String format(String? error) {
    if (error == null || error.isEmpty) return 'Une erreur est survenue.';

    final e = error.toLowerCase();

    // Timeout / connexion lente
    if (e.contains('connection timeout') || e.contains('connecttimeout') || e.contains('connect timeout')) {
      return 'La connexion a pris trop de temps. Vérifiez votre réseau et réessayez.';
    }

    // Pas de connexion internet
    if (e.contains('socketexception') || e.contains('network is unreachable') ||
        e.contains('failed host lookup') || e.contains('no address associated')) {
      return 'Pas de connexion internet. Vérifiez votre réseau.';
    }

    // Receive timeout
    if (e.contains('receive timeout') || e.contains('receivetimeout')) {
      return 'Le serveur met trop de temps à répondre. Réessayez dans un moment.';
    }

    // Send timeout
    if (e.contains('send timeout')) {
      return 'Impossible d\'envoyer la requête. Vérifiez votre connexion.';
    }

    // Erreurs HTTP
    if (e.contains('401') || e.contains('unauthorized')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }
    if (e.contains('403') || e.contains('forbidden') || e.contains('access denied')) {
      return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
    }
    if (e.contains('404') || e.contains('not found')) {
      return 'Contenu introuvable.';
    }
    if (e.contains('500') || e.contains('server error') || e.contains('internal server')) {
      return 'Erreur serveur. Réessayez dans un moment.';
    }
    if (e.contains('503') || e.contains('service unavailable')) {
      return 'Service temporairement indisponible. Réessayez plus tard.';
    }

    // Erreur SSL / certificat
    if (e.contains('handshake') || e.contains('certificate') || e.contains('ssl')) {
      return 'Erreur de sécurité. Vérifiez votre connexion.';
    }

    // Erreur de parsing JSON
    if (e.contains('formatexception') || e.contains('type') && e.contains('subtype')) {
      return 'Erreur de données reçues. Réessayez.';
    }

    // Message trop long ou technique → message générique
    if (error.length > 100 || e.contains('dioexception') || e.contains('exception')) {
      return 'Une erreur est survenue. Vérifiez votre connexion et réessayez.';
    }

    return error;
  }
}
