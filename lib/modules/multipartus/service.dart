import 'package:lex/modules/multipartus/models/lecture_section.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/utils/signals.dart';
import 'package:signals/signals.dart';

class MultipartusService {
  final LexBackend _backend;

  late final FutureSignal<bool> isRegistered;
  late final FutureSignal<Map<SubjectId, Subject>> pinnedSubjects;
  late final AsyncContainer<List<LectureSection>, SubjectId> lectureSections;

  MultipartusService(this._backend) {
    pinnedSubjects = computedAsync(
      () async {
        final r = await _backend.client?.get('/impartus/user/subjects');
        if (r?.data! is! List) return {};

        final iter = (r!.data! as List)
            .map((e) => Subject.fromJson({...e, 'isPinned': true}));

        return {for (final s in iter) s.id: s};
      },
      debugLabel: 'subjects',
    );

    isRegistered = computedAsync(
      () async {
        // TODO: change this to the actual userinfo endpoint
        // for testing only.
        return (await pinnedSubjects.future).isNotEmpty;
      },
      debugLabel: 'isRegistered',
    );

    lectureSections = asyncSignalContainer<List<LectureSection>, SubjectId>(
      (id) {
        return computedAsync(() async {
          final r = await _backend.client
              ?.get('/impartus/subject/${id.departmentUrl}/${id.code}');
          if (r?.data is! List) return [];
          return (r?.data! as List)
              .map((e) => LectureSection.fromJson(e))
              .toList();
        });
      },
      cache: true,
    );
  }
  Future<void> registerUser(String impartusPassword) async {
    pinnedSubjects.setLoading();
    await _backend.client?.post(
      '/impartus/user',
      data: {
        "password": impartusPassword,
      },
    );
    await pinnedSubjects.refresh();
  }
}

typedef AsyncContainer<T, E> = AsyncSignalContainer<T, E, FutureSignal<T>>;
