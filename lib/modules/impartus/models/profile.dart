class ImpartusProfile {
  int? userId;
  String? originalname;
  String? fullname;
  String? fname;
  String? lname;
  int? sessionId;
  String? sessionName;
  String? instituteName;
  String? departmentName;
  int? departmentId;
  int? eula;
  String? email;
  String? mobileno;
  String? loginid;
  void email2;
  void email2Verified;
  void mobile2;
  void mobile2Verified;
  void departmentId2;
  void departmentName2;
  void courseId2;
  void courseName2;
  void courseDuration;
  void admissionYear;
  String? courseName;
  int? courseId;
  String? batchName;
  int? batchId;
  int? userType;
  String? section;
  int? instituteId;
  void externalId;
  String? pic;
  String? staticip;
  String? localip;
  String? vpnip;
  int? promptPC;
  int? oneCampus;
  String? oneCampusImage;
  String? oneCampusLink;
  String? supportEmailAddress;
  int? notifications;
  int? autoProcessInterval;
  int? dailyDigest;
  int? weeklyDigest;
  int? hideVideoViews;
  int? hideLeaderBoard;
  int? discoNotification;
  int? eachVideoNotification;
  String? supportChat;
  String? lectureDeletion;
  int? selfSchedule;
  int? disableViewSwitch;
  String? language;
  int? downloadAllowed;
  int? selfenroll;
  int? adIntegrated;
  String? rs;
  String? restoreId;
  String? lastLogin;
  String? campaigns;
  Karma? karma;
  double? karmaGradient;
  int? nRatings;
  int? averageRating;
  int? accessFrom;
  String? instance;
  String? instanceName;

  ImpartusProfile({
    this.userId,
    this.originalname,
    this.fullname,
    this.fname,
    this.lname,
    this.sessionId,
    this.sessionName,
    this.instituteName,
    this.departmentName,
    this.departmentId,
    this.eula,
    this.email,
    this.mobileno,
    this.loginid,
    this.email2,
    this.email2Verified,
    this.mobile2,
    this.mobile2Verified,
    this.departmentId2,
    this.departmentName2,
    this.courseId2,
    this.courseName2,
    this.courseDuration,
    this.admissionYear,
    this.courseName,
    this.courseId,
    this.batchName,
    this.batchId,
    this.userType,
    this.section,
    this.instituteId,
    this.externalId,
    this.pic,
    this.staticip,
    this.localip,
    this.vpnip,
    this.promptPC,
    this.oneCampus,
    this.oneCampusImage,
    this.oneCampusLink,
    this.supportEmailAddress,
    this.notifications,
    this.autoProcessInterval,
    this.dailyDigest,
    this.weeklyDigest,
    this.hideVideoViews,
    this.hideLeaderBoard,
    this.discoNotification,
    this.eachVideoNotification,
    this.supportChat,
    this.lectureDeletion,
    this.selfSchedule,
    this.disableViewSwitch,
    this.language,
    this.downloadAllowed,
    this.selfenroll,
    this.adIntegrated,
    this.rs,
    this.restoreId,
    this.lastLogin,
    this.campaigns,
    this.karma,
    this.karmaGradient,
    this.nRatings,
    this.averageRating,
    this.accessFrom,
    this.instance,
    this.instanceName,
  });

  ImpartusProfile.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    originalname = json['originalname'];
    fullname = json['fullname'];
    fname = json['fname'];
    lname = json['lname'];
    sessionId = json['sessionId'];
    sessionName = json['sessionName'];
    instituteName = json['instituteName'];
    departmentName = json['departmentName'];
    departmentId = json['departmentId'];
    eula = json['eula'];
    email = json['email'];
    mobileno = json['mobileno'];
    loginid = json['loginid'];
    // email2 = json['email2'];
    // email2Verified = json['email2Verified'];
    // mobile2 = json['mobile2'];
    // mobile2Verified = json['mobile2Verified'];
    // departmentId2 = json['departmentId2'];
    // departmentName2 = json['departmentName2'];
    // courseId2 = json['courseId2'];
    // courseName2 = json['courseName2'];
    // courseDuration = json['courseDuration'];
    // admissionYear = json['admissionYear'];
    courseName = json['courseName'];
    courseId = json['courseId'];
    batchName = json['batchName'];
    batchId = json['batchId'];
    userType = json['userType'];
    section = json['section'];
    instituteId = json['instituteId'];
    // externalId = json['externalId'];
    pic = json['pic'];
    staticip = json['staticip'];
    localip = json['localip'];
    vpnip = json['vpnip'];
    promptPC = json['promptPC'];
    oneCampus = json['oneCampus'];
    oneCampusImage = json['oneCampusImage'];
    oneCampusLink = json['oneCampusLink'];
    supportEmailAddress = json['supportEmailAddress'];
    notifications = json['notifications'];
    autoProcessInterval = json['autoProcessInterval'];
    dailyDigest = json['dailyDigest'];
    weeklyDigest = json['weeklyDigest'];
    hideVideoViews = json['hideVideoViews'];
    hideLeaderBoard = json['hideLeaderBoard'];
    discoNotification = json['discoNotification'];
    eachVideoNotification = json['eachVideoNotification'];
    supportChat = json['supportChat'];
    lectureDeletion = json['lectureDeletion'];
    selfSchedule = json['selfSchedule'];
    disableViewSwitch = json['disableViewSwitch'];
    language = json['language'];
    downloadAllowed = json['downloadAllowed'];
    selfenroll = json['selfenroll'];
    adIntegrated = json['adIntegrated'];
    rs = json['rs'];
    restoreId = json['restoreId'];
    lastLogin = json['lastLogin'];
    campaigns = json['campaigns'];
    karma = json['karma'] != null ? Karma.fromJson(json['karma']) : null;
    karmaGradient = json['karmaGradient'];
    nRatings = json['nRatings'];
    averageRating = json['averageRating'];
    accessFrom = json['accessFrom'];
    instance = json['instance'];
    instanceName = json['instanceName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['originalname'] = originalname;
    data['fullname'] = fullname;
    data['fname'] = fname;
    data['lname'] = lname;
    data['sessionId'] = sessionId;
    data['sessionName'] = sessionName;
    data['instituteName'] = instituteName;
    data['departmentName'] = departmentName;
    data['departmentId'] = departmentId;
    data['eula'] = eula;
    data['email'] = email;
    data['mobileno'] = mobileno;
    data['loginid'] = loginid;
    // data['email2'] = email2;
    // data['email2Verified'] = email2Verified;
    // data['mobile2'] = mobile2;
    // data['mobile2Verified'] = mobile2Verified;
    // data['departmentId2'] = departmentId2;
    // data['departmentName2'] = departmentName2;
    // data['courseId2'] = courseId2;
    // data['courseName2'] = courseName2;
    // data['courseDuration'] = courseDuration;
    // data['admissionYear'] = admissionYear;
    data['courseName'] = courseName;
    data['courseId'] = courseId;
    data['batchName'] = batchName;
    data['batchId'] = batchId;
    data['userType'] = userType;
    data['section'] = section;
    data['instituteId'] = instituteId;
    // data['externalId'] = externalId;
    data['pic'] = pic;
    data['staticip'] = staticip;
    data['localip'] = localip;
    data['vpnip'] = vpnip;
    data['promptPC'] = promptPC;
    data['oneCampus'] = oneCampus;
    data['oneCampusImage'] = oneCampusImage;
    data['oneCampusLink'] = oneCampusLink;
    data['supportEmailAddress'] = supportEmailAddress;
    data['notifications'] = notifications;
    data['autoProcessInterval'] = autoProcessInterval;
    data['dailyDigest'] = dailyDigest;
    data['weeklyDigest'] = weeklyDigest;
    data['hideVideoViews'] = hideVideoViews;
    data['hideLeaderBoard'] = hideLeaderBoard;
    data['discoNotification'] = discoNotification;
    data['eachVideoNotification'] = eachVideoNotification;
    data['supportChat'] = supportChat;
    data['lectureDeletion'] = lectureDeletion;
    data['selfSchedule'] = selfSchedule;
    data['disableViewSwitch'] = disableViewSwitch;
    data['language'] = language;
    data['downloadAllowed'] = downloadAllowed;
    data['selfenroll'] = selfenroll;
    data['adIntegrated'] = adIntegrated;
    data['rs'] = rs;
    data['restoreId'] = restoreId;
    data['lastLogin'] = lastLogin;
    data['campaigns'] = campaigns;
    if (karma != null) {
      data['karma'] = karma!.toJson();
    }
    data['karmaGradient'] = karmaGradient;
    data['nRatings'] = nRatings;
    data['averageRating'] = averageRating;
    data['accessFrom'] = accessFrom;
    data['instance'] = instance;
    data['instanceName'] = instanceName;
    return data;
  }
}

class Karma {
  int? x;
  int? y;
  int? total;

  Karma({this.x, this.y, this.total});

  Karma.fromJson(Map<String, dynamic> json) {
    x = json['X'];
    y = json['Y'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['X'] = x;
    data['Y'] = y;
    data['total'] = total;
    return data;
  }
}
