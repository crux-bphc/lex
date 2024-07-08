import 'package:lex/providers/backend.dart';
import 'package:signals/signals.dart';

class MultipartusService {
  final LexBackend _backend;

  MultipartusService(this._backend) {
    subjects = futureSignal(() async {
      final r = await _backend.client?.get('/impartus/user/subjects');
      final data = r?.data;
      return data is List ? data.map((e) => e["name"] as String).toList() : [];
    });

    isRegistered = futureSignal(
      () async {
        // TODO: change this to the actual userinfo endpoint
        // for testing only.
        await subjects.future;
        return subjects().value?.isNotEmpty ?? false;
      },
    );
  }

  late final FutureSignal<bool> isRegistered;
  late final FutureSignal<List<String>> subjects;

  Future<void> registerUser(String impartusPassword) async {
    await _backend.client?.post(
      '/impartus/user',
      data: {
        "password": impartusPassword,
      },
    );
    await subjects.refresh();
  }
}
