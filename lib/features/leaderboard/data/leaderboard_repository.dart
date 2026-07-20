import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/strings.dart';
import '../../../core/utils/failures.dart';
import '../domain/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  /// Top players by rank points. Throws [OfflineFailure] when there is no
  /// backend to query — the screen checks [AppConfig.isOnline] first so
  /// this is only reached in online mode.
  Future<List<LeaderboardEntry>> top({int limit = 50});
}

class SupabaseLeaderboardRepository implements LeaderboardRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<LeaderboardEntry>> top({int limit = 50}) async {
    // A guest whose silent anonymous sign-in failed (no backend session) has
    // no `authenticated` role for RLS — querying would just surface a
    // confusing permission error. Fail with a typed, actionable state instead.
    if (_client.auth.currentUser == null) {
      throw OfflineFailure(S.leaderboardSignInBody);
    }
    try {
      final rows = await _client
          .from('profiles')
          .select('id, nickname, avatar_id, rank_points')
          .order('rank_points', ascending: false)
          .limit(limit);
      return [for (final row in rows) LeaderboardEntry.fromJson(row)];
    } on PostgrestException {
      throw NetworkFailure(S.networkError);
    }
  }
}

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => SupabaseLeaderboardRepository(),
);
