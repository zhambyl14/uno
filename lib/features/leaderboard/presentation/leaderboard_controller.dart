import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

final leaderboardControllerProvider =
    FutureProvider.autoDispose<List<LeaderboardEntry>>(
      (ref) => ref.watch(leaderboardRepositoryProvider).top(),
    );
