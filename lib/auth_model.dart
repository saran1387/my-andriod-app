// auth_model.dart ─────────────────────────────────────────────────────────
// Handles login/signup/logout AND owns the persistence lifecycle for
// per-user Cart + Favourites data (saved on logout, restored on login).
//
// Storage: shared_preferences (key-value, survives app restarts).
// Add to pubspec.yaml:
//   dependencies:
//     shared_preferences: ^2.2.2

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_model.dart';
import 'favourites_model.dart';

class UserProfile {
  String name;
  String email;
  String phone;
  String? avatarInitials;

  UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
  }) : avatarInitials = name.isNotEmpty ? name[0].toUpperCase() : '?';

  void update({String? name, String? email, String? phone}) {
    if (name != null && name.isNotEmpty) {
      this.name = name;
      avatarInitials = name[0].toUpperCase();
    }
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
  }
}

class AuthManager {
  AuthManager._();
  static final AuthManager instance = AuthManager._();

  UserProfile? _user;
  final CartManager _cart = CartManager();
  final FavouritesManager _favs = FavouritesManager.instance;

  bool get isLoggedIn => _user != null;
  UserProfile? get user => _user;

  // ── Storage key helpers — scoped per user email ─────────────────────────────
  String _cartKey(String email) => 'cart_data_${email.toLowerCase()}';
  String _favsKey(String email) => 'favs_data_${email.toLowerCase()}';

  /// Call once at app startup (e.g. in main()) to silently restore a
  /// previously logged-in session, if you choose to persist login state too.
  /// Optional — omit if you want users to always log in fresh on app launch.
  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('last_logged_in_email');
    final savedName = prefs.getString('last_logged_in_name');
    if (savedEmail != null && savedName != null) {
      _user = UserProfile(name: savedName, email: savedEmail);
      await _restoreUserData(savedEmail);
    }
  }

  /// Returns null on success, error message on failure.
  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return 'Please fill all fields';
    if (!email.contains('@')) return 'Enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';

    final normalizedEmail = email.trim();
    _user = UserProfile(
      name: normalizedEmail.split('@').first,
      email: normalizedEmail,
    );

    await _restoreUserData(normalizedEmail);
    await _rememberSession(normalizedEmail, _user!.name);
    return null;
  }

  /// Returns null on success, error message on failure.
  Future<String?> signup(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Please fill all fields';
    }
    if (!email.contains('@')) return 'Enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';

    final normalizedEmail = email.trim();
    _user = UserProfile(name: name.trim(), email: normalizedEmail);

    // New account — start with empty cart/favourites (clears any stale state)
    _cart.clear();
    _favs.clear();
    await _rememberSession(normalizedEmail, _user!.name);
    return null;
  }

  /// Logs out: SAVES current cart/favourites under this user's key,
  /// then CLEARS the in-memory cart/favourites so the next user (or guest
  /// view) doesn't see this user's data.
  Future<void> logout() async {
    if (_user != null) {
      await _persistUserData(_user!.email);
    }
    _cart.clear();
    _favs.clear();
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_logged_in_email');
    await prefs.remove('last_logged_in_name');
  }

  void updateProfile({String? name, String? email, String? phone}) {
    _user?.update(name: name, email: email, phone: phone);
  }

  /// Call this after any cart/favourites mutation (add/remove/toggle) while
  /// a user is logged in, so data survives an app kill — not just a clean
  /// logout. No-op when logged out (guest actions aren't persisted).
  Future<void> autoSaveIfLoggedIn() async {
    if (_user != null) {
      await _persistUserData(_user!.email);
    }
  }

  // ── Internal persistence ─────────────────────────────────────────────────

  Future<void> _persistUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey(email), jsonEncode(_cart.toJsonList()));
    await prefs.setString(_favsKey(email), jsonEncode(_favs.toJsonList()));
  }

  Future<void> _restoreUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    _cart.clear();
    _favs.clear();

    final cartJson = prefs.getString(_cartKey(email));
    if (cartJson != null) {
      try {
        _cart.restoreFromJsonList(jsonDecode(cartJson) as List<dynamic>);
      } catch (_) {
        // Corrupt or outdated data — start fresh rather than crash.
      }
    }

    final favsJson = prefs.getString(_favsKey(email));
    if (favsJson != null) {
      try {
        _favs.restoreFromJsonList(jsonDecode(favsJson) as List<dynamic>);
      } catch (_) {}
    }
  }

  Future<void> _rememberSession(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_logged_in_email', email);
    await prefs.setString('last_logged_in_name', name);
  }
}