class ImpartusLecture {
  int? type;
  int? ttid;
  int? seqNo;
  int? status;
  int? videoId;
  int? subjectId;
  String? subjectName;
  int? selfenroll;
  String? coverpic;
  String? subjectCode;
  String? subjectDescription;
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
  String? professorImageUrl;
  String? startTime;
  String? endTime;
  int? actualDuration;
  int? tapNToggle;
  String? filePath;
  String? filePath2;
  int? slideCount;
  int? noaudio;
  int? averageRating;
  int? views;
  int? documentCount;
  int? lessonPlanAvailable;
  int? trending;
  int? lastPosition;

  ImpartusLecture(
      {this.type,
      this.ttid,
      this.seqNo,
      this.status,
      this.videoId,
      this.subjectId,
      this.subjectName,
      this.selfenroll,
      this.coverpic,
      this.subjectCode,
      this.subjectDescription,
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
      this.professorImageUrl,
      this.startTime,
      this.endTime,
      this.actualDuration,
      this.tapNToggle,
      this.filePath,
      this.filePath2,
      this.slideCount,
      this.noaudio,
      this.averageRating,
      this.views,
      this.documentCount,
      this.lessonPlanAvailable,
      this.trending,
      this.lastPosition,});

  ImpartusLecture.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    ttid = json['ttid'];
    seqNo = json['seqNo'];
    status = json['status'];
    videoId = json['videoId'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    selfenroll = json['selfenroll'];
    coverpic = json['coverpic'];
    subjectCode = json['subjectCode'];
    subjectDescription = json['subjectDescription'];
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
    professorImageUrl = json['professorImageUrl'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    actualDuration = json['actualDuration'];
    tapNToggle = json['tapNToggle'];
    filePath = json['filePath'];
    filePath2 = json['filePath2'];
    slideCount = json['slideCount'];
    noaudio = json['noaudio'];
    averageRating = json['averageRating'];
    views = json['views'];
    documentCount = json['documentCount'];
    lessonPlanAvailable = json['lessonPlanAvailable'];
    trending = json['trending'];
    lastPosition = json['lastPosition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['ttid'] = ttid;
    data['seqNo'] = seqNo;
    data['status'] = status;
    data['videoId'] = videoId;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['selfenroll'] = selfenroll;
    data['coverpic'] = coverpic;
    data['subjectCode'] = subjectCode;
    data['subjectDescription'] = subjectDescription;
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
    data['professorImageUrl'] = professorImageUrl;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['actualDuration'] = actualDuration;
    data['tapNToggle'] = tapNToggle;
    data['filePath'] = filePath;
    data['filePath2'] = filePath2;
    data['slideCount'] = slideCount;
    data['noaudio'] = noaudio;
    data['averageRating'] = averageRating;
    data['views'] = views;
    data['documentCount'] = documentCount;
    data['lessonPlanAvailable'] = lessonPlanAvailable;
    data['trending'] = trending;
    data['lastPosition'] = lastPosition;
    return data;
  }
}
