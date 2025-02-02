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

    batch(() {
      _history.clear();

      bool isOld = false;

      _history.addAll(
        map.map(
          (key, value) {
            if (value['v'] != null) isOld = true;
            return MapEntry(
              int.parse(key),
              WatchHistoryItem(
                value['t'] ?? 0,
                value['p'] ?? 0,
                value['f'] ?? 0,
                value['d'] ?? '',
                value['c'] ?? '',
              ),
            );
          },
        ),
      );

      if (isOld) {
        _history.clear();
        untracked(() {
          _save();
        });
      }
    });
  }

  void _save() {
    final sortedEntries = _history.entries.toList()
      ..sort((a, b) => -a.value.timestamp.compareTo(b.value.timestamp));

    // Keep only the first 30 items
    if (sortedEntries.length > 30) {
      _history.clear();
      _history.addAll(
        Map.fromEntries(sortedEntries.take(30)),
      );
    }

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
    required int position,
    required double fraction,
    required String departmentUrl,
    required String code,
    required String ttid,
    DateTime? timestamp,
  }) {
    timestamp ??= DateTime.now();
    _history[int.parse(ttid)] = WatchHistoryItem.fromDateTime(
      timestamp,
      position,
      fraction,
      departmentUrl,
      code,
    );
    _save();
  }

  WatchHistoryItem? getByTtid(String ttid) {
    return _history[int.parse(ttid)];
  }

  /// Returns the most recent watch history item for a given subject
  /// (ttid, WatchHistoryItem)
  (String, WatchHistoryItem)? getMostRecentBySubject({
    required String departmentUrl,
    required String code,
  }) {
    final found = _history.entries
        .where(
          (e) => e.value.departmentUrl == departmentUrl && e.value.code == code,
        )
        .fold<MapEntry<int, WatchHistoryItem>?>(
          null,
          (a, b) =>
              a == null ? b : (a.value.timestamp > b.value.timestamp ? a : b),
        );

    if (found == null) return null;
    return (found.key.toString(), found.value);
  }

  /// Subscribes to the history map signal
  /// and returns `List<(ttid, WatchHistoryItem)>`
  List<(String, WatchHistoryItem)> readAll() {
    return _history()
        .entries
        .map((e) => (e.key.toString(), e.value))
        // remove videos that are fully watched
        .where((e) => e.$2.fraction < 0.94)
        .toList()
      ..sort(
        // sort by most recent
        (a, b) => -a.$2.timestamp.compareTo(b.$2.timestamp),
      );
  }

  /// Clears the entire watch history
  void clear() {
    _history.clear();
    _save();
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
