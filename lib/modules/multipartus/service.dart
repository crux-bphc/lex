import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:lex/modules/multipartus/models/impartus_section.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:lex/modules/multipartus/models/lecture_slide.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/utils/misc.dart';
import 'package:signals/signals.dart';

class MultipartusService {
  final Dio _backend;

  /// A map of all pinned subjects. It is refreshed when
  /// the user pins or unpins a subject.
  late final FutureSignal<Map<SubjectId, Subject>> pinnedSubjects;

  /// A map of all impartus sessions.
  late final FutureSignal<Map<int, ImpartusTimeSession>> _impartusSessionMap;

  /// A sort of cache for all the subjects that have been fetched so far.
  final _subjectMap = <SubjectId, Subject>{};

  MultipartusService(this._backend) {
    pinnedSubjects = computedAsync(
      () async {
        final r = await _backend.get('/impartus/user/subjects');

        backendAssertType<List>(
          r.data,
          "Your pinned subjects could not be retrieved"
          " in a format we understand",
        );

        // all these subjects are pinned
        final iter = (r.data as List)
            .map((e) => Subject.fromJson({...e, 'isPinned': true}));

        final subs = _subjectsToIdMap(iter);

        _subjectMap.addAll(subs);
        return subs;
      },
      debugLabel: 'service | pinnedSubjects',
    );

    _impartusSessionMap = computedAsync(
      () async {
        final r = await _backend.get('/impartus/session');

        backendAssertType<Map>(
          r.data,
          "Impartus session data is not in the expected format",
        );

        return {
          for (final e in (r.data as Map).entries)
            int.parse(e.key):
                ImpartusTimeSession(year: e.value[0], sem: e.value[1]),
        };
      },
      debugLabel: 'service | impartusSessionMap',
    );
  }

  Future<MultipartusRegistrationState> fetchRegistrationState() async {
    final r = await _backend.get('/impartus/user');

    backendAssertType<Map>(
      r.data,
      "Multipartus registration data is not in the expected format",
    );

    final registered = r.data['registered'] ?? false;
    final valid = r.data['valid'] ?? false;

    if (registered && valid) {
      return MultipartusRegistrationState.registered;
    } else if (registered && !valid) {
      return MultipartusRegistrationState.invalidToken;
    }

    return MultipartusRegistrationState.notRegistered;
  }

  Future<(bool, String)> registerUser(String impartusPassword) async {
    final r = await _backend.post(
      '/impartus/user',
      data: {
        "password": impartusPassword,
      },
    );

    return (r.statusCode == 200, r.data.toString());
  }

  late final lectureSections = AsyncCached((SubjectId id) async {
    final department = id.department.replaceAll('/', ',');
    final r =
        await _backend.get('/impartus/subject/$department/${id.code}/lectures');

    backendAssertType<List>(
      r.data,
      "Lecture section data is not in the expected format",
    );

    final lectures = r.data as List;
    final sessions = await _impartusSessionMap.future;

    final f = lectures
        .map((e) => ImpartusSection.fromJson(e))
        .map(
          (e) => SectionSession(
            section: e,
            session: sessions[e.impartusSession] ?? ImpartusTimeSession.unknown,
          ),
        )
        .toList();

    return f;
  });

  late final fetchImpartusVideos = AsyncCached((
    ({
      int sessionId,
      int subjectId,
    }) e,
  ) async {
    final sessionId = e.sessionId;
    final subjectId = e.subjectId;

    final r = await _backend.get('/impartus/lecture/$sessionId/$subjectId');

    backendAssertType<List>(
      r.data,
      "Lecture video data is not in the expected format",
    );

    return (r.data as List).map((e) => ImpartusVideo.fromJson(e)).toList();
  });

  late final fetchImpartusVideo = AsyncCached((String ttid) async {
    final videoData = await _getVideoInfo(ttid);
    if (videoData != null) {
      return videoData;
    }

    throw BackendError("No video found with ttid $ttid");
  });

  late final fetchLectureVideos = AsyncCached((ImpartusSection section) async {
    final vids = await fetchImpartusVideos(
      (
        sessionId: section.impartusSession,
        subjectId: section.impartusSubject,
      ),
    );

    final sessions = await _impartusSessionMap.future;

    final result = vids
        .map(
          (e) => LectureVideo.fromData(
            section: section,
            video: e,
            session: sessions[section.impartusSession] ??
                ImpartusTimeSession.unknown,
          ),
        )
        .toList();

    return result;
  });

  /// Get the [previous, current, next] video for a given video ttid.
  /// current video is guaranteed to be non-null.
  Future<AdjacentVideos> getAdjacentVideos({
    required String ttid,
    int count = 1,
  }) async {
    final vid = await fetchImpartusVideo(ttid);
    final vids = await fetchImpartusVideos(
      (
        sessionId: vid.sessionId,
        subjectId: vid.impartusSubjectId,
      ),
    );

    final index = vids.indexWhere((e) => e.ttid.toString() == ttid);

    final start = (index - count).clamp(0, index);
    final end = (index + count + 1).clamp(index, vids.length);

    // lectures are sorted in descending order of lecture number.
    final nextVids = vids.sublist(start, index);
    final prevVids = vids.sublist(index + 1, end);

    return (
      previous: prevVids,
      next: nextVids,
      current: vid,
    );
  }

