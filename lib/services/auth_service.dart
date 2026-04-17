import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtpoll/providers/repository_providers.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  Future<User?> ensureSignedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return currentUser;

    final credentials = await _auth.signInAnonymously();
    return credentials.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}

final authServiceProvider = Provider<AuthService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthService(auth);
});
