import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/modules/comment.dart';
import 'package:ppu_feed/modules/course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommentsFeedScreen extends StatelessWidget {
  final int postId;
  const CommentsFeedScreen({super.key, required this.postId});

  Future<List<Comment>> fetchComments() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) throw Exception("Authentication token not found.");

    final res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/posts/$postId/comments"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var jsonArr = jsonDecode(res.body)['comments'] as List;
      return jsonArr.map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load comments: ${res.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Comment>>(
        future: fetchComments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final comments = snapshot.data!;
            return ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  title: Text(comment.body),
                  subtitle: Text("By: ${comment.author}"),
                );
              },
            );
          } else {
            return const Center(child: Text("No comments available."));
          }
        },
      ),
    );
  }
}
