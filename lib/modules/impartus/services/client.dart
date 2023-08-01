import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ghotpromax/http.dart';
import 'package:ghotpromax/modules/impartus/models/profile.dart';
import 'package:ghotpromax/modules/impartus/models/subject.dart';

@immutable
class ImpartusClient {
  const ImpartusClient(this.auth);
  final String auth;
  final String _baseUrl = "https://bitshyd.impartus.com/api";

  static Future<String> getAuthToken(String email, String password) async {
    Response response = await dio.post(
      "https://bitshyd.impartus.com/api/auth/signin",
      data: {'username': email, 'password': password},
    );
    return response.data['token'];
  }

  static Future<bool> checkAuthToken(String value) async {
    try {
      Response response = await dio.get(
        "https://bitshyd.impartus.com/api/language/supported/",
        options: Options(
          headers: {
            'authorization': 'Bearer $value',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<ImpartusProfile> getProfile() async {
    Response response = await dio.get(
      "$_baseUrl/user/profile",
      options: Options(
        headers: {"authorization": "Bearer $auth"},
      ),
    );
    return ImpartusProfile.fromJson(response.data);
  }

  Future<List<ImpartusSubject>> getSubjects() async {
    Response response = await dio.get(
      "$_baseUrl/subjects",
      options: Options(
        headers: {"authorization": "Bearer $auth"},
      ),
    );
    final subjects = response.data as List<dynamic>;
    return subjects
        .map((subject) => ImpartusSubject.fromJson(subject))
        .toList(growable: false);
  }

  Future<List<ImpartusLecture>> getLectures(
    String subjectId,
    String sessionId,
  ) async {
    Response response = await dio.get(
      "$_baseUrl/subjects/$subjectId/lectures/$sessionId",
      options: Options(
        headers: {"authorization": "Bearer $auth"},
      ),
    );
    final lectures = response.data as List<dynamic>;
    return lectures
        .map((lecture) => ImpartusLecture.fromJson(lecture))
        .toList(growable: false);
  }
}
