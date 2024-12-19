import 'dart:async';

import 'package:lex/modules/multipartus/models/lecture_section.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/utils/signals.dart';
import 'package:signals/signals.dart';

class MultipartusService {
  final LexBackend _backend;

  late final FutureSignal<bool> isRegistered;
  late final FutureSignal<Map<SubjectId, Subject>> subjects;
  late final FutureSignal<Map<SubjectId, Subject>> pinnedSubjects;
  late final FutureSignal<Map<int, ImpartusSessionData>> _impartusSessionMap;

  final Map<int, (LectureVideo?, Completer<LectureVideo>)>
      _lectureVideoCompleters = {};

  MultipartusService(this._backend) {
    pinnedSubjects = computedAsync(
      () async {
        final r = await _backend.get('/impartus/subject');

        if (r?.data! is! List) return {};
        final iter = (r!.data! as List)
            .cast<Map>()
            .map((e) => Subject.fromJson({...e, 'isPinned': false}));

        final subs = <SubjectId, Subject>{
          for (final s in iter) (department: s.departmentUrl, code: s.code): s,
        };
        return subs;
      },
      debugLabel: 'service | pinnedSubjects',
    );

    subjects = computedAsync(
      () async {
        return await pinnedSubjects.future;
      },
      debugLabel: 'service | subjects',
    );

    _impartusSessionMap = computedAsync(
      () async {
        final r = await _backend.get('/impartus/session');
        if (r?.data is! Map) return {};
        return {
          for (final e in (r?.data as Map).entries)
            int.parse(e.key): (year: e.value[0], sem: e.value[1]),
        };
      },
      debugLabel: 'service | impartusSessionMap',
    );

    isRegistered = computedAsync(
      () async {
        final r = await _backend.get('/impartus/user');
        if (r?.data is! Map) return false;
        return r?.data['registered'] ?? false;
      },
      debugLabel: 'service | isRegistered',
    );
  }

  FutureSignal<List<ImpartusSectionData>> lectureSections(String id) {
    return computedAsync(
      () async {
        final r = await _backend.get('/impartus/subject/$id');
        if (r?.data is! List) return [];
        final f = (r?.data! as List)
            .map((e) => ImpartusSectionData.fromJson(e))
            .toList();
        return f;
      },
      debugLabel: 'service | sections',
      autoDispose: true,
    );
  }

  Future<List<ImpartusVideoData>> _fetchImpartusVideos({
    required int sessionId,
    required int subjectId,
  }) async {
    final r = await _backend.get('/impartus/lecture/$sessionId/$subjectId');
    if (r?.data is! List) return [];
    return (r!.data as List).map((e) => ImpartusVideoData.fromJson(e)).toList();
  }

  late final lectures = asyncSignalContainer<LecturesResult,
      ({String departmentUrl, String code})>(
    (e) {
      final departmentUrl = e.departmentUrl;
      final code = e.code;
      final s = lectureSections("$departmentUrl/$code");

      return computedAsync(
        () async {
          final sections = await s.future;
          final sessions = await _impartusSessionMap.future;

          final List<LectureVideo> vidsList = (await Future.wait(
            sections.map((lec) async {
              final impartusVideos = await _fetchImpartusVideos(
                sessionId: lec.impartusSession,
                subjectId: lec.impartusSubject,
              );

              return impartusVideos
                  .map(
                    (v) => LectureVideo.fromData(
                      section: lec,
                      video: v,
                      session: sessions[lec.impartusSession]!,
                    ),
                  )
                  .toList();
            }),
          ))
              .reduce((a, b) => a + b);

          final profMap = <String, Set<ImpartusSessionData>>{};

          for (final v in vidsList) {
            final prof = v.professor;
            profMap.putIfAbsent(prof, () => {}).add(v.session);

            final c = _lectureVideoCompleters
                .putIfAbsent(v.ttid, () => (v, Completer()))
                .$2;
            if (!c.isCompleted) c.complete(v);
          }

          return (
            videos: vidsList,
            professorSessionMap: profMap,
          );
        },
        autoDispose: true,
        debugLabel: 'service | lectures',
      );
    },
    cache: true,
  );

  Future<void> pinSubject(String id) async {
    await _backend.post(
      '/impartus/user/subjects',
      queryParameters: {'id': id},
    );
    pinnedSubjects.refresh();
  }

  Future<void> unpinSubject(String id) async {
    await _backend.delete(
      '/impartus/user/subjects',
      queryParameters: {'id': id},
    );
    pinnedSubjects.refresh();
  }

  Future<void> registerUser(String impartusPassword) async {
    isRegistered.setLoading();
    await _backend.post(
      '/impartus/user',
      data: {
        "password": impartusPassword,
      },
    );
    await isRegistered.refresh();
  }

  Future<LectureVideo> fetchLectureVideo({
    required String departmentUrl,
    required String code,
    required int ttid,
  }) async {
    final c = _lectureVideoCompleters[ttid]?.$1;
    if (c != null) return c;

    _lectureVideoCompleters[ttid] = (null, Completer());
    lectures((departmentUrl: departmentUrl, code: code)).future;

    return _lectureVideoCompleters[ttid]!.$2.future;
  }
}

class LectureVideo {
  final String professor;
  final String title;
  final int lectureNo;
  final DateTime createdAt;
  final int ttid;
  final ImpartusSessionData session;

  LectureVideo.fromData({
    required ImpartusSectionData section,
    required ImpartusVideoData video,
    required this.session,
  })  : professor = section.professor,
        title = video.topic,
        lectureNo = video.lectureNo,
        createdAt = video.createdAt,
        ttid = video.ttid;
}

typedef ImpartusSessionData = ({int year, int sem});

typedef LecturesResult = ({
  List<LectureVideo> videos,
  Map<String, Set<ImpartusSessionData>> professorSessionMap,
});
