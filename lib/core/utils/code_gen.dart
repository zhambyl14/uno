import 'dart:math';

/// Generators for friend codes (12345678) and room codes (ABCD12).
abstract final class CodeGen {
  // No O/0/I/1 — children read these aloud.
  static const String _roomAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Digits only — one character type, easy for a child to read and type on
  /// a phone number pad, no mixed letters/prefix/dashes to fumble.
  static String friendCode([Random? random]) {
    final r = random ?? Random();
    return List.generate(8, (_) => r.nextInt(10).toString()).join();
  }

  static String roomCode([Random? random]) {
    final r = random ?? Random();
    return List.generate(
      6,
      (_) => _roomAlphabet[r.nextInt(_roomAlphabet.length)],
    ).join();
  }

  static final RegExp friendCodePattern = RegExp(r'^\d{8}$');
  static final RegExp roomCodePattern = RegExp(r'^[A-Z2-9]{6}$');

  /// Normalizes user input: trims, uppercases, and strips stray spaces —
  /// forgiving of "1234 5678"-style typing without requiring any format.
  static String normalize(String raw) =>
      raw.trim().toUpperCase().replaceAll(' ', '');
}
