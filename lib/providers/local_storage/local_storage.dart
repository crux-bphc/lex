import 'package:lex/providers/local_storage/preferences.dart';
import 'package:lex/providers/local_storage/watch_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  late final SharedPreferences _sharedPreferences;

  late final Preferences preferences;
  late final WatchHistory watchHistory;

  Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    preferences = Preferences(_sharedPreferences);
    preferences.initialize();

    watchHistory = WatchHistory(_sharedPreferences);
    watchHistory.initialize();
  }

  void dispose() {
    preferences.dispose();
  }
}
