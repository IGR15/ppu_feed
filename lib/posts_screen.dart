import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/comments_screen.dart';
import 'package:ppu_feed/controller/post_controller.dart';
import 'package:ppu_feed/model/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostsScreen extends StatefulWidget {
  final int courseId;
  final int sectionId;
  const PostsScreen(
      {super.key, required this.courseId, required this.sectionId});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<Post>> _postsFuture;
  late String postContent;

  @override
  void initState() {
    super.initState();
    _postsFuture = controller.fetchPosts(widget.courseId, widget.sectionId);
  }

  PostController controller = new PostController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;
            if (posts.isEmpty) {
              return const Center(child: Text("No posts available."));
            }
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                Post post = posts[index];
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[300],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(
                        post.body,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "Author: ${post.author}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CommentsScreen(
                                      courseId: widget.courseId,
                                      sectionId: widget.sectionId,
                                      postId: post.id,
                                    )));
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No posts available."));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController postController = TextEditingController();
              return AlertDialog(
                title: const Text("Add a Post"),
                content: TextField(
                  controller: postController,
                  decoration:
                      const InputDecoration(hintText: "Enter post content"),
                  maxLines: 3,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      postContent = postController.text;
                      if (postContent.isNotEmpty) {
                        controller.addPost(
                          context,
                          widget.courseId,
                          widget.sectionId,
                          postContent,
                        );
                        setState(() {
                          _postsFuture = controller.fetchPosts(
                              widget.courseId, widget.sectionId);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Post content cannot be empty")),
                        );
                      }
                    },
                    child: const Text("Submit"),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
