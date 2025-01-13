import 'dart:async';

class ErrorService {
  Stream<String> get errorStream => _errorStreamController.stream;

  final _errorStreamController = StreamController<String>.broadcast();

  void reportError(String message) {
    _errorStreamController.add(message);
  }
}
