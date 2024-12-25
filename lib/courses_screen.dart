import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/controller/courses_controller.dart';
import 'package:ppu_feed/model/course.dart';
import 'package:ppu_feed/sections_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({super.key});

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
CoursesController controller = CoursesController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeds"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Course>>(
        future: controller.fetchCourses(),
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
                Course course = courses[index];
                return Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[300],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(course.name),
                      subtitle: Text("College: ${course.college}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CourseFeedScreen(courseId: course.id),
                          ),
                        );
                      },
                    ),
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
