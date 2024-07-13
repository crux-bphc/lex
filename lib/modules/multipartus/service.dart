import 'package:lex/modules/multipartus/models/lecture_section.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/utils/signals.dart';
import 'package:signals/signals.dart';

class MultipartusService {
  final LexBackend _backend;

  MultipartusService(this._backend) {
    subjects = computedAsync(
      () async {
        final r = await _backend.client?.get('/impartus/user/subjects');
        if (r?.data is! List) return {};

        final iter = (r!.data! as List).map((e) => Subject.fromJson(e));

        return {for (final s in iter) s.id: s};
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

    lectureSections = asyncSignalContainer<List<LectureSection>, SubjectId>(
      (id) {
        return computedAsync(() async {
          final r = await _backend.client
              ?.get('/impartus/subject/${id.department}/${id.code}');
          if (r?.data is! List) return [];
          return (r?.data! as List)
              .map((e) => LectureSection.fromJson(e))
              .toList();
        });
      },
      cache: true,
    );
  }

  late final FutureSignal<bool> isRegistered;
  late final FutureSignal<Map<SubjectId, Subject>> subjects;
  late final AsyncContainer<List<LectureSection>, SubjectId> lectureSections;

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

typedef AsyncContainer<T, E> = AsyncSignalContainer<T, E, FutureSignal<T>>;
