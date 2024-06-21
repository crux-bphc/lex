import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';
import 'package:signals/signals.dart';

const _cruxIssuerUrl = "https://auth.crux-bphc.com/realms/CRUx";

const _platformSpecificOptions = OidcPlatformSpecificOptions(
  web: OidcPlatformSpecificOptions_Web(
    navigationMode: OidcPlatformSpecificOptions_Web_NavigationMode.newPage,
  ),
);

class KeycloakAuthProvider extends AuthProvider {
  final OidcUserManager _authManager;
  final _currentUser = signal<OidcUser?>(null);

  final List<Function> _cleanups = [];

  @override
  late final currentUser = _currentUser.readonly();

  @override
  late final isAuthed = computed(() => currentUser() != null);

  KeycloakAuthProvider()
      : _authManager = OidcUserManager.lazy(
          discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
            Uri.parse(_cruxIssuerUrl),
          ),
          clientCredentials:
              const OidcClientAuthentication.none(clientId: "lex"),
          store: OidcDefaultStore(),
          settings: OidcUserManagerSettings(
            redirectUri: Uri.parse(_getRedirectUri()),
            postLogoutRedirectUri: Uri.parse(_getPostLogoutUri()),
            scope: ['openid', 'profile', 'email'],
            strictJwtVerification: true,
            options: _platformSpecificOptions,
          ),
        );

  @override
  Future<void> initialise() {
    final sub = _authManager.userChanges().listen((user) {
      _currentUser.value = user;
    });
    _cleanups.add(sub.cancel);
    return _authManager.init();
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

String _getPostLogoutUri() {
  if (kIsWeb) {
    return "${Uri.base.origin}/redirect.html";
  }

  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    return "com.thecomputerm.lex:/logoutredirect";
  }

  if (Platform.isWindows || Platform.isLinux) {
    return "http://localhost:0";
  }

  return "";
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