import 'package:flutter/foundation.dart';
import '../models/commission/commission.dart';
import '../models/commission/withdrawal.dart';
import '../models/commission/wallet.dart';
import '../services/commission_service.dart';

class CommissionProvider with ChangeNotifier {
  final CommissionService _commissionService = CommissionService();

  // État du wallet
  CommissionnaireWallet? _wallet;
  bool _isLoadingWallet = false;
  String? _walletError;

  // État des commissions
  List<Commission> _commissions = [];
  bool _isLoadingCommissions = false;
  String? _commissionsError;
  int _currentPage = 1;
  bool _hasMoreCommissions = true;

  // État des retraits
  List<Withdrawal> _withdrawals = [];
  bool _isLoadingWithdrawals = false;
  String? _withdrawalsError;

  // État de vérification
  bool _isVerifying = false;
  String? _verificationError;

  // État des codes de vérification (pour les visiteurs)
  List<Map<String, dynamic>> _verificationCodes = [];
  bool _isLoadingCodes = false;

  // Getters
  CommissionnaireWallet? get wallet => _wallet;
  bool get isLoadingWallet => _isLoadingWallet;
  String? get walletError => _walletError;

  List<Commission> get commissions => _commissions;
  bool get isLoadingCommissions => _isLoadingCommissions;
  String? get commissionsError => _commissionsError;
  bool get hasMoreCommissions => _hasMoreCommissions;

  List<Withdrawal> get withdrawals => _withdrawals;
  bool get isLoadingWithdrawals => _isLoadingWithdrawals;
  String? get withdrawalsError => _withdrawalsError;

  bool get isVerifying => _isVerifying;
  String? get verificationError => _verificationError;

  List<Map<String, dynamic>> get verificationCodes => _verificationCodes;
  bool get isLoadingCodes => _isLoadingCodes;

  /// Charger le wallet
  Future<void> loadWallet() async {
    _isLoadingWallet = true;
    _walletError = null;
    notifyListeners();

    try {
      _wallet = await _commissionService.getWallet();
      _walletError = null;
    } catch (e) {
      _walletError = e.toString();
      debugPrint('Erreur chargement wallet: $e');
    } finally {
      _isLoadingWallet = false;
      notifyListeners();
    }
  }

  /// Charger les commissions
  Future<void> loadCommissions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _commissions.clear();
      _hasMoreCommissions = true;
    }

    if (_isLoadingCommissions || !_hasMoreCommissions) return;

    _isLoadingCommissions = true;
    _commissionsError = null;
    notifyListeners();

    try {
      final newCommissions = await _commissionService.getCommissions(
        page: _currentPage,
        limit: 20,
      );

      if (newCommissions.isEmpty) {
        _hasMoreCommissions = false;
      } else {
        if (refresh) {
          _commissions = newCommissions;
        } else {
          _commissions.addAll(newCommissions);
        }
        _currentPage++;
      }
      _commissionsError = null;
    } catch (e) {
      _commissionsError = e.toString();
      debugPrint('Erreur chargement commissions: $e');
    } finally {
      _isLoadingCommissions = false;
      notifyListeners();
    }
  }

  /// Vérifier une commission avec le code OTP
  Future<bool> verifyCommission(String commissionId, String code) async {
    _isVerifying = true;
    _verificationError = null;
    notifyListeners();

    try {
      final verifiedCommission = await _commissionService.verifyCommission(
        commissionId,
        code,
      );

      // Mettre à jour la commission dans la liste
      final index = _commissions.indexWhere((c) => c.id == commissionId);
      if (index != -1) {
        _commissions[index] = verifiedCommission;
      }

      // Recharger le wallet pour mettre à jour le solde
      await loadWallet();

      _verificationError = null;
      return true;
    } catch (e) {
      _verificationError = e.toString();
      debugPrint('Erreur vérification commission: $e');
      return false;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  /// Trouver et vérifier une commission par téléphone
  Future<bool> verifyCommissionByPhone(String phoneNumber, String code) async {
    _isVerifying = true;
    _verificationError = null;
    notifyListeners();

    try {
      final verifiedCommission = await _commissionService.findCommissionByPhone(
        phoneNumber,
        code,
      );

      // Ajouter ou mettre à jour la commission dans la liste
      final index = _commissions.indexWhere((c) => c.id == verifiedCommission.id);
      if (index != -1) {
        _commissions[index] = verifiedCommission;
      } else {
        _commissions.insert(0, verifiedCommission);
      }

      // Recharger le wallet
      await loadWallet();

      _verificationError = null;
      return true;
    } catch (e) {
      _verificationError = e.toString();
      debugPrint('Erreur vérification par téléphone: $e');
      return false;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  /// Charger les retraits
  Future<void> loadWithdrawals({bool refresh = false}) async {
    _isLoadingWithdrawals = true;
    _withdrawalsError = null;
    notifyListeners();

    try {
      _withdrawals = await _commissionService.getWithdrawals();
      _withdrawalsError = null;
    } catch (e) {
      _withdrawalsError = e.toString();
      debugPrint('Erreur chargement retraits: $e');
    } finally {
      _isLoadingWithdrawals = false;
      notifyListeners();
    }
  }

  /// Demander un retrait
  Future<bool> requestWithdrawal({
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      final withdrawal = await _commissionService.requestWithdrawal(
        amount: amount,
        phoneNumber: phoneNumber,
      );

      // Ajouter le nouveau retrait en tête de liste
      _withdrawals.insert(0, withdrawal);

      // Recharger le wallet pour mettre à jour le solde
      await loadWallet();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur demande retrait: $e');
      return false;
    }
  }

  /// Charger les codes de vérification (pour les visiteurs)
  Future<void> loadVerificationCodes() async {
    _isLoadingCodes = true;
    notifyListeners();

    try {
      _verificationCodes = await _commissionService.getVerificationCodes();
    } catch (e) {
      debugPrint('Erreur chargement codes: $e');
    } finally {
      _isLoadingCodes = false;
      notifyListeners();
    }
  }

  /// Nettoyer les erreurs
  void clearErrors() {
    _walletError = null;
    _commissionsError = null;
    _withdrawalsError = null;
    _verificationError = null;
    notifyListeners();
  }
}