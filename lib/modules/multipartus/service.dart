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

  late final FutureSignal<MultipartusRegistrationState> registrationState;
  late final MapSignal<SubjectId, Subject> subjects;
  late final FutureSignal<Map<SubjectId, Subject>> pinnedSubjects;
  late final FutureSignal<Map<int, ImpartusSessionData>> _impartusSessionMap;

  /// ttid: ImpartusVideoData
  late final _videoMap = DeferredValueMap<String, ImpartusVideoData>();

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

    // modified by: pinnedSubjects, searchSubjects, and
    // lectureSections (indirectly by fetchLectureVideo),
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

    registrationState = computedAsync(
      () async {
        final r = await _backend.get('/impartus/user');

        if (r?.data is! Map) return MultipartusRegistrationState.notRegistered;

        if (r?.data["registered"] == false) {
          return MultipartusRegistrationState.notRegistered;
        }

        if (r?.data["valid"] == false) {
          return MultipartusRegistrationState.invalidToken;
        }
        // if for some reason these keys don't exist we shouldn't count that
        // as registered, so I'm strictly checking for their values.
        if (r?.data["valid"] == true && r?.data["registered"] == true) {
          return MultipartusRegistrationState.registered;
        }

        return MultipartusRegistrationState.notRegistered;
      },
      debugLabel: 'service | isRegistered',
    );
  }

  Future<List<ImpartusSectionData>> lectureSections(String id) async {
    final r = await _backend.get('/impartus/subject/$id');
    if (r?.data is! Map) return [];

    final lectures = r!.data['lectures'] ?? [];

    final f =
        (lectures as List).map((e) => ImpartusSectionData.fromJson(e)).toList();

    final subject = r.data['subject'];
    if (subject is Map) {
      final s = Subject.fromJson(subject.cast());
      final id = (code: s.code, department: s.department);
      // add subject to cache if its not already there, we don't get pinned
      // data from this endpoint so if this subject exists as pinned already
      // don't touch it
      if (untracked(() => subjects[id]?.isPinned) != true) {
        subjects[id] = s;
      }
    }

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

            _videoMap.set(v.ttid, v.video);
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
    registrationState.setLoading();
    await _backend.post(
      '/impartus/user',
      data: {
        "password": impartusPassword,
      },
    );
    await registrationState.refresh();
  }

  Future<ImpartusVideoData> fetchLectureVideo({
    required String department,
    required String code,
    required String ttid,
  }) async {
    // first check if we have the video in cache
    final maybe = _videoMap.maybeGet(ttid);
    if (maybe != null) return maybe;

    // if not, fetch from video info
    final videoData = await _getVideoInfo(ttid);
    if (videoData != null) {
      _videoMap.set(ttid, videoData);
      return videoData;
    }

    // this should ideally never run but im leaving this here in case
    // the video info endpoint fails (above)
    return (await _videoMap.get(
      ttid,
      () => lectures((department: department, code: code)).future,
    ));
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

  Future<ImpartusVideoData?> _getVideoInfo(String ttid) async {
    final r = await _backend.get('/impartus/ttid/$ttid/info');

    if (r?.data is! Map) return null;

    return ImpartusVideoData.fromJson(r?.data);
  }
}

class LectureVideo {
  final String professor;
  final String title;
  final int lectureNo;
  final DateTime createdAt;
  final String ttid;
  final String videoId;

  final ImpartusSessionData? session;
  final ImpartusVideoData video;

  LectureVideo.fromData({
    required ImpartusSectionData section,
    required this.video,
    required this.session,
  })  : professor = section.professor,
        title = video.title,
        lectureNo = video.lectureNo,
        createdAt = video.createdAt,
        ttid = video.ttid.toString(),
        videoId = video.videoId.toString();
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

enum MultipartusRegistrationState {
  registered,
  notRegistered,
  invalidToken,
}
