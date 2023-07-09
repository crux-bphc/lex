import 'package:dio/dio.dart';
import 'package:ghotpromax/modules/impartus/models/lecture.dart';
import 'package:ghotpromax/modules/impartus/models/profile.dart';
import 'package:ghotpromax/modules/impartus/models/subject.dart';

class ImpartusClient {
  ImpartusClient(this._email, this._password);
  final String _email;
  final String _password;
  final Dio _dio = Dio();
  final String _baseUrl = "https://bitshyd.impartus.com/api";
  String? auth;

  setAuthToken(String value) {
    auth = value;
    _dio.options.headers["authorization"] = "Bearer $auth";
  }

  Future<String> getAuthToken() async {
    Response response = await _dio.post(
      "$_baseUrl/auth/signin",
      data: {'username': _email, 'password': _password},
    );
    return response.data['token'];
  }

  Future<bool> checkAuthToken(String value) async {
    try {
      Response response = await _dio.get(
        "$_baseUrl/language/supported/",
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
    Response response = await _dio.get("$_baseUrl/user/profile");
    return ImpartusProfile.fromJson(response.data);
  }

  Future<List<ImpartusSubject>> getSubjects() async {
    Response response = await _dio.get("$_baseUrl/subjects");
    final subjects = response.data as List<dynamic>;
    return subjects
        .map((subject) => ImpartusSubject.fromJson(subject))
        .toList(growable: false);
  }

  Future<List<ImpartusLecture>> getLectures(
    String subjectId,
    String sessionId,
  ) async {
    Response response = await _dio.get(
      "$_baseUrl/subjects/$subjectId/lectures/$sessionId",
    );
    final lectures = response.data as List<dynamic>;
    return lectures
        .map((lecture) => ImpartusLecture.fromJson(lecture))
        .toList(growable: false);
  }
}