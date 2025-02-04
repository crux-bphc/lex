import 'package:dio/dio.dart';
import 'package:lex/providers/auth/auth_user.dart';
import 'package:signals/signals.dart';

abstract class AuthProvider {
  ReadonlySignal<AuthUser?> get currentUser;

  Dio get dioClient;

  /// Whether the current user is logged in.
  late final isLoggedIn = computed(() => currentUser() != null);

  /// To be called before the app is in a usable state
  Future<void> initialise();

  Future<void> login();

  Future<void> logout();

  void dispose();
}
