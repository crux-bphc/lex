import 'package:flutter/material.dart';
import 'package:ghotpromax/http.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';
import 'package:ghotpromax/modules/cms/models/profile.dart';
import 'package:ghotpromax/modules/cms/models/registered_course.dart';
import 'package:ghotpromax/modules/cms/models/search_result.dart';
import 'package:html2md/html2md.dart' as html2md;

@immutable
class CMSClient {
  const CMSClient(this.token);

  final _baseUrl =
      "https://cms.bits-hyderabad.ac.in/webservice/rest/server.php";
  final String token;

  Future<CMSUser> fetchUserDetail() async {
    final response = await dio.get(
      _baseUrl,
      queryParameters: {
        'wsfunction': 'core_webservice_get_site_info',
        'moodlewsrestformat': 'json',
        'wstoken': token
      },
    );
    return CMSUser.fromJson(response.data);
  }

  Future<List<CMSRegisteredCourse>> fetchCourses(int userId) async {
    final response = await dio.get(
      _baseUrl,
      queryParameters: {
        'wsfunction': 'core_enrol_get_users_courses',
        'moodlewsrestformat': 'json',
        'wstoken': token,
        'userid': userId
      },
    );
    final courses = response.data as List<dynamic>;
    return courses
        .map((course) => CMSRegisteredCourse.fromJson(course))
        .toList(growable: false);
  }

  Future<List<CMSCourseContent>> fetchCourseContent(int courseId) async {
    final response = await dio.get(
      _baseUrl,
      queryParameters: {
        'wsfunction': 'core_course_get_contents',
        'moodlewsrestformat': 'json',
        'wstoken': token,
        'courseid': courseId
      },
    );
    final sections = response.data as List<dynamic>;
    return sections
        .map((section) => CMSCourseContent.fromJson(section))
        .toList(growable: false);
  }

  Future<List<CMSForumDiscussion>> fetchForum(int instanceId) async {
    final response = await dio.get(
      _baseUrl,
      queryParameters: {
        'wsfunction': 'mod_forum_get_forum_discussions',
        'moodlewsrestformat': 'json',
        'wstoken': token,
        'forumid': instanceId
      },
    );
    final discussions = response.data['discussions'] as List<dynamic>;
    return discussions.map((discussion) {
      discussion['message'] = html2md.convert(discussion['message']);
      return CMSForumDiscussion.fromJson(discussion);
    }).toList(growable: false);
  }

  Future<List<CMSSearchResult>> searchCourses(String searchFor) async {
    final response = await dio.get(
      _baseUrl,
      queryParameters: {
        'wsfunction': 'core_course_search_courses',
        'moodlewsrestformat': 'json',
        'wstoken': token,
        'criterianame': 'search',
        'page': 0,
        'perpage': 15,
        'criteriavalue': searchFor
      },
    );
    final courses = response.data['courses'] as List<dynamic>;
    return courses
        .map((course) => CMSSearchResult.fromJson(course))
        .toList(growable: false);
  }

  Future<bool> courseEnroll(int courseId) async {
    final response = await dio.post(
      _baseUrl,
      queryParameters: {
        'wsfunction': 'enrol_self_enrol_user',
        'moodlewsrestformat': 'json',
        'wstoken': token,
        'courseid': courseId
      },
    );
    return response.data['status'] as bool;
  }
}
