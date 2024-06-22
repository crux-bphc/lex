import 'package:lex/providers/auth/auth_user.dart';
import 'package:signals/signals.dart';

abstract class AuthProvider {
  ReadonlySignal<AuthUser?> get currentUser;
  ReadonlySignal<bool> get isAuthed;

  Future<void> initialise();

  Future<void> login();

  Future<void> logout();

  void dispose();
}
