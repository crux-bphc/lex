import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/cms/models/profile.dart';
import 'package:ghotpromax/modules/cms/models/search_result.dart';

@immutable
class CMSClient {
  CMSClient(this.token);

  final _dio = Dio();
  final _baseUrl =
      "https://cms.bits-hyderabad.ac.in/webservice/rest/server.php";
  final String token;

  Future<CMSUser> fetchUserDetail() async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'wsfunction': 'core_webservice_get_site_info',
        'moodlewsrestformat': 'json',
        'wstoken': token
      },
    );
    return CMSUser.fromJson(response.data);
  }

  Future<List<CMSSearchResult>> searchCourses(String searchFor) async {
    final response = await _dio.get(
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
}
