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

class DioAuthInterceptor extends Interceptor {
  final AuthProvider _authProvider;

  DioAuthInterceptor({required AuthProvider authProvider})
      : _authProvider = authProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _appendAuthHeader(_authProvider, options.headers);
    handler.next(options);
  }
}

void _appendAuthHeader(AuthProvider provider, Map<String, dynamic> headers) {
  // If the Authorization header is already set, don't override it
  if (headers.containsKey('Authorization')) return;

  // If there's no idToken, don't set the Authorization header
  final idToken = provider.currentUser.value?.idToken;
  if (idToken == null) return;

  headers['Authorization'] = 'Bearer $idToken';
}
