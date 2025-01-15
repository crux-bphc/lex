import 'package:lex/providers/local_storage/preferences.dart';

class LocalStorage {
  final preferences = Preferences();

  Future<void> initialize() async {
    preferences.initialize();
  }

  void dispose() {
    preferences.dispose();
  }
}
