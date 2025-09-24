import '../models/user.dart';

class RolePermissions {
  // Rôles disponibles
  static const String superAdmin = 'superadmin';
  static const String admin = 'admin';
  static const String standard = 'standard';
  static const String premium = 'premium';
  static const String agent = 'agent';
  static const String owner = 'owner';

  // Vérifier si l'utilisateur peut ajouter des propriétés
  static bool canAddProperties(User user) {
    return [
      superAdmin,
      admin,
      agent,
      owner,
    ].contains(user.role.toLowerCase());
  }

  // Vérifier si l'utilisateur peut gérer les visites
  static bool canManageVisits(User user) {
    return [
      superAdmin,
      admin,
      agent,
      owner,
    ].contains(user.role.toLowerCase());
  }

  // Vérifier si l'utilisateur peut voir les statistiques
  static bool canViewStatistics(User user) {
    return [
      superAdmin,
      admin,
      agent,
    ].contains(user.role.toLowerCase());
  }

  // Vérifier si l'utilisateur peut gérer les utilisateurs
  static bool canManageUsers(User user) {
    return [
      superAdmin,
      admin,
    ].contains(user.role.toLowerCase());
  }

  // Vérifier si l'utilisateur peut accéder aux paramètres avancés
  static bool canAccessAdvancedSettings(User user) {
    return [
      superAdmin,
      admin,
    ].contains(user.role.toLowerCase());
  }

  // Vérifier si l'utilisateur peut demander des retraits
  static bool canRequestWithdrawal(User user) {
    return [
      superAdmin,
      admin,
      agent,
      owner,
    ].contains(user.role.toLowerCase());
  }

  // Vérifier si l'utilisateur peut voir l'historique des paiements
  static bool canViewPaymentHistory(User user) {
    return [
      superAdmin,
      admin,
      agent,
      owner,
    ].contains(user.role.toLowerCase());
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
    return [
      superAdmin,
      admin,
      agent,
      owner,
    ].contains(user.role.toLowerCase());
  }

  // Vérifier si l'utilisateur peut voir ses propres visites
  static bool canViewOwnVisits(User user) {
    // Tous les utilisateurs peuvent voir leurs propres visites
    return true;
  }

  // Obtenir le nom d'affichage du rôle
  static String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case superAdmin:
        return 'Super Administrateur';
      case admin:
        return 'Administrateur';
      case agent:
        return 'Agent';
      case owner:
        return 'Propriétaire';
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
    switch (role.toLowerCase()) {
      case superAdmin:
        return '#FF6B35'; // Orange
      case admin:
        return '#E31C5F'; // Rouge
      case agent:
        return '#00A699'; // Vert
      case owner:
        return '#4DB6AC'; // Vert clair
      case premium:
        return '#FFB400'; // Jaune
      case standard:
        return '#666666'; // Gris
      default:
        return '#999999'; // Gris clair
    }
  }
}
