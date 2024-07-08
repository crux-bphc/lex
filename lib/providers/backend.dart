import 'package:dio/dio.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:signals/signals.dart';

const _baseUrl = 'http://localhost:3000/';

class LexBackend {
  final AuthProvider _authProvider;

  LexBackend(this._authProvider);

  late final _clientSignal = computed(
    () {
      final accessToken = _authProvider.currentUser.value?.accessToken;
      return accessToken != null
          ? Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                headers: {
                  'Authorization': 'Bearer $accessToken',
                },
                validateStatus: (status) => true,
              ),
            )
          : null;
    },
  );

  /// The Dio client to use for making requests to the backend.
  /// Has the Authorization header set to the current user's access token
  /// and base URL set to the backend's base URL.
  ///
  /// Returns null if there's no current user.
  Dio? get client => _clientSignal();
}
