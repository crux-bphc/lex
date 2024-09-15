import 'package:lex/modules/multipartus/models/lecture_section.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/providers/backend.dart';
import 'package:signals/signals.dart';

class MultipartusService {
  final LexBackend _backend;

  late final FutureSignal<bool> isRegistered;
  late final FutureSignal<Map<String, Subject>> subjects;
  late final FutureSignal<Map<String, Subject>> pinnedSubjects;
  late final FutureSignal<Map<int, ImpartusSession>> _impartusSessionMap;

  MultipartusService(this._backend) {
    pinnedSubjects = computedAsync(
      () async {
        final r = await _backend.client?.get('/impartus/user/subjects');
        if (r?.data! is! List) return {};
        final iter = (r!.data! as List)
            .cast<Map>()
            .map((e) => Subject.fromJson({...e, 'isPinned': true}));

        final subs = {for (final s in iter) s.id: s};
        return subs;
      },
    );

    subjects = computedAsync(
      () async {
        return await pinnedSubjects.future;
        // final r = await _backend.client?.get('/impartus/subject');
      },
      debugLabel: 'pinnedSubjects',
    );

    _impartusSessionMap = computedAsync(() async {
      final r = await _backend.client?.get('/impartus/session');
      if (r?.data is! Map) return {};
      return {
        for (final e in (r?.data as Map).entries)
          int.parse(e.key): (year: e.value[0], sem: e.value[1]),
      };
    });

    isRegistered = computedAsync(
      () async {
        final r = await _backend.client?.get('/impartus/user');
        if (r?.data is! Map) return false;
        return r?.data['registered'] ?? false;
      },
      debugLabel: 'isRegistered',
    );
  }

  FutureSignal<List<LectureSection>> lectureSections(String id) {
    return computedAsync(
      () async {
        final r = await _backend.client?.get('/impartus/subject/$id');
        if (r?.data is! List) return [];
        final f =
            (r?.data! as List).map((e) => LectureSection.fromJson(e)).toList();
        return f;
      },
      debugLabel: 'sections',
    );
  }

  Future<List<ImpartusVideo>> _fetchImpartusVideos({
    required int sessionId,
    required int subjectId,
  }) async {
    final r =
        await _backend.client?.get('/impartus/lecture/$sessionId/$subjectId');
    if (r?.data is! List) return [];
    return (r!.data as List).map((e) => ImpartusVideo.fromJson(e)).toList();
  }

  FutureSignal<List<LectureVideo>> lectures({
    required String departmentUrl,
    required String code,
  }) {
    final s = lectureSections("$departmentUrl/$code");
    return computedAsync(
      () async {
        final sections = await s.future;
        final sessions = await _impartusSessionMap.future;

        final vidsList = await Future.wait(
          sections.map(
            (lec) async {
              final impartusVideos = await _fetchImpartusVideos(
                sessionId: lec.impartusSession,
                subjectId: lec.impartusSubject,
              );

              return impartusVideos
                  .map(
                    (v) => (
                      section: lec,
                      video: v,
                      session: sessions[lec.impartusSession]!,
                    ),
                  )
                  .toList();
            },
          ),
        );

        return vidsList.reduce((a, b) => a + b);
      },
    );
  }

  Future<void> pinSubject(String id) async {
    await _backend.client?.post(
      '/impartus/user/subjects',
      queryParameters: {'id': id},
    );
    pinnedSubjects.refresh();
  }

  Future<void> unpinSubject(String id) async {
    await _backend.client?.delete(
      '/impartus/user/subjects',
      queryParameters: {'id': id},
    );
    pinnedSubjects.refresh();
  }

  Future<void> registerUser(String impartusPassword) async {
    isRegistered.setLoading();
    await _backend.client?.post(
      '/impartus/user',
      data: {
        "password": impartusPassword,
      },
    );
    await isRegistered.refresh();
  }
}

typedef LectureVideo = ({
  LectureSection section,
  ImpartusVideo video,
  ImpartusSession session,
});

typedef ImpartusSession = ({int year, int sem});
