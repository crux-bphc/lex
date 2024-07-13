import 'package:signals/signals.dart';

class AsyncSignalContainer<T, Arg, S extends FutureSignal<T>> {
  /// If true then signals will be cached when created
  final bool cache;

  /// Store of created signals (if cache is true)
  final store = mapSignal<Arg, S>({});

  final S Function(Arg) _create;

  /// Signal container used to create multiple signals via args
  AsyncSignalContainer(
    this._create, {
    this.cache = false,
  });

  /// Create the signal with the given args
  S call(Arg arg) {
    if (cache) {
      return store.putIfAbsent(arg, () {
        return _create(arg)..onDispose(() => store.remove(arg));
      });
    } else {
      return _create(arg);
    }
  }

  /// Remove a signal from the cache
  S? remove(Arg arg) => store.remove(arg);

  /// Check if signal is currently stored in the cache
  bool containsKey(Arg arg) => store.containsKey(arg);

  /// Clear the cache
  void clear() => store.clear();

  /// Dispose of all created signals
  void dispose() {
    for (final signal in store.values.toList()) {
      signal.dispose();
    }
    store.dispose();
  }
}

AsyncSignalContainer<T, Arg, FutureSignal<T>> asyncSignalContainer<T, Arg>(
  FutureSignal<T> Function(Arg) create, {
  bool cache = false,
}) {
  return AsyncSignalContainer(create, cache: cache);
}
