import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/error.dart';
import 'package:lex/utils/cached.dart';
import 'package:signals/signals.dart';

const _baseUrl = String.fromEnvironment("LEX_BACKEND_URL");

class LexBackend {
  final AuthProvider _authProvider;

  LexBackend(this._authProvider);

  // only updates subscribers when uid changes
  late final _dummy = computed<String?>(
    () => _authProvider.currentUser()?.uid,
    debugLabel: 'backend | dummy',
  );

  /// This signal is slightly special because it may or may not trigger updates
  /// in its subscribers.
  ///
  /// When the current user changes, usually one of two things happen:
  /// the access token changed (because it refreshed) or the
  /// user signed in/out. In the former case we want subsequent calls to
  /// `_clientSignal` to return a new Dio client with the new access token;
  /// but this should be done _without triggering updates in the subscribers_.
  /// In the latter case, _we do want_ subscribers to be updated because the
  /// entire app must show new data based on the new user.
  ///
  /// To accommodate both these requirements, we use a dummy signal that
  /// changes its value whenever the current user changes (user signed in/out)
  /// and we return a function that will always have the Dio client with
  /// the latest access token.
  late final _clientSignal = computed(
    () {
      _dummy();

      return () => clientCreator(
            untracked(() => _authProvider.currentUser.value?.accessToken),
          );
    },
    debugLabel: 'backend | client',
  );

  /// The Dio client to use for making requests to the backend.
  /// Has the Authorization header set to the current user's access token
  /// and base URL set to the backend's base URL.
  ///
  /// Returns null if there's no current user.
  Dio? get dioClient => _clientSignal()();

  Future<Response?>? get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
  }) async {
    try {
      return await dioClient?.get(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      _handleDioException(e);
      return null;
    }
  }

  Future<Response?>? post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
  }) async {
    try {
      return await dioClient?.post(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      _handleDioException(e);
      return null;
    }
  }

  Future<Response?>? delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
  }) async {
    try {
      return await dioClient?.delete(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      _handleDioException(e);
      return null;
    }
  }

  /// customHandler should return true if the exception was handled
  void _handleDioException(
    DioException exception, {
    bool Function(DioException e)? customHandler,
  }) {
    if (customHandler?.call(exception) ?? false) return;
    final service = GetIt.instance<ErrorService>();
    switch (exception.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        service.reportError("There was a problem connecting to our servers");
        break;

      case DioExceptionType.badResponse:
        service.reportError("There was a problem with the request");
        break;

      default:
        service.reportError(
          "Something wrong occurred on our end. Please try again later",
        );
    }
  }

  void dispose() {
    _clientSignal.dispose();
    _dummy.dispose();
  }
}

final clientCreator = cached((String? accessToken) {
  final client = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      validateStatus: (status) => status != null && status < 400,
    ),
  );
  return accessToken != null ? client : null;
});
