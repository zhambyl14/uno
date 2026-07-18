import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../game/data/remote_game_session.dart';
import '../../game/domain/seat_factory.dart';
import '../../game/presentation/game_controller.dart';
import '../data/room_repository.dart';
import '../domain/room.dart';

/// Live room stream for the waiting room, keyed by room code.
final roomStreamProvider = StreamProvider.autoDispose.family<Room?, String>((
  ref,
  code,
) {
  return ref.watch(roomRepositoryProvider).watchRoom(code);
});

/// Actions taken inside a waiting room (add bot, leave, start).
class RoomController extends Notifier<bool> {
  @override
  bool build() => false;

  RoomRepository get _repo => ref.read(roomRepositoryProvider);

  Future<void> addBot(String code) => _run(() => _repo.addBot(code));

  Future<void> leave(String code) {
    final me = ref.read(authControllerProvider).value;
    if (me == null) return Future.value();
    return _run(() => _repo.leaveRoom(code: code, playerId: me.id));
  }

  /// Host starts the match. Local: build a bot-filled session directly.
  /// Online: build the authoritative remote session, then flip room status
  /// so joined clients switch into the game.
  Future<void> startAsHost(Room room) => _run(() async {
    final me = ref.read(authControllerProvider).value!;
    final game = ref.read(gameControllerProvider.notifier);
    if (AppConfig.isOnline) {
      final seats = SeatFactory.fillWithBots(
        humans: [for (final p in room.players) p.toSeat()],
        targetSeats: room.players.length,
      );
      game.attach(
        RemoteGameSession.host(
          hostId: me.id,
          roomCode: room.code,
          mode: room.mode,
          seats: seats,
        ),
      );
      await _repo.startGame(room.code);
    } else {
      final seats = SeatFactory.fillWithBots(
        humans: [for (final p in room.players) p.toSeat()],
        targetSeats: room.players.length < Room.minPlayers
            ? SeatFactory.defaultBotCount + 1
            : room.players.length,
      );
      game.startWithSeats(mode: room.mode, seats: seats, localId: me.id);
      await _repo.startGame(room.code);
    }
  });

  /// A non-host client joins the running match once the host has started.
  Future<bool> joinAsClient(Room room) async {
    if (!AppConfig.isOnline) return false;
    final me = ref.read(authControllerProvider).value!;
    final initial = await _repo.currentGameState(room.code);
    if (initial == null) return false;
    ref
        .read(gameControllerProvider.notifier)
        .attach(
          RemoteGameSession.client(
            playerId: me.id,
            roomCode: room.code,
            initialState: initial,
          ),
        );
    return true;
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

final roomControllerProvider = NotifierProvider<RoomController, bool>(
  RoomController.new,
);
