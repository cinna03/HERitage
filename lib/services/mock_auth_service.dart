class MockAuthService {
  static String? _currentUserEmail;
  
  String? get currentUserEmail => _currentUserEmail;
  bool get isAuthenticated => _currentUserEmail != null;

  Future<bool> signInWithEmail(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUserEmail = email;
      return true;
    }
    throw Exception('Invalid credentials');
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUserEmail = email;
      return true;
    }
    throw Exception('Sign up failed');
  }

  Future<bool> signInWithGoogle() async {
    await Future.delayed(Duration(milliseconds: 500));
    _currentUserEmail = 'user@gmail.com';
    return true;
  }

  Future<void> signOut() async {
    await Future.delayed(Duration(milliseconds: 200));
    _currentUserEmail = null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(Duration(milliseconds: 500));
  }
}