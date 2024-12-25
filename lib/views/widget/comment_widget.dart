import 'package:flutter/material.dart';
import 'package:ppu_feed/controller/comments_controller.dart';
import 'package:ppu_feed/model/comment.dart';

class CommentDetails extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;
  final int commentId;

  CommentDetails(
      {Key? key,
      required this.comment,
      required this.courseId,
      required this.sectionId,
      required this.postId,
      required this.commentId})
      : super(key: key);
  Comment comment;
  @override
  _CommentDetailsState createState() => _CommentDetailsState();
}

class _CommentDetailsState extends State<CommentDetails> {
  late bool isliked;
  CommentsController controller = CommentsController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Comment comment = widget.comment;

    return SimpleDialog(
      children: [
        Container(
          child: Column(
            children: [
              ListTile(
                title: Text(comment.author),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 30,
                  child: Text(comment.author[0]),
                ),
              ),
              ListTile(
                title: Text(comment.body),
              ),
              Divider(),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        FutureBuilder(
                          future: controller.likescount(
                              widget.courseId,
                              widget.sectionId,
                              widget.postId,
                              widget.commentId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text("${snapshot.data}");
                            }

                            return CircularProgressIndicator();
                          },
                        ),
                        FutureBuilder(
                          future: controller.isliked(
                              widget.courseId,
                              widget.sectionId,
                              widget.postId,
                              widget.commentId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              bool? liked = snapshot.data;
                              return IconButton(
                                  onPressed: () {
                                    controller
                                        .likeComment(
                                            context,
                                            widget.courseId,
                                            widget.sectionId,
                                            widget.postId,
                                            widget.commentId)
                                        .then(
                                      (value) {
                                        setState(() {});
                                      },
                                    );
                                  },
                                  icon: Icon(liked!
                                      ? Icons.favorite
                                      : Icons.favorite_border));
                            }
                            return CircularProgressIndicator();
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }
}
