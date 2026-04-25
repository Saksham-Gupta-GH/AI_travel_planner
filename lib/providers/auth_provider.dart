import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _userModel != null;
  String get userRole => _userModel?.role ?? '';
  String get userName => _userModel?.name ?? '';
  String get userId => _userModel?.id ?? '';

  // Initialize auth state
  Future<void> initializeAuth() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _userModel = await _authService.getUserData(user.uid);
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    // Defer notifyListeners to after the build phase
    Future.microtask(() => notifyListeners());
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.loginWithEmailPassword(
        email: email,
        password: password,
      );
      
      if (user != null && !user.isApproved) {
        await _authService.logout();
        _error = 'Account awaiting administrative approval.';
        _setLoading(false);
        return false;
      }

      _userModel = user;
      _setLoading(false);
      return _userModel != null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.registerWithEmailPassword(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      
      if (user != null && !user.isApproved) {
        await _authService.logout();
        _error = 'Registration successful. Awaiting admin approval.';
        _setLoading(false);
        return false;
      }

      _userModel = user;
      _setLoading(false);
      return _userModel != null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _userModel = null;
    _setLoading(false);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
