class Comment {
  final int id;
  final String body;
  final String author;

  Comment({required this.id, required this.body, required this.author});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      body: json['body'],
      author: json['author'],
    );
  }
}
