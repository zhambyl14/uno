class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.nickname,
    required this.avatarId,
    required this.rankPoints,
  });

  final String id;
  final String nickname;
  final String avatarId;
  final int rankPoints;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        avatarId: json['avatar_id'] as String? ?? 'cat',
        rankPoints: json['rank_points'] as int? ?? 0,
      );
}
