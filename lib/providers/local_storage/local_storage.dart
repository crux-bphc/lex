import 'package:lex/providers/local_storage/preferences.dart';
import 'package:lex/providers/local_storage/watch_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Access the app's local storage.
class LocalStorage {
  late final SharedPreferences _sharedPreferences;

  late final Preferences preferences;
  late final WatchHistory watchHistory;

  Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    preferences = Preferences(_sharedPreferences)..initialize();

    watchHistory = WatchHistory(_sharedPreferences)..initialize();
  }

  void dispose() {
    preferences.dispose();
  }
}
