import 'dart:math';

/// Generators for friend codes (UNO-1234-5678) and room codes (ABCD12).
abstract final class CodeGen {
  // No O/0/I/1 — children read these aloud.
  static const String _roomAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String friendCode([Random? random]) {
    final r = random ?? Random();
    String block() => List.generate(4, (_) => r.nextInt(10).toString()).join();
    return 'UNO-${block()}-${block()}';
  }

  static String roomCode([Random? random]) {
    final r = random ?? Random();
    return List.generate(
      6,
      (_) => _roomAlphabet[r.nextInt(_roomAlphabet.length)],
    ).join();
  }

  static final RegExp friendCodePattern = RegExp(r'^UNO-\d{4}-\d{4}$');
  static final RegExp roomCodePattern = RegExp(r'^[A-Z2-9]{6}$');

  /// Normalizes user input: trims, uppercases.
  static String normalize(String raw) => raw.trim().toUpperCase();
}
