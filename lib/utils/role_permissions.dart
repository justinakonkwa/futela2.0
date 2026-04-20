import '../models/user.dart';

class RolePermissions {
  // Rôles API (après normalisation, sans préfixe ROLE_)
  static const String superAdmin = 'super_admin';
  static const String admin = 'admin';
  static const String user = 'user';
  static const String commissionnaire = 'commissionnaire';
  static const String owner = 'owner';
  static const String agent = 'agent';
  static const String premium = 'premium';

  /// Normalise un rôle : retire ROLE_, met en minuscule
  static String _normalize(String role) {
    var r = role.toLowerCase().trim();
    if (r.startsWith('role_')) r = r.substring(5);
    return r;
  }

  /// Vérifie si l'utilisateur possède au moins un des rôles donnés
  static bool _hasAnyRole(User user, List<String> roles) {
    return user.roles.any((r) => roles.contains(_normalize(r)));
  }

  // ─── Permissions ────────────────────────────────────────────────────────────

  static bool canAddProperties(User user) =>
      _hasAnyRole(user, [superAdmin, admin, commissionnaire, owner, agent]);

  static bool canManageVisits(User user) =>
      _hasAnyRole(user, [superAdmin, admin, commissionnaire, owner, agent]);

  static bool canViewStatistics(User user) =>
      _hasAnyRole(user, [superAdmin, admin, agent]);

  static bool canManageUsers(User user) =>
      _hasAnyRole(user, [superAdmin, admin]);

  static bool canAccessAdvancedSettings(User user) =>
      _hasAnyRole(user, [superAdmin, admin]);

  static bool canRequestWithdrawal(User user) =>
      _hasAnyRole(user, [superAdmin, admin, commissionnaire, owner, agent]);

  static bool canViewPaymentHistory(User user) => true; // Tous les users

  static bool canManageFavorites(User user) => true;

  static bool canRequestVisits(User user) => true;

  static bool canViewOwnProperties(User user) => user.roles.isNotEmpty;

  static bool canViewOwnVisits(User user) => true;

  static bool isCommissionnaire(User user) =>
      _hasAnyRole(user, [commissionnaire, admin, superAdmin]);

  static bool isAdmin(User user) =>
      _hasAnyRole(user, [admin, superAdmin]);

  static bool canAccessCommissionFeatures(User user) {
    if (!_hasAnyRole(user, [commissionnaire, admin, superAdmin])) return false;
    // Pour les commissionnaires, vérifier que le compte est approuvé
    // Si approvalStatus est null (non renvoyé par l'API), on considère approuvé
    if (_hasAnyRole(user, [commissionnaire]) &&
        !_hasAnyRole(user, [admin, superAdmin])) {
      return user.approvalStatus == null || user.approvalStatus == 'approved';
    }
    return true;
  }

  // ─── Affichage ──────────────────────────────────────────────────────────────

  /// Retourne le label du rôle le plus important de l'utilisateur
  static String getPrimaryRoleLabel(User user) {
    final normalized = user.roles.map(_normalize).toList();
    if (normalized.contains(superAdmin)) return 'Super Admin';
    if (normalized.contains(admin)) return 'Administrateur';
    if (normalized.contains(commissionnaire)) return 'Commissionnaire';
    if (normalized.contains(owner)) return 'Propriétaire';
    if (normalized.contains(agent)) return 'Agent';
    if (normalized.contains(premium)) return 'Premium';
    return 'Utilisateur';
  }

  /// Retourne tous les labels de rôles (sauf ROLE_USER si d'autres existent)
  static List<String> getAllRoleLabels(User user) {
    final normalized = user.roles.map(_normalize).toList();
    final labels = <String>[];
    if (normalized.contains(superAdmin)) labels.add('Super Admin');
    if (normalized.contains(admin)) labels.add('Administrateur');
    if (normalized.contains(commissionnaire)) labels.add('Commissionnaire');
    if (normalized.contains(owner)) labels.add('Propriétaire');
    if (normalized.contains(agent)) labels.add('Agent');
    if (normalized.contains(premium)) labels.add('Premium');
    // Afficher "Utilisateur" seulement si pas d'autre rôle
    if (labels.isEmpty) labels.add('Utilisateur');
    return labels;
  }

  static String getRoleDisplayName(String role) {
    switch (_normalize(role)) {
      case superAdmin: return 'Super Administrateur';
      case admin: return 'Administrateur';
      case commissionnaire: return 'Commissionnaire';
      case owner: return 'Propriétaire';
      case agent: return 'Agent';
      case premium: return 'Premium';
      case user: return 'Utilisateur';
      default: return 'Utilisateur';
    }
  }

  static String getRoleColor(String role) {
    switch (_normalize(role)) {
      case superAdmin: return '#FF6B35';
      case admin: return '#E31C5F';
      case commissionnaire: return '#9C27B0';
      case owner: return '#4DB6AC';
      case agent: return '#00A699';
      case premium: return '#FFB400';
      default: return '#666666';
    }
  }
}
