import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/model/post.dart';
import 'package:ppu_feed/model/section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostController {
  Future<List<Post>> fetchPosts(int courseId,int SectionID) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) throw Exception("Authentication token not found.");
    final res = await http.get(
      Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$SectionID/posts"),
      headers: {'Authorization': token},
    );
    if (res.statusCode == 200) {
      print(res.body);
      final jsonResponse = jsonDecode(res.body)["posts"] as List;
      return jsonResponse.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load posts.");
    }
  }

  Future<void> addPost(context,int courseId,int SectionID,String postContent) async {
    
    final String postUrl =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$SectionID/posts";
    try {
      print(postContent);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("Authentication token not found.");

      final response = await http.post(Uri.parse(postUrl),
          headers: {'Authorization': token}, body: {"body": postContent});
      print(response);

      if (response.statusCode == 200) {
        print(response.body);
       
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post added successfully!")),
        );
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add post: ${response.statusCode}")),
        );
      }
    } catch (error) {
      print(error);
    }
  }
}