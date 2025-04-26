class User {
  final int? userId;
  final String? username;
  User({required this.userId, required this.username});

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
    );
  }
}
