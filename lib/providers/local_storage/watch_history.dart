import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchHistory {
  final _history = <int, WatchHistoryItem>{};

  final SharedPreferences _prefs;

  WatchHistory(this._prefs);

  void initialize() {
    _load();
  }

  void _load() {
    final content = _prefs.getString('watch_history');
    if (content == null) return;

    final map = jsonDecode(content);
    if (map is! Map) return;

    _history.clear();
    _history.addAll(
      map.map(
        (key, value) => MapEntry(
          int.parse(key),
          WatchHistoryItem(value['t'] ?? 0, value['d'] ?? 0, value['f'] ?? 0),
        ),
      ),
    );
  }

  void _save() {
    final map = _history.map(
      (key, value) => MapEntry(
        key.toString(),
        {
          't': value.timestamp,
          'd': value.duration,
          'f': value.fraction,
        },
      ),
    );

    _prefs.setString('watch_history', jsonEncode(map));
  }

  void update(int videoId, int duration, double fraction,
      {DateTime? timestamp}) {
    timestamp ??= DateTime.now();
    _history[videoId] =
        WatchHistoryItem.fromDateTime(timestamp, duration, fraction);
    _save();
  }

  WatchHistoryItem? read(int videoId) {
    return _history[videoId];
  }
}

class WatchHistoryItem {
  final int timestamp;
  final int duration;
  final double fraction;

  WatchHistoryItem(this.timestamp, this.duration, this.fraction);
  WatchHistoryItem.fromDateTime(
    DateTime timestamp,
    this.duration,
    this.fraction,
  ) : timestamp = timestamp.millisecondsSinceEpoch ~/ 1000;
}
