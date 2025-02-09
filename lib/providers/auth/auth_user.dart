import 'package:dio/dio.dart';
import 'package:oidc/oidc.dart';

class AuthUser {
  final Dio _client;
  Dio get bearerClient => _client;

  final String? refreshToken;
  final String? idToken;
  final String? uid;

  AuthUser.fromOidcUser(OidcUser user)
      : refreshToken = user.token.refreshToken,
        idToken = user.token.idToken,
        uid = user.uid,
        _client = Dio(
          BaseOptions(
            headers: {
              "Authorization": "Bearer ${user.token.accessToken}",
            },
          ),
        );
}
