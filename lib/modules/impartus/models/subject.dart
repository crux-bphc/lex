class ImpartusSubject {
  LastLecture? lastLecture;
  int? subjectId;
  String? subjectName;
  int? sessionId;
  String? sessionName;
  int? professorId;
  String? professorName;
  int? departmentId;
  String? department;
  int? instituteId;
  String? institute;
  String? coverpic;
  int? videoCount;
  int? flippedLecturesCount;
  String? professorImageUrl;

  ImpartusSubject({
    this.lastLecture,
    this.subjectId,
    this.subjectName,
    this.sessionId,
    this.sessionName,
    this.professorId,
    this.professorName,
    this.departmentId,
    this.department,
    this.instituteId,
    this.institute,
    this.coverpic,
    this.videoCount,
    this.flippedLecturesCount,
    this.professorImageUrl,
  });

  ImpartusSubject.fromJson(Map<String, dynamic> json) {
    lastLecture = json['lastLecture'] != null
        ? LastLecture.fromJson(json['lastLecture'])
        : null;
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    sessionId = json['sessionId'];
    sessionName = json['sessionName'];
    professorId = json['professorId'];
    professorName = json['professorName'];
    departmentId = json['departmentId'];
    department = json['department'];
    instituteId = json['instituteId'];
    institute = json['institute'];
    coverpic = json['coverpic'];
    videoCount = json['videoCount'];
    flippedLecturesCount = json['flippedLecturesCount'];
    professorImageUrl = json['professorImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lastLecture != null) {
      data['lastLecture'] = lastLecture!.toJson();
    }
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['sessionId'] = sessionId;
    data['sessionName'] = sessionName;
    data['professorId'] = professorId;
    data['professorName'] = professorName;
    data['departmentId'] = departmentId;
    data['department'] = department;
    data['instituteId'] = instituteId;
    data['institute'] = institute;
    data['coverpic'] = coverpic;
    data['videoCount'] = videoCount;
    data['flippedLecturesCount'] = flippedLecturesCount;
    data['professorImageUrl'] = professorImageUrl;
    return data;
  }
}

class LastLecture {
  int? ttid;
  int? fcid;
  int? type;
  int? active;
  int? seqNo;
  int? status;
  int? videoId;
  String? filePath;
  String? filePath2;
  int? subjectId;
  String? subjectName;
  int? instituteId;
  String? institute;
  int? departmentId;
  String? department;
  int? classroomId;
  String? classroomName;
  int? sessionId;
  String? sessionName;
  String? topic;
  int? professorId;
  String? professorName;
  String? startTime;
  String? endTime;
  int? livestream;
  int? broadcastMode;
  int? actualDuration;
  int? tapNToggle;
  int? slideCount;
  int? noaudio;
  int? averageRating;
  int? views;
  String? returnURL;
  String? lmsProvider;
  List<Editingcoords>? editingcoords;

  LastLecture({
    this.ttid,
    this.fcid,
    this.type,
    this.active,
    this.seqNo,
    this.status,
    this.videoId,
    this.filePath,
    this.filePath2,
    this.subjectId,
    this.subjectName,
    this.instituteId,
    this.institute,
    this.departmentId,
    this.department,
    this.classroomId,
    this.classroomName,
    this.sessionId,
    this.sessionName,
    this.topic,
    this.professorId,
    this.professorName,
    this.startTime,
    this.endTime,
    this.livestream,
    this.broadcastMode,
    this.actualDuration,
    this.tapNToggle,
    this.slideCount,
    this.noaudio,
    this.averageRating,
    this.views,
    this.returnURL,
    this.lmsProvider,
    this.editingcoords,
  });

  LastLecture.fromJson(Map<String, dynamic> json) {
    ttid = json['ttid'];
    fcid = json['fcid'];
    type = json['type'];
    active = json['active'];
    seqNo = json['seqNo'];
    status = json['status'];
    videoId = json['videoId'];
    filePath = json['filePath'];
    filePath2 = json['filePath2'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    instituteId = json['instituteId'];
    institute = json['institute'];
    departmentId = json['departmentId'];
    department = json['department'];
    classroomId = json['classroomId'];
    classroomName = json['classroomName'];
    sessionId = json['sessionId'];
    sessionName = json['sessionName'];
    topic = json['topic'];
    professorId = json['professorId'];
    professorName = json['professorName'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    livestream = json['livestream'];
    broadcastMode = json['broadcastMode'];
    actualDuration = json['actualDuration'];
    tapNToggle = json['tapNToggle'];
    slideCount = json['slideCount'];
    noaudio = json['noaudio'];
    averageRating = json['averageRating'];
    views = json['views'];
    returnURL = json['returnURL'];
    lmsProvider = json['lmsProvider'];
    if (json['editingcoords'] != null) {
      editingcoords = <Editingcoords>[];
      json['editingcoords'].forEach((v) {
        editingcoords!.add(Editingcoords.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ttid'] = ttid;
    data['fcid'] = fcid;
    data['type'] = type;
    data['active'] = active;
    data['seqNo'] = seqNo;
    data['status'] = status;
    data['videoId'] = videoId;
    data['filePath'] = filePath;
    data['filePath2'] = filePath2;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['instituteId'] = instituteId;
    data['institute'] = institute;
    data['departmentId'] = departmentId;
    data['department'] = department;
    data['classroomId'] = classroomId;
    data['classroomName'] = classroomName;
    data['sessionId'] = sessionId;
    data['sessionName'] = sessionName;
    data['topic'] = topic;
    data['professorId'] = professorId;
    data['professorName'] = professorName;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['livestream'] = livestream;
    data['broadcastMode'] = broadcastMode;
    data['actualDuration'] = actualDuration;
    data['tapNToggle'] = tapNToggle;
    data['slideCount'] = slideCount;
    data['noaudio'] = noaudio;
    data['averageRating'] = averageRating;
    data['views'] = views;
    data['returnURL'] = returnURL;
    data['lmsProvider'] = lmsProvider;
    if (editingcoords != null) {
      data['editingcoords'] = editingcoords!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Editingcoords {
  int? startpos;
  int? endpos;

  Editingcoords({this.startpos, this.endpos});

  Editingcoords.fromJson(Map<String, dynamic> json) {
    startpos = json['startpos'];
    endpos = json['endpos'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startpos'] = startpos;
    data['endpos'] = endpos;
    return data;
  }
}
