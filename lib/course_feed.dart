import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/comments_feed.dart';
import 'package:ppu_feed/modules/course.dart';
import 'package:ppu_feed/modules/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CourseFeedScreen extends StatelessWidget {
  final int courseId;
  const CourseFeedScreen({super.key, required this.courseId});

  Future<List<Post>> fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse("http://feeds.ppu.edu/courses/$courseId/posts"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var jsonArr = jsonDecode(res.body)['posts'] as List;
      return jsonArr.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load posts: ${res.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Feed"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Post>>(
        future: fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post.body),
                  subtitle: Text("Posted by: ${post.author}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CommentsFeedScreen(postId: post.id),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No posts available."));
          }
        },
      ),
    );
  }
}
