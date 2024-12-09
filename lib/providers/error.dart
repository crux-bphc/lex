import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class ErrorService {
  Stream<String> get errorStream => _errorStreamController.stream;

  final _errorStreamController = StreamController<String>.broadcast();

  FutureOr<T?> runAndHandleError<T>(
    FutureOr<T?> Function() fn, {
    bool Function(DioException e)? customHandler,
  });

  void reportError(String message) {
    _errorStreamController.add(message);
  }
}

class DioErrorService extends ErrorService {
  @override
  FutureOr<T?> runAndHandleError<T>(
    FutureOr<T?> Function() fn, {
    bool Function(DioException e)? customHandler,
  }) {
    try {
      return fn();
    } on DioException catch (e) {
      if (customHandler?.call(e) ?? false) {
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            debugPrint("there was a problem connecting to our servers");
            break;

          default:
            debugPrint("there was a problem with the request");
        }
      }
    } catch (e) {
      debugPrint("bro $e");
    }

    return null;
  }
}
