import 'package:flutter/material.dart';

import '../models/user_model.dart';

/// =====================================================
/// AppState
/// -----------------------------------------------------
/// Global application state holder.
/// Keeps track of:
/// - Auth status
/// - Current user
/// - Theme mode
/// - Locale
/// - App-level loading & error states
/// =====================================================

class AppState extends ChangeNotifier {
  // ================= AUTH =================

  bool _initialized = false;
  bool _isAuthenticated = false;

  UserModel? _currentUser;
  String? _authToken;

  // ================= UI / SYSTEM =================

  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  bool _globalLoading = false;
  String? _globalError;

  // ================= GETTERS =================

  bool get initialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;

  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  bool get isGlobalLoading => _globalLoading;
  String? get globalError => _globalError;

  // ================= INITIALIZATION =================

  /// Call once at app startup
  void markInitialized() {
    _initialized = true;
    notifyListeners();
  }

  // ================= AUTH METHODS =================

  void setAuthenticated({
    required String token,
    required UserModel user,
  }) {
    _authToken = token;
    _currentUser = user;
    _isAuthenticated = true;
    _globalError = null;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _authToken = null;
    _currentUser = null;
    _isAuthenticated = false;
    _globalError = null;
    notifyListeners();
  }

  // ================= THEME =================

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // ================= LOCALE =================

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  // ================= GLOBAL LOADING =================

  void setGlobalLoading(bool value) {
    _globalLoading = value;
    notifyListeners();
  }

  // ================= GLOBAL ERROR =================

  void setGlobalError(String? message) {
    _globalError = message;
    notifyListeners();
  }

  void clearGlobalError() {
    _globalError = null;
    notifyListeners();
  }

  // ================= RESET =================

  /// Full reset (used on logout / token expiry)
  void reset() {
    _initialized = false;
    _isAuthenticated = false;
    _currentUser = null;
    _authToken = null;
    _globalLoading = false;
    _globalError = null;
    _themeMode = ThemeMode.dark;
    _locale = const Locale('en');
    notifyListeners();
  }
}
