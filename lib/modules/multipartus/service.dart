import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/providers/backend.dart';
import 'package:signals/signals.dart';

class MultipartusService {
  final LexBackend _backend;

  MultipartusService(this._backend) {
    subjects = computedAsync(
      () async {
        final r = await _backend.client?.get('/impartus/user/subjects');
        if (r?.data is! List) return [];

        return (r!.data! as List)
            .map((e) => Subject.fromJson(e))
            .toList(growable: false);
      },
      debugLabel: 'subjects',
    );

    isRegistered = computedAsync(
      () async {
        // TODO: change this to the actual userinfo endpoint
        // for testing only.
        return (await subjects.future).isNotEmpty;
      },
      debugLabel: 'isRegistered',
    );
  }

  late final FutureSignal<bool> isRegistered;
  late final FutureSignal<List<Subject>> subjects;

  Future<void> registerUser(String impartusPassword) async {
    subjects.setLoading();
    await _backend.client?.post(
      '/impartus/user',
      data: {
        "password": impartusPassword,
      },
    );
    await subjects.refresh();
  }
}
