import 'package:signals/signals.dart';

abstract class AuthProvider {
  ReadonlySignal get currentUser;
  ReadonlySignal<bool> get isAuthed;

  Future<void> initialise();

  Future<void> login();

  Future<void> logout();

  void dispose();
}