  Future<Subject> fetchSubject(SubjectId id) async {
    // retrieve from cache
    final maybe = _subjectMap[id];
    if (maybe != null) return maybe;

    final r = await _backend.get('/impartus/subject/${id.asUrl}');

    backendAssertType<Map>(
      r.data,
      "Subject data is not in the expected format",
    );

    final s = Subject.fromJson(r.data);

    return s;
  }

  Future<ImpartusVideo?> _getVideoInfo(String ttid) async {
    final r = await _backend.get('/impartus/ttid/$ttid/info');

    if (r.data is! Map) return null;

    return ImpartusVideo.fromJson(r.data);
  }

  Future<void> pinSubject(String department, String code) async {
    final r = await _backend.post(
      '/impartus/user/subjects',
      data: {'department': department, 'code': code},
    );

    if (r.statusCode == 200) {
      await pinnedSubjects.refresh();
    }
  }

  Future<void> unpinSubject(String department, String code) async {
    final r = await _backend.delete(
      '/impartus/user/subjects',
      data: {'department': department, 'code': code},
    );

    if (r.statusCode == 200) {
      await pinnedSubjects.refresh();
    }
  }

  Future<List<Subject>> searchSubjects(String search) async {
    final r = await _backend.get(
      "/impartus/subject/search",
      queryParameters: {"q": search},
    );

    backendAssertType<List>(
      r.data,
      "Search results are not in the expected format",
    );

    final subs =
        _pinnifySubjects((r.data as List).map((e) => Subject.fromJson(e)))
            .toList();

    _subjectMap.addAll(_subjectsToIdMap(subs));

    return subs;
  }

  /// Given an iterable of Subjects, this function will return an iterable with
  /// the pinned subjects marked as pinned in each Subject object.
  ///
  /// This is useful when you need to find out if subjects that are returned
  /// from, for example, the search endpoint are pinned because the backend
  /// does not give us that information.
  Iterable<Subject> _pinnifySubjects(Iterable<Subject> subs) => subs.map((s) {
        return s.copyWith(
          isPinned: untracked(
                () => pinnedSubjects.value.value,
              )?.containsKey(s.subjectId) ??
              false,
        );
      });

  Future<List<LectureSlide>> fetchSlides(String ttid) async {
    final r = await _backend.get('/impartus/ttid/$ttid/slides');
    if (r.data is! List) return [];

    return (r.data as List).map((e) => LectureSlide.fromJson(e)).toList();
  }

  Future<bool> downloadSlides(String ttid) async {
    final r = await _backend.get<Uint8List>(
      '/impartus/ttid/$ttid/slides/download',
      options: Options(responseType: ResponseType.bytes),
    );
    await FileSaver.instance.saveFile(
      name: "slides.pdf",
      bytes: r.data,
    );

    return true;
  }

  Future<bool> isImpartusDown(String ttid) async {
    final result = await _backend.get('/impartus/ttid/$ttid/m3u8');

    if (result is! Map<String, dynamic>) return true;

    return (result as Map<String, dynamic>)["cause"] == "impartus";
  }
}

class LectureVideo {
  final String professor;
  final String title;
  final int lectureNo;
  final DateTime createdAt;
  final String ttid;
  final String videoId;

  final ImpartusTimeSession? session;
  final ImpartusSection section;
  final ImpartusVideo video;

  LectureVideo.fromData({
    required this.section,
    required this.video,
    required this.session,
  })  : professor = section.professor,
        title = video.title,
        lectureNo = video.lectureNo,
        createdAt = video.createdAt,
        ttid = video.ttid.toString(),
        videoId = video.videoId.toString();
}

class ImpartusTimeSession {
  final int? year;
  final int? sem;

  ImpartusTimeSession({required this.year, required this.sem});

  /// A session with no year or semester is considered unknown.
  /// This type of session will show up when a session id that the backend does
  /// not know of has to be displayed to the user.
  static final unknown = ImpartusTimeSession(year: null, sem: null);

  bool get isUnknown => year == null || sem == null;
}

/// Convert a list of subjects to a map of subjectId to subject
Map<SubjectId, Subject> _subjectsToIdMap(Iterable<Subject> subjects) =>
    <SubjectId, Subject>{
      for (final s in subjects)
        SubjectId(department: s.department, code: s.code): s,
    };

enum MultipartusRegistrationState {
  registered,
  notRegistered,
  invalidToken,
}

class BackendError extends Error {
  final Object? object;
  final String message;

  BackendError(this.message, [this.object]);

  @override
  String toString() {
    if (object is Map<String, dynamic>) {
      final map = object as Map<String, dynamic>;
      return 'BackendError: ${map['message']}';
    }
    return 'BackendError: $message';
  }
}

void backendAssertType<T>(Object obj, String message) {
  if (obj is! T) {
    throw BackendError(message, obj);
  }
}

class SectionSession {
  final ImpartusTimeSession session;
  final ImpartusSection section;

  SectionSession({
    required this.section,
    required this.session,
  })  : professor = section.professor,
        lectureSection = section.section,
        year = session.year,
        sem = session.sem,
        isUnknown = session.isUnknown;

  final String professor, lectureSection;
  final int? year, sem;
  final bool isUnknown;
}

typedef AdjacentVideos = ({
  ImpartusVideo current,
  List<ImpartusVideo> previous,
  List<ImpartusVideo> next,
});
