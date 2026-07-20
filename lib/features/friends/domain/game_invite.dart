/// A friend's invite to a specific waiting room. Streamed to the recipient
/// over Supabase Realtime so tapping it drops them straight into that room.
class GameInvite {
  const GameInvite({
    required this.id,
    required this.fromId,
    required this.roomCode,
  });

  final int id;
  final String fromId;
  final String roomCode;

  factory GameInvite.fromJson(Map<String, dynamic> json) => GameInvite(
    id: json['id'] as int,
    fromId: json['from_id'] as String,
    roomCode: json['room_code'] as String,
  );
}
