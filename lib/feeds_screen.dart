import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/modules/course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({super.key});

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  Future<List<Course>> fetchCourses() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse("http://feeds.ppu.edu/courses"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var jsonArr = jsonDecode(res.body)['courses'] as List;
      return jsonArr.map((e) => Course.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load courses: ${res.statusCode}");
    }
  }

  Future<void> subscribeToCourse(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.post(
      Uri.parse("http://feeds.ppu.edu/courses/$courseId/subscribe"),
      headers: {'Authorization': token},
    );

    if (res.statusCode != 200) throw Exception("Failed to subscribe.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeds"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Course>>(
        future: fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final courses = snapshot.data!;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  title: Text(course.name),
                  subtitle: Text("College: ${course.college}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await subscribeToCourse(course.id.toString());
                      setState(() {}); // Refresh the UI
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No courses available."));
          }
        },
      ),
    );
  }
}