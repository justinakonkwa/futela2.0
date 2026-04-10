import 'package:flutter/foundation.dart';
import '../models/user/public_profile.dart';
import '../services/public_profile_service.dart';

class PublicProfileProvider with ChangeNotifier {
  final PublicProfileService _service = PublicProfileService();

  PublicProfile? _profile;
  List<PublicPropertyItem> _properties = [];
  bool _isLoadingProfile = false;
  bool _isLoadingProperties = false;
  String? _error;

  PublicProfile? get profile => _profile;
  List<PublicPropertyItem> get properties => _properties;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingProperties => _isLoadingProperties;
  String? get error => _error;

  Future<void> loadProfile({required String userId}) async {
    _isLoadingProfile = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getPublicProfile(userId: userId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadProperties({required String userId}) async {
    _isLoadingProperties = true;
    notifyListeners();

    try {
      _properties = await _service.getUserProperties(userId: userId);
    } catch (e) {
      _properties = [];
    } finally {
      _isLoadingProperties = false;
      notifyListeners();
    }
  }

  void reset() {
    _profile = null;
    _properties = [];
    _isLoadingProfile = false;
    _isLoadingProperties = false;
    _error = null;
    notifyListeners();
  }
}
