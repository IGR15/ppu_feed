import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ppu_feed/controller/comments_controller.dart';
import 'package:ppu_feed/model/comment.dart';
import 'package:ppu_feed/views/widget/comment_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommentsScreen extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;

  const CommentsScreen({
    super.key,
    required this.courseId,
    required this.sectionId,
    required this.postId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  CommentsController controller = new CommentsController();
  late String commentcontent;
  late Future<List<Comment>> _commentsFuture;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    loadUsername();

    _commentsFuture = controller.fetchComments(
        widget.courseId, widget.sectionId, widget.postId);
  }

  loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Comment>>(
        future: _commentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final comments = snapshot.data!;
            if (comments.isEmpty) {
              return const Center(child: Text("No comments available."));
            }
            return ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                Comment comment = comments[index];
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[300],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(
                        comment.body,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CommentDetails(comment: comment,courseId:widget.courseId,sectionId: widget.sectionId,postId:widget.postId,commentId: comment.id,);
                          },
                        );
                      },
                      subtitle: Text(
                        "Author: ${comment.author}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: currentUsername == comment.author
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  onPressed: () {
                                    TextEditingController editController =
                                        TextEditingController(
                                            text: comment.body);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Edit Comment"),
                                        content: TextField(
                                          controller: editController,
                                          decoration: const InputDecoration(
                                              hintText: "Enter new content"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (editController
                                                  .text.isNotEmpty) {
                                                controller
                                                    .editComment(
                                                        context,
                                                        widget.courseId,
                                                        widget.sectionId,
                                                        widget.postId,
                                                        comment.id,
                                                        editController.text)
                                                    .then(
                                                  (value) {
                                                    setState(() {
                                                      _commentsFuture =
                                                          controller
                                                              .fetchComments(
                                                                  widget
                                                                      .courseId,
                                                                  widget
                                                                      .sectionId,
                                                                  widget
                                                                      .postId);
                                                    });
                                                  },
                                                );

                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text("Save"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () {
                                    controller
                                        .deleteComment(
                                            context,
                                            widget.courseId,
                                            widget.sectionId,
                                            widget.postId,
                                            comment.id)
                                        .then(
                                      (value) {
                                        setState(() {
                                          _commentsFuture =
                                              controller.fetchComments(
                                                  widget.courseId,
                                                  widget.sectionId,
                                                  widget.postId);
                                        });
                                      },
                                    );
                                  },
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No comments available."));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController commetnController = TextEditingController();
              return AlertDialog(
                title: const Text("Add a Post"),
                content: TextField(
                  controller: commetnController,
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
                      commentcontent = commetnController.text;
                      if (commentcontent.isNotEmpty) {
                        controller.addComment(context, widget.courseId,
                            widget.sectionId, widget.postId, commentcontent).then((value) {
                              setState(() {
                          _commentsFuture = controller.fetchComments(
                              widget.courseId, widget.sectionId, widget.postId);
                        });
                            },);
                        
                        Navigator.pop(context);
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
