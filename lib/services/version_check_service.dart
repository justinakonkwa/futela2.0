import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';

/// Service de vérification de mise à jour de l'application.
/// Vérifie si une nouvelle version est disponible sur le Play Store / App Store
/// et affiche un dialog si c'est le cas.
class VersionCheckService {
  // IDs de production Futela
  // La vérification ne fonctionnera qu'une fois l'app publiée sur les stores
  static final NewVersionPlus _newVersion = NewVersionPlus(
    androidId: 'com.futelaapp.mobile',
    iOSId: 'com.futelaapp.mobile',
    androidHtmlReleaseNotes: false,
  );

  /// Indique si l'app est publiée sur les stores.
  /// Passer à true une fois l'app live sur App Store / Play Store.
  static const bool _isPublishedOnStores = false;

  /// Vérifie la version et affiche un dialog si une mise à jour est disponible.
  /// [context] : le BuildContext courant (doit être monté).
  /// [forceShow] : si true, affiche le dialog même si canUpdate est false (pour tests).
  static Future<void> checkAndShowUpdateDialog(
    BuildContext context, {
    bool forceShow = false,
  }) async {
    // Ne pas vérifier tant que l'app n'est pas publiée sur les stores
    if (!_isPublishedOnStores) {
      debugPrint('[VersionCheck] ⏭️ App non publiée sur les stores — vérification ignorée');
      return;
    }

    debugPrint('[VersionCheck] 🔍 Début de la vérification...');
    
    try {
      debugPrint('[VersionCheck] 📡 Appel API vers le store...');
      final status = await _newVersion.getVersionStatus();

      debugPrint('[VersionCheck] 📦 Réponse reçue: ${status != null ? "OK" : "NULL"}');
      
      if (status == null) {
        debugPrint('[VersionCheck] ❌ Status null - aucune info disponible');
        return;
      }
      
      if (!context.mounted) {
        debugPrint('[VersionCheck] ⚠️ Context non monté - abandon');
        return;
      }

      debugPrint('[VersionCheck] 📊 Local: ${status.localVersion} | Store: ${status.storeVersion} | canUpdate: ${status.canUpdate}');

      if (status.canUpdate || forceShow) {
        debugPrint('[VersionCheck] ✅ Affichage du dialog (canUpdate: ${status.canUpdate}, forceShow: $forceShow)');
        _newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: 'Mise à jour disponible',
          dialogText:
              'Une nouvelle version (${status.storeVersion}) est disponible.\n'
              'Votre version actuelle est ${status.localVersion}.\n\n'
              'Mettez à jour pour profiter des dernières améliorations.',
          updateButtonText: 'Mettre à jour',
          dismissButtonText: 'Plus tard',
          launchModeVersion: LaunchModeVersion.external,
          allowDismissal: true,
        );
      } else {
        debugPrint('[VersionCheck] ℹ️ Pas de mise à jour nécessaire');
      }
    } catch (e, stackTrace) {
      // Ne pas bloquer l'app si la vérification échoue (pas de réseau, etc.)
      debugPrint('[VersionCheck] ❌ Erreur lors de la vérification : $e');
      debugPrint('[VersionCheck] Stack trace: $stackTrace');
    }
  }
}
