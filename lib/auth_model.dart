// auth_model.dart  ─────────────────────────────────────────────────────────
// Simple in-memory auth singleton.  Replace with real backend / Firebase later.

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

  bool get isLoggedIn => _user != null;
  UserProfile? get user => _user;

  /// Returns null on success, error message on failure.
  String? login(String email, String password) {
    if (email.isEmpty || password.isEmpty) return 'Please fill all fields';
    if (!email.contains('@')) return 'Enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';
    // Simulate successful login
    _user = UserProfile(
      name: email.split('@').first,
      email: email,
    );
    return null;
  }

  /// Returns null on success, error message on failure.
  String? signup(String name, String email, String password) {
    if (name.isEmpty || email.isEmpty || password.isEmpty)
      return 'Please fill all fields';
    if (!email.contains('@')) return 'Enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';
    _user = UserProfile(name: name, email: email);
    return null;
  }

  void logout() => _user = null;

  void updateProfile({String? name, String? email, String? phone}) =>
      _user?.update(name: name, email: email, phone: phone);
}
