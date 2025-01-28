import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/auth/auth_user.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';
import 'package:signals/signals.dart';

const _baseUrl = String.fromEnvironment("LEX_BACKEND_URL");
const _clientId = String.fromEnvironment("CLIENT_ID");
const _cruxDiscoveryUrl = String.fromEnvironment("AUTH_DISCOVERY_URL");

const _platformSpecificOptions = OidcPlatformSpecificOptions(
  web: OidcPlatformSpecificOptions_Web(
    navigationMode: OidcPlatformSpecificOptions_Web_NavigationMode.newPage,
  ),
);

class OidcAuthProvider extends AuthProvider {
  final OidcUserManager _authManager;
  final _currentUser = signal<AuthUser?>(null);

  final List<Function> _cleanups = [];

  @override
  late final currentUser = _currentUser.readonly();

  @override
  final dioClient = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      validateStatus: (status) => true,
    ),
  );

  OidcAuthProvider()
      : _authManager = OidcUserManager.lazy(
          discoveryDocumentUri: Uri.parse(_cruxDiscoveryUrl),
          clientCredentials:
              const OidcClientAuthentication.none(clientId: _clientId),
          store: OidcDefaultStore(),
          settings: OidcUserManagerSettings(
            redirectUri: Uri.parse(_getRedirectUri()),
            scope: ['openid', 'profile', 'email', 'offline_access'],
            prompt: ['consent'],
            // strictJwtVerification: true,
            options: _platformSpecificOptions,
          ),
        );

  @override
  Future<void> initialise() async {
    final sub = _authManager.userChanges().listen((user) {
      _currentUser.value = user != null ? AuthUser.fromOidcUser(user) : null;
    });
    _cleanups.add(sub.cancel);
    await _authManager.init();

    dioClient.interceptors.add(DioAuthInterceptor(authProvider: this));

    // if this, for some reason, is null we can't logout
    assert(_authManager.discoveryDocument.endSessionEndpoint != null);
  }

  @override
  Future<void> login() async {
    await _authManager.loginAuthorizationCodeFlow();
  }

  @override
  Future<void> logout() async {
    await _authManager.logout();
  }

  @override
  void dispose() {
    for (final fn in _cleanups) {
      fn();
    }
    _authManager.dispose();
  }
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

String _getRedirectUri() {
  if (kIsWeb) {
    return "${Uri.base.origin}/redirect.html";
  }

  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    return "com.thecomputerm.lex:/oauth2redirect";
  }

  if (Platform.isWindows || Platform.isLinux) {
    return "http://localhost:0";
  }

  return "";
}
