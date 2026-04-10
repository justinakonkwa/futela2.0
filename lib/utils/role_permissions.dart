import '../models/user.dart';

class RolePermissions {
  // Rôles disponibles
  static const String superAdmin = 'superadmin';
  static const String admin = 'admin';
  static const String standard = 'standard';
  static const String premium = 'premium';
  static const String agent = 'agent';
  static const String owner = 'owner';
  static const String commissionnaire = 'commissionnaire';

  // Normaliser le rôle (gérer les formats avec et sans préfixe ROLE_)
  static String _normalizeRole(String role) {
    String normalized = role.toLowerCase();
    // Retirer le préfixe ROLE_ si présent
    if (normalized.startsWith('role_')) {
      normalized = normalized.substring(5);
    }
    return normalized;
  }

  // Vérifier si l'utilisateur peut ajouter des propriétés
  static bool canAddProperties(User user) {
    // Vérifier tous les rôles de l'utilisateur
    for (String userRole in user.roles) {
      String normalizedRole = _normalizeRole(userRole);
      // Autoriser les rôles avec permissions
      if ([
        superAdmin,
        admin,
        agent,
        owner,
      ].contains(normalizedRole)) {
        return true;
      }
    }
    return false;
  }

  // Vérifier si l'utilisateur peut gérer les visites
  static bool canManageVisits(User user) {
    for (String userRole in user.roles) {
      String normalizedRole = _normalizeRole(userRole);
      if ([superAdmin, admin, agent, owner].contains(normalizedRole)) {
        return true;
      }
    }
    return false;
  }

  // Vérifier si l'utilisateur peut voir les statistiques
  static bool canViewStatistics(User user) {
    for (String userRole in user.roles) {
      String normalizedRole = _normalizeRole(userRole);
      if ([superAdmin, admin, agent].contains(normalizedRole)) {
        return true;
      }
    }
    return false;
  }

  // Vérifier si l'utilisateur peut gérer les utilisateurs
  static bool canManageUsers(User user) {
    for (String userRole in user.roles) {
      String normalizedRole = _normalizeRole(userRole);
      if ([superAdmin, admin].contains(normalizedRole)) {
        return true;
      }
    }
    return false;
  }

  // Vérifier si l'utilisateur peut accéder aux paramètres avancés
  static bool canAccessAdvancedSettings(User user) {
    for (String userRole in user.roles) {
      String normalizedRole = _normalizeRole(userRole);
      if ([superAdmin, admin].contains(normalizedRole)) {
        return true;
      }
    }
    return false;
  }

  // Vérifier si l'utilisateur peut demander des retraits
  static bool canRequestWithdrawal(User user) {
    for (String userRole in user.roles) {
      String normalizedRole = _normalizeRole(userRole);
      if ([superAdmin, admin, agent, owner].contains(normalizedRole)) {
        return true;
      }
    }
    return false;
  }

  // Vérifier si l'utilisateur peut voir l'historique des paiements
  /// Même périmètre que les visites : données `GET /me/visits` (utilisateur connecté).
  static bool canViewPaymentHistory(User user) {
    return canViewOwnVisits(user);
  }

  // Vérifier si l'utilisateur peut gérer les favoris
  static bool canManageFavorites(User user) {
    // Tous les utilisateurs peuvent gérer leurs favoris
    return true;
  }

  // Vérifier si l'utilisateur peut demander des visites
  static bool canRequestVisits(User user) {
    // Tous les utilisateurs peuvent demander des visites
    return true;
  }

  // Vérifier si l'utilisateur peut voir ses propres propriétés
  static bool canViewOwnProperties(User user) {
    // Tous les utilisateurs authentifiés peuvent voir leurs propres propriétés
    // Si l'utilisateur a des rôles, il peut voir ses propriétés
    return user.roles.isNotEmpty;
  }

  // Vérifier si l'utilisateur peut voir ses propres visites
  static bool canViewOwnVisits(User user) {
    // Tous les utilisateurs peuvent voir leurs propres visites
    return true;
  }

  // Vérifier si l'utilisateur est commissionnaire
  static bool isCommissionnaire(User user) {
    for (String userRole in user.roles) {
      String normalizedRole = _normalizeRole(userRole);
      if (normalizedRole == commissionnaire) {
        return true;
      }
    }
    return false;
  }

  // Vérifier si l'utilisateur peut accéder aux fonctionnalités de commission
  static bool canAccessCommissionFeatures(User user) {
    return isCommissionnaire(user);
  }
  static String getRoleDisplayName(String role) {
    String normalizedRole = _normalizeRole(role);
    switch (normalizedRole) {
      case superAdmin:
        return 'Super Administrateur';
      case admin:
        return 'Administrateur';
      case agent:
        return 'Agent';
      case owner:
        return 'Propriétaire';
      case commissionnaire:
        return 'Commissionnaire';
      case premium:
        return 'Premium';
      case standard:
        return 'Standard';
      default:
        return 'Utilisateur';
    }
  }

  // Obtenir la couleur du rôle
  static String getRoleColor(String role) {
    String normalizedRole = _normalizeRole(role);
    switch (normalizedRole) {
      case superAdmin:
        return '#FF6B35'; // Orange
      case admin:
        return '#E31C5F'; // Rouge
      case agent:
        return '#00A699'; // Vert
      case owner:
        return '#4DB6AC'; // Vert clair
      case commissionnaire:
        return '#9C27B0'; // Violet
      case premium:
        return '#FFB400'; // Jaune
      case standard:
        return '#666666'; // Gris
      default:
        return '#999999'; // Gris clair
    }
  }
}
