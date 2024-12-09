import 'package:dio/dio.dart';
import 'package:oidc/oidc.dart';

class AuthUser {
  final OidcUser _oidcUser;

  final Dio _client;
  Dio get bearerClient => _client;

  String? get refreshToken => _oidcUser.token.refreshToken;
  String? get accessToken => _oidcUser.token.accessToken;
  String? get uid => _oidcUser.uid;

  AuthUser.fromOidcUser(OidcUser user)
      : _oidcUser = user,
        _client = Dio(
          BaseOptions(
            headers: {
              "Authorization": "Bearer ${user.token.accessToken}",
            },
          ),
        );
}
