import 'dart:convert';

import 'package:ppu_feed/model/course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CoursesController {
  Future<List<Course>> fetchCourses() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/courses"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      print(res.body);
      var jsonArr = jsonDecode(res.body)['courses'] as List;
      return jsonArr.map((e) => Course.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load courses: ${res.statusCode}");
    }
  }
}
