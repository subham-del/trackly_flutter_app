class Friend {
  final int friendId;
  final String friendName;

  Friend({required this.friendId, required this.friendName});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      friendId: json['FriendId'],
      friendName: json['FriendName'],
    );
  }
}