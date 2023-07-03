class CMSUser {
  String? sitename;
  String? username;
  String? firstname;
  String? lastname;
  String? fullname;
  String? lang;
  int? userid;
  String? siteurl;
  String? userpictureurl;
  int? downloadfiles;
  int? uploadfiles;
  String? release;
  String? version;
  String? mobilecssurl;
  bool? usercanmanageownfiles;
  int? userquota;
  int? usermaxuploadfilesize;
  int? userhomepage;
  String? userprivateaccesskey;
  int? siteid;
  String? sitecalendartype;
  String? usercalendartype;
  bool? userissiteadmin;
  String? theme;
  int? limitconcurrentlogins;

  CMSUser({
    this.sitename,
    this.username,
    this.firstname,
    this.lastname,
    this.fullname,
    this.lang,
    this.userid,
    this.siteurl,
    this.userpictureurl,
    this.downloadfiles,
    this.uploadfiles,
    this.release,
    this.version,
    this.mobilecssurl,
    this.usercanmanageownfiles,
    this.userquota,
    this.usermaxuploadfilesize,
    this.userhomepage,
    this.userprivateaccesskey,
    this.siteid,
    this.sitecalendartype,
    this.usercalendartype,
    this.userissiteadmin,
    this.theme,
    this.limitconcurrentlogins,
  });

  CMSUser.fromJson(Map<String, dynamic> json) {
    sitename = json['sitename'];
    username = json['username'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    fullname = json['fullname'];
    lang = json['lang'];
    userid = json['userid'];
    siteurl = json['siteurl'];
    userpictureurl = json['userpictureurl'];
    downloadfiles = json['downloadfiles'];
    uploadfiles = json['uploadfiles'];
    release = json['release'];
    version = json['version'];
    mobilecssurl = json['mobilecssurl'];
    usercanmanageownfiles = json['usercanmanageownfiles'];
    userquota = json['userquota'];
    usermaxuploadfilesize = json['usermaxuploadfilesize'];
    userhomepage = json['userhomepage'];
    userprivateaccesskey = json['userprivateaccesskey'];
    siteid = json['siteid'];
    sitecalendartype = json['sitecalendartype'];
    usercalendartype = json['usercalendartype'];
    userissiteadmin = json['userissiteadmin'];
    theme = json['theme'];
    limitconcurrentlogins = json['limitconcurrentlogins'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sitename'] = sitename;
    data['username'] = username;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['fullname'] = fullname;
    data['lang'] = lang;
    data['userid'] = userid;
    data['siteurl'] = siteurl;
    data['userpictureurl'] = userpictureurl;
    data['downloadfiles'] = downloadfiles;
    data['uploadfiles'] = uploadfiles;
    data['release'] = release;
    data['version'] = version;
    data['mobilecssurl'] = mobilecssurl;
    data['usercanmanageownfiles'] = usercanmanageownfiles;
    data['userquota'] = userquota;
    data['usermaxuploadfilesize'] = usermaxuploadfilesize;
    data['userhomepage'] = userhomepage;
    data['userprivateaccesskey'] = userprivateaccesskey;
    data['siteid'] = siteid;
    data['sitecalendartype'] = sitecalendartype;
    data['usercalendartype'] = usercalendartype;
    data['userissiteadmin'] = userissiteadmin;
    data['theme'] = theme;
    data['limitconcurrentlogins'] = limitconcurrentlogins;
    return data;
  }
}
