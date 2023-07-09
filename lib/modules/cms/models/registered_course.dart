class CMSRegisteredCourse {
  int? id;
  String? shortname;
  String? fullname;
  String? displayname;
  int? enrolledusercount;
  String? idnumber;
  int? visible;
  String? summary;
  int? summaryformat;
  String? format;
  bool? showgrades;
  String? lang;
  bool? enablecompletion;
  bool? completionhascriteria;
  bool? completionusertracked;
  int? category;
  // double? progress;
  bool? completed;
  int? startdate;
  int? enddate;
  int? marker;
  int? lastaccess;
  bool? isfavourite;
  bool? hidden;
  // List<void>? overviewfiles;
  bool? showactivitydates;
  bool? showcompletionconditions;
  int? timemodified;

  CMSRegisteredCourse({
    this.id,
    this.shortname,
    this.fullname,
    this.displayname,
    this.enrolledusercount,
    this.idnumber,
    this.visible,
    this.summary,
    this.summaryformat,
    this.format,
    this.showgrades,
    this.lang,
    this.enablecompletion,
    this.completionhascriteria,
    this.completionusertracked,
    this.category,
    // this.progress,
    this.completed,
    this.startdate,
    this.enddate,
    this.marker,
    this.lastaccess,
    this.isfavourite,
    this.hidden,
    // this.overviewfiles,
    this.showactivitydates,
    this.showcompletionconditions,
    this.timemodified,
  });

  CMSRegisteredCourse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shortname = json['shortname'];
    fullname = json['fullname'];
    displayname = json['displayname'];
    enrolledusercount = json['enrolledusercount'];
    idnumber = json['idnumber'];
    visible = json['visible'];
    summary = json['summary'];
    summaryformat = json['summaryformat'];
    format = json['format'];
    showgrades = json['showgrades'];
    lang = json['lang'];
    enablecompletion = json['enablecompletion'];
    completionhascriteria = json['completionhascriteria'];
    completionusertracked = json['completionusertracked'];
    category = json['category'];
    // progress = json['progress'];
    completed = json['completed'];
    startdate = json['startdate'];
    enddate = json['enddate'];
    marker = json['marker'];
    lastaccess = json['lastaccess'];
    isfavourite = json['isfavourite'];
    hidden = json['hidden'];
    // if (json['overviewfiles'] != null) {
    //   overviewfiles = <Null>[];
    //   json['overviewfiles'].forEach((v) {
    //     overviewfiles!.add(void.fromJson(v));
    //   });
    // }
    showactivitydates = json['showactivitydates'];
    showcompletionconditions = json['showcompletionconditions'];
    timemodified = json['timemodified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['shortname'] = shortname;
    data['fullname'] = fullname;
    data['displayname'] = displayname;
    data['enrolledusercount'] = enrolledusercount;
    data['idnumber'] = idnumber;
    data['visible'] = visible;
    data['summary'] = summary;
    data['summaryformat'] = summaryformat;
    data['format'] = format;
    data['showgrades'] = showgrades;
    data['lang'] = lang;
    data['enablecompletion'] = enablecompletion;
    data['completionhascriteria'] = completionhascriteria;
    data['completionusertracked'] = completionusertracked;
    data['category'] = category;
    // data['progress'] = progress;
    data['completed'] = completed;
    data['startdate'] = startdate;
    data['enddate'] = enddate;
    data['marker'] = marker;
    data['lastaccess'] = lastaccess;
    data['isfavourite'] = isfavourite;
    data['hidden'] = hidden;
    // if (overviewfiles != null) {
    //   data['overviewfiles'] =
    //       overviewfiles!.map((v) => v.toJson()).toList();
    // }
    data['showactivitydates'] = showactivitydates;
    data['showcompletionconditions'] = showcompletionconditions;
    data['timemodified'] = timemodified;
    return data;
  }
}
