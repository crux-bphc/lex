class CMSSearchResult {
  int? id;
  String? fullname;
  String? displayname;
  String? shortname;
  int? categoryid;
  String? categoryname;
  int? sortorder;
  String? summary;
  int? summaryformat;
  bool? showactivitydates;
  bool? showcompletionconditions;
  List<CMSSearchResultContacts>? contacts;
  List<String>? enrollmentmethods;

  CMSSearchResult({
    this.id,
    this.fullname,
    this.displayname,
    this.shortname,
    this.categoryid,
    this.categoryname,
    this.sortorder,
    this.summary,
    this.summaryformat,
    this.showactivitydates,
    this.showcompletionconditions,
    this.contacts,
    this.enrollmentmethods,
  });

  CMSSearchResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullname = json['fullname'];
    displayname = json['displayname'];
    shortname = json['shortname'];
    categoryid = json['categoryid'];
    categoryname = json['categoryname'];
    sortorder = json['sortorder'];
    summary = json['summary'];
    summaryformat = json['summaryformat'];
    showactivitydates = json['showactivitydates'];
    showcompletionconditions = json['showcompletionconditions'];
    if (json['contacts'] != null) {
      contacts = <CMSSearchResultContacts>[];
      json['contacts'].forEach((v) {
        contacts!.add(CMSSearchResultContacts.fromJson(v));
      });
    }
    enrollmentmethods = json['enrollmentmethods'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullname'] = fullname;
    data['displayname'] = displayname;
    data['shortname'] = shortname;
    data['categoryid'] = categoryid;
    data['categoryname'] = categoryname;
    data['sortorder'] = sortorder;
    data['summary'] = summary;
    data['summaryformat'] = summaryformat;
    data['showactivitydates'] = showactivitydates;
    data['showcompletionconditions'] = showcompletionconditions;
    if (contacts != null) {
      data['contacts'] = contacts!.map((v) => v.toJson()).toList();
    }
    data['enrollmentmethods'] = enrollmentmethods;
    return data;
  }
}

class CMSSearchResultContacts {
  int? id;
  String? fullname;

  CMSSearchResultContacts({this.id, this.fullname});

  CMSSearchResultContacts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullname = json['fullname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullname'] = fullname;
    return data;
  }
}
