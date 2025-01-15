import 'dart:async';

import 'package:lex/modules/multipartus/models/lecture_section.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/utils/misc.dart';
import 'package:lex/utils/signals.dart';
import 'package:signals/signals.dart';

class MultipartusService {
  final LexBackend _backend;

  late final FutureSignal<bool> isRegistered;
  late final MapSignal<SubjectId, Subject> subjects;
  late final FutureSignal<Map<SubjectId, Subject>> pinnedSubjects;
  late final FutureSignal<Map<int, ImpartusSessionData>> _impartusSessionMap;

  late final _lectureMap = DeferredValueMap<int, LectureVideo>();

  MultipartusService(this._backend) {
    pinnedSubjects = computedAsync(
      () async {
        final r = await _backend.get('/impartus/user/subjects');

        if (r?.data! is! List) return {};
        final iter = (r!.data! as List)
            .cast<Map>()
            .map((e) => Subject.fromJson({...e, 'isPinned': true}));

        final subs = _subjectsToIdMap(iter);

        subjects.addAll(subs);
        return subs;
      },
      debugLabel: 'service | pinnedSubjects',
    );

    subjects = <SubjectId, Subject>{}.toSignal(
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
        return (r?.data['registered'] ?? false) && (r?.data['valid'] ?? false);
      },
      debugLabel: 'service | isRegistered',
    );
  }

  Future<List<ImpartusSectionData>> lectureSections(String id) async {
    final r = await _backend.get('/impartus/subject/$id');
    if (r?.data is! List) return [];
    final f =
        (r?.data! as List).map((e) => ImpartusSectionData.fromJson(e)).toList();

    return f;
  }

  Future<List<ImpartusVideoData>> _fetchImpartusVideos({
    required int sessionId,
    required int subjectId,
  }) async {
    final r = await _backend.get('/impartus/lecture/$sessionId/$subjectId');
    if (r?.data is! List) return [];
    return (r!.data as List).map((e) => ImpartusVideoData.fromJson(e)).toList();
  }

  late final lectures =
      asyncSignalContainer<LecturesResult, ({String department, String code})>(
    (e) {
      final departmentUrl = e.department.replaceAll('/', ',');
      final code = e.code;

      return computedAsync(
        () async {
          final sections = await lectureSections("$departmentUrl/$code");

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
                      session: sessions[lec.impartusSession],
                    ),
                  )
                  .toList();
            }),
          ))
              .reduce((a, b) => a + b);

          final profMap = <String, Set<ImpartusSessionData?>>{};

          for (final v in vidsList) {
            final prof = v.professor;
            profMap.putIfAbsent(prof, () => {}).add(v.session);

            _lectureMap.set(v.ttid, v);
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

  Future<void> pinSubject(String department, String code) async {
    await _backend.post(
      '/impartus/user/subjects',
      data: {'department': department, 'code': code},
    );
    pinnedSubjects.refresh();
  }

  Future<void> unpinSubject(String department, String code) async {
    await _backend.delete('/impartus/user/subjects',
        data: {'department': department, 'code': code});
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
    required String department,
    required String code,
    required int ttid,
  }) {
    return _lectureMap.get(
      ttid,
      () => lectures((department: department, code: code)).future,
    );
  }

  Future<List<Subject>> searchSubjects(String search) async {
    final r = await _backend.get(
      "/impartus/subject/search",
      queryParameters: {"q": search},
    );
    if (r?.data is! List) return [];

    final subs = (r!.data as List).map((e) => Subject.fromJson(e)).toList();

    subjects.addAll(_subjectsToIdMap(subs));

    return subs;
  }
}

class LectureVideo {
  final String professor;
  final String title;
  final int lectureNo;
  final DateTime createdAt;
  final int ttid;
  final ImpartusSessionData? session;

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
  Map<String, Set<ImpartusSessionData?>> professorSessionMap,
});

Map<SubjectId, Subject> _subjectsToIdMap(Iterable<Subject> subjects) =>
    <SubjectId, Subject>{
      for (final s in subjects)
        (department: s.departmentUrl.replaceAll(',', '/'), code: s.code): s,
    };
