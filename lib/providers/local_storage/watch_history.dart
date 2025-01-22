import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

const _key = 'watch_history';

class WatchHistory {
  final _history = <int, WatchHistoryItem>{}.toSignal();

  final SharedPreferences _prefs;

  WatchHistory(this._prefs);

  void initialize() {
    _load();
  }

  void _load() {
    final content = _prefs.getString(_key);
    if (content == null) return;

    final map = jsonDecode(content);
    if (map is! Map) return;

    _history.clear();
    _history.addAll(
      map.map(
        (key, value) => MapEntry(
          int.parse(key),
          WatchHistoryItem(
            value['t'] ?? 0,
            value['p'] ?? 0,
            value['f'] ?? 0,
            value['d'] ?? '',
            value['c'] ?? '',
          ),
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
          'p': value.position,
          // reduce precision to 2 decimal digits (eg 0.25)
          'f': double.parse(value.fraction.toStringAsFixed(2)),
          'd': value.departmentUrl,
          'c': value.code,
        },
      ),
    );

    _prefs.setString(_key, jsonEncode(map));
  }

  void update({
    required int videoId,
    required int position,
    required double fraction,
    required String departmentUrl,
    required String code,
    DateTime? timestamp,
  }) {
    timestamp ??= DateTime.now();
    _history[videoId] = WatchHistoryItem.fromDateTime(
      timestamp,
      position,
      fraction,
      departmentUrl,
      code,
    );
    _save();
  }

  WatchHistoryItem? read(int videoId) {
    return _history[videoId];
  }

  // subscribes to the history map signal
  List<(int, WatchHistoryItem)> readAll() {
    return _history()
        .entries
        .map((e) => (e.key, e.value))
        // remove videos that are fully watched
        .where((e) => e.$2.fraction < 0.94)
        .toList()
      ..sort(
        // sort by most recent
        (a, b) => -a.$2.timestamp.compareTo(b.$2.timestamp),
      );
  }
}

class WatchHistoryItem {
  final int timestamp;
  final int position;
  final double fraction;
  final String departmentUrl, code;

  WatchHistoryItem(
    this.timestamp,
    this.position,
    this.fraction,
    this.departmentUrl,
    this.code,
  );
  WatchHistoryItem.fromDateTime(
    DateTime timestamp,
    this.position,
    this.fraction,
    this.departmentUrl,
    this.code,
  ) : timestamp = timestamp.millisecondsSinceEpoch ~/ 1000;
}
