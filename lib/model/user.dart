
class User {
  String token;
  String username;
 User({required this.token,required this.username});
 factory User.fromJson(dynamic json) {
    return User(
      token: json["token"],
      username: json["username"],
    );
  }
}