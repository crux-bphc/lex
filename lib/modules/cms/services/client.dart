import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

@immutable
class CMSClient {
  CMSClient(this.token);

  final _dio = Dio();
  final _baseUrl =
      "https://cms.bits-hyderabad.ac.in/webservice/rest/server.php";
  final String token;

  Future<dynamic> getUserDetail() async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'wsfunction': 'core_webservice_get_site_info',
        'moodlewsrestformat': 'json',
        'wstoken': token
      },
    );
    return response.data;
  }
}
