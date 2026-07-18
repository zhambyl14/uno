import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/friends_repository.dart';
import '../domain/friend.dart';

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

  Future<void> invite(String friendId) => _repo.invite(friendId);
}

final friendsControllerProvider =
    AsyncNotifierProvider<FriendsController, List<Friend>>(
      FriendsController.new,
    );
