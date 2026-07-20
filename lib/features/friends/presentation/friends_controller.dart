import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/friends_repository.dart';
import '../domain/friend.dart';
import '../domain/game_invite.dart';

class FriendsController extends AsyncNotifier<List<Friend>> {
  FriendsRepository get _repo => ref.read(friendsRepositoryProvider);

  @override
  Future<List<Friend>> build() => _repo.list();

  Future<void> addByCode(String code) async {
    final myCode = ref.read(authControllerProvider).value?.friendCode ?? '';
    // Let the error propagate to the caller for a snackbar; keep list intact.
    await _repo.addByCode(code: code, myCode: myCode);
    state = AsyncData(await _repo.list());
  }

  Future<void> remove(String friendId) async {
    await _repo.remove(friendId);
    state = AsyncData(await _repo.list());
  }

  Future<void> inviteToRoom({
    required String friendId,
    required String roomCode,
  }) => _repo.inviteToRoom(friendId: friendId, roomCode: roomCode);

  Future<void> consumeInvite(int inviteId) => _repo.consumeInvite(inviteId);
}

final friendsControllerProvider =
    AsyncNotifierProvider<FriendsController, List<Friend>>(
      FriendsController.new,
    );

/// Live incoming room invites for the signed-in user. Watched app-wide by the
/// navigation shell so a friend's invite surfaces wherever the player is.
final incomingInvitesProvider = StreamProvider.autoDispose<List<GameInvite>>(
  (ref) => ref.watch(friendsRepositoryProvider).watchInvites(),
);
