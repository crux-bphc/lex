import 'package:dio/dio.dart';
import 'package:ghotpromax/http.dart';
import 'package:ghotpromax/modules/impartus/models/profile.dart';
import 'package:ghotpromax/modules/impartus/models/subject.dart';

class ImpartusClient {
  ImpartusClient(this._email, this._password);
  final String _email;
  final String _password;
  final String _baseUrl = "https://bitshyd.impartus.com/api";
  String? auth;

  setAuthToken(String value) {
    auth = value;
  }

  Future<String> getAuthToken() async {
    Response response = await dio.post(
      "$_baseUrl/auth/signin",
      data: {'username': _email, 'password': _password},
      options: Options(
        headers: {"authorization": "Bearer $auth"},
      ),
    );
    return response.data['token'];
  }

  Future<bool> checkAuthToken(String value) async {
    try {
      Response response = await dio.get(
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
