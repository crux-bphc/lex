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

  late final FutureSignal<Map<SubjectId, Subject>> pinnedSubjects;
  late final FutureSignal<Map<int, ImpartusSession>> _impartusSessionMap;

  final _subjectMap = <SubjectId, Subject>{};

  MultipartusService(this._backend) {
    pinnedSubjects = computedAsync(
      () async {
        final r = await _backend.get('/impartus/user/subjects');

        requireDataType<List>(
          r,
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

        requireDataType<Map>(
          r,
          "Impartus session data is not in the expected format",
        );

        return {
          for (final e in (r.data as Map).entries)
            int.parse(e.key):
                ImpartusSession(year: e.value[0], sem: e.value[1]),
        };
      },
      debugLabel: 'service | impartusSessionMap',
    );
  }

  Future<MultipartusRegistrationState> fetchRegistrationState() async {
    final r = await _backend.get('/impartus/user');

    requireDataType<Map>(
      r,
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

  Future<bool> registerUser(String impartusPassword) async {
    final r = await _backend.post(
      '/impartus/user',
      data: {
        "password": impartusPassword,
      },
    );

    return r.statusCode == 200;
  }

  late final lectureSections = AsyncCached((SubjectId id) async {
    final department = id.department.replaceAll('/', ',');
    final r =
        await _backend.get('/impartus/subject/$department/${id.code}/lectures');

    requireDataType<List>(r, "Lecture data is not in the expected format");

    final lectures = r.data as List;
    final sessions = await _impartusSessionMap.future;

    final f = lectures
        .map((e) => ImpartusSection.fromJson(e))
        .map(
          (e) => SectionSession(
            section: e,
            session: sessions[e.impartusSession] ?? ImpartusSession.unknown,
          ),
        )
        .toList();

    return f;
  });

  Future<List<ImpartusVideo>> fetchImpartusVideos({
    required int sessionId,
    required int subjectId,
  }) async {
    final r = await _backend.get('/impartus/lecture/$sessionId/$subjectId');

    requireDataType<List>(
      r,
      "Lecture video data is not in the expected format",
    );

    return (r.data as List).map((e) => ImpartusVideo.fromJson(e)).toList();
  }

  late final fetchLectures = AsyncCached((ImpartusSection section) async {
    final vids = await fetchImpartusVideos(
      sessionId: section.impartusSession,
      subjectId: section.impartusSubject,
    );
    final sessions = await _impartusSessionMap.future;

    final result = vids
        .map(
          (e) => LectureVideo.fromData(
            section: section,
            video: e,
            session:
                sessions[section.impartusSession] ?? ImpartusSession.unknown,
          ),
        )
        .toList();

    return result;
  });

  Future<void> pinSubject(String department, String code) async {
    await _backend.post(
      '/impartus/user/subjects',
      data: {'department': department, 'code': code},
    );

    await pinnedSubjects.refresh();
  }

  Future<void> unpinSubject(String department, String code) async {
    await _backend.delete(
      '/impartus/user/subjects',
      data: {'department': department, 'code': code},
    );

    await pinnedSubjects.refresh();
  }

  late final fetchImpartusVideo = AsyncCached((String ttid) async {
    final videoData = await _getVideoInfo(ttid);
    if (videoData != null) {
      return videoData;
    }

    throw BackendError("No video found with ttid $ttid");
  });

  late final fetchSubject = AsyncCached((SubjectId id) async {
    final r =
        await _backend.get('/impartus/subject/${id.departmentUrl}/${id.code}');

    requireDataType<Map>(r, "Subject data is not in the expected format");

    final s = Subject.fromJson(r.data);

    return s;
  });

  Future<List<Subject>> searchSubjects(String search) async {
    final r = await _backend.get(
      "/impartus/subject/search",
      queryParameters: {"q": search},
    );

    if (r.data is! List) return [];

    final subs =
        _pinnifySubjects((r.data as List).map((e) => Subject.fromJson(e)))
            .toList();

    _subjectMap.addAll(_subjectsToIdMap(subs));

    return subs;
  }

  Future<ImpartusVideo?> _getVideoInfo(String ttid) async {
    final r = await _backend.get('/impartus/ttid/$ttid/info');

    if (r.data is! Map) return null;

    return ImpartusVideo.fromJson(r.data);
  }

  Iterable<Subject> _pinnifySubjects(Iterable<Subject> subs) => subs.map((s) {
        return s.copyWith(
          isPinned: untracked(
                () => pinnedSubjects.value.value,
              )?.containsKey(s.subjectId) ??
              false,
        );
      });

  Future<List<LectureSlide>> slidesBro(String ttid) async {
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
}

class LectureVideo {
  final String professor;
  final String title;
  final int lectureNo;
  final DateTime createdAt;
  final String ttid;
  final String videoId;

  final ImpartusSession? session;
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

class ImpartusSession {
  final int? year;
  final int? sem;

  ImpartusSession({required this.year, required this.sem});

  static final unknown = ImpartusSession(year: null, sem: null);

  bool get isUnknown => year == null || sem == null;
}

typedef LecturesResult = ({
  List<LectureVideo> videos,
});

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
  final Response? response;
  final String message;

  BackendError(this.message, [this.response]);

  @override
  String toString() => 'BackendError: $message';
}

void requireDataType<T>(Response r, String message) {
  if (r.data is! T) {
    throw BackendError(
      message,
      r,
    );
  }
}

List<T> requireListType<T>(Response r, String message) {
  final data = r.data;
  if (data is! List) {
    throw BackendError(message, r);
  }
  try {
    return data.cast<T>();
  } on TypeError {
    throw BackendError(message, r);
  }
}

class SectionSession {
  final ImpartusSession session;
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
