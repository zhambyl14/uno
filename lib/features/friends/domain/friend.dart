class Friend {
  const Friend({
    required this.id,
    required this.nickname,
    required this.avatarId,
    required this.friendCode,
  });

  final String id;
  final String nickname;
  final String avatarId;
  final String friendCode;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'avatar_id': avatarId,
    'friend_code': friendCode,
  };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'] as String,
    nickname: json['nickname'] as String,
    avatarId: json['avatar_id'] as String? ?? 'cat',
    friendCode: json['friend_code'] as String,
  );
}
