import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/model/comment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommentsController {
  Future<List<Comment>> fetchComments(
      int courseId, int sectionId, int postId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) throw Exception("Authentication token not found.");
    final res = await http.get(
      Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments"),
      headers: {'Authorization': token},
    );
    if (res.statusCode == 200) {
      final jsonResponse = jsonDecode(res.body)["comments"] as List;
      return jsonResponse.map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load comments.");
    }
  }

  Future<void> addComment(context, int courseId, int sectionId, int postId,
      String commentcontent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("Authentication token not found.");
      final res = await http.post(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments"),
        headers: {
          'Authorization': token,
        },
        body: {"body": commentcontent},
      );
      print(res);
      if (res.statusCode == 200) {
        print(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("comment added successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add post: ${res.statusCode}")),
        );
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> deleteComment(
      context, int courseId, int sectionId, int postId, int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("Authentication token not found.");
      final url = Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId");
      final response =
          await http.delete(url, headers: {'Authorization': token});
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment deleted successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete comment.")),
        );
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> editComment(context, int courseId, int sectionId, int postId,
      int commentId, String newContent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("Authentication token not found.");
      final url = Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId");
      final response = await http.put(
        url,
        headers: {'Authorization': token},
        body: {'body': newContent},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment edited successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to edit comment.")),
        );
      }
    } catch (e) {
      print(e); 
    }
  }

  Future<int?> likescount(
      int courseId, int sectionId, int postId, int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("Authentication token not found.");
      final url = Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId/likes");
      final response = await http.get(url, headers: {'Authorization': token});
      if (response.statusCode == 200) {
        print(response.body);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse != null) {
          int like = jsonResponse["likes_count"];
          return like;
        } else {
          throw Exception("Failed to parse response.");
        }
      } else {
        throw Exception("Failed to fetch likes count.");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool?> isliked(
      int courseId, int sectionId, int postId, int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("Authentication token not found.");
      final url = Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId/like");
      final response = await http.get(url, headers: {'Authorization': token});
      if (response.statusCode == 200) {
        print(response.body);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse != null) {
          bool isliked = jsonResponse["liked"];
          return isliked;
        } else {
          throw Exception("Failed to parse response.");
        }
      } else {
        throw Exception("Failed to fetch likes count.");
      }
    } catch (e) {}
  }

  Future<void> likeComment(
      context, int courseId, int sectionId, int postId, int commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("Authentication token not found.");
      final url = Uri.parse(
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId/like");
      final response = await http.post(url, headers: {'Authorization': token});
      if (response.statusCode == 200) {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Liked successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to like comment.")),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
