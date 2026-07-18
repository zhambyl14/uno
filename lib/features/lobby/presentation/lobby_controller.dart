import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../game/domain/game_mode.dart';
import '../../game/presentation/game_controller.dart';
import '../data/room_repository.dart';
import '../domain/room.dart';

/// One-shot lobby actions. State is a simple busy flag so buttons disable
/// while a request is in flight.
class LobbyController extends Notifier<bool> {
  @override
  bool build() => false;

  RoomRepository get _repo => ref.read(roomRepositoryProvider);

  RoomPlayer _me({required bool host}) {
    final profile = ref.read(authControllerProvider).value!;
    return RoomPlayer(
      id: profile.id,
      name: profile.nickname,
      avatarId: profile.avatarId,
      isHost: host,
    );
  }

  Future<Room> createRoom({required bool isPublic, required GameMode mode}) =>
      _run(
        () => _repo.createRoom(
          isPublic: isPublic,
          mode: mode,
          host: _me(host: true),
        ),
      );

  Future<Room> joinByCode(String code) =>
      _run(() => _repo.joinRoom(code: code, player: _me(host: false)));

  Future<Room> quickMatch(GameMode mode) =>
      _run(() => _repo.quickMatch(mode: mode, player: _me(host: false)));

  /// Instant solo match against bots — no room needed.
  void startVsBots(GameMode mode) {
    ref.read(gameControllerProvider.notifier).startLocal(mode: mode);
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    state = true;
    try {
      return await action();
    } finally {
      state = false;
    }
  }
}

final lobbyControllerProvider = NotifierProvider<LobbyController, bool>(
  LobbyController.new,
);
