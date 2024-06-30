import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/auth/auth_user.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';
import 'package:signals/signals.dart';

const _clientId = "lex";

const _cruxIssuerUrl = "https://auth.crux-bphc.com/realms/CRUx";

const _platformSpecificOptions = OidcPlatformSpecificOptions(
  web: OidcPlatformSpecificOptions_Web(
    navigationMode: OidcPlatformSpecificOptions_Web_NavigationMode.newPage,
  ),
);

class KeycloakAuthProvider extends AuthProvider {
  final OidcUserManager _authManager;
  final _currentUser = signal<AuthUser?>(null);

  final List<Function> _cleanups = [];

  @override
  late final currentUser = _currentUser.readonly();

  KeycloakAuthProvider()
      : _authManager = OidcUserManager.lazy(
          discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
            Uri.parse(_cruxIssuerUrl),
          ),
          clientCredentials:
              const OidcClientAuthentication.none(clientId: _clientId),
          store: OidcDefaultStore(),
          settings: OidcUserManagerSettings(
            redirectUri: Uri.parse(_getRedirectUri()),
            scope: ['openid', 'profile', 'email'],
            strictJwtVerification: true,
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

    // if this, for some reason, is null we can't logout
    assert(_authManager.discoveryDocument.endSessionEndpoint != null);
  }

  @override
  Future<void> login() async {
    await _authManager.loginAuthorizationCodeFlow();
  }

  @override
  Future<void> logout() async {
    final success = await _postEndSessionRequest();
    if (success) {
      await _authManager.forgetUser();
    }
  }

  /// Log out without needing a new browser tab
  Future<bool> _postEndSessionRequest() async {
    final user = _currentUser.value;
    if (user == null) {
      return false;
    }
    final dio = user.bearerClient;

    // The default logout method that the Oidc auth manager
    // uses opens a new browser tab.

    final response = await dio.postUri(
      _authManager.discoveryDocument.endSessionEndpoint!,
      options: Options(contentType: "application/x-www-form-urlencoded"),
      data: {
        "client_id": _clientId,
        "refresh_token": user.refreshToken!,
      },
    );

    if (response.statusCode == null) return false;

    return 200 <= response.statusCode! && response.statusCode! < 300;
  }

  @override
  void dispose() {
    for (final fn in _cleanups) {
      fn();
    }
    _authManager.dispose();
  }
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
