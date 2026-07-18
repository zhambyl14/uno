import '../constants/strings.dart';

/// Child-safety nickname validation: profanity, contact info and links are
/// rejected. Returns a user-facing error message, or null when valid.
abstract final class NicknameFilter {
  static const int minLength = 3;
  static const int maxLength = 16;

  static final RegExp _allowed = RegExp(
    r'^[a-zA-Zа-яА-ЯәғқңөұүһіӘҒҚҢӨҰҮҺІ0-9_]+$',
  );
  static final RegExp _phone = RegExp(r'\d{6,}');
  static final RegExp _contact = RegExp(
    r'(https?|www\.|\.com|\.kz|\.ru|\.net|@|tiktok|insta|telegram|whatsapp|wa\.me|t\.me|mail\.|gmail)',
    caseSensitive: false,
  );

  // Substring blocklist, checked on a lowercased, de-obfuscated value.
  static const List<String> _banned = [
    'sex',
    'секс',
    'porn',
    'порн',
    'fuck',
    'фак',
    'shit',
    'bitch',
    'suka',
    'сука',
    'блять',
    'блядь',
    'bliat',
    'хуй',
    'huy',
    'hui',
    'пизд',
    'pizd',
    'ебан',
    'eban',
    'jeban',
    'nahui',
    'нахуй',
    'долбо',
    'dolbo',
    'урод',
    'дебил',
    'debil',
    'idiot',
    'идиот',
    'nazi',
    'наци',
    'hitler',
    'гитлер',
    'terror',
    'террор',
    'жиһад',
    'jihad',
    'казино',
    'casino',
    'bet',
    'ставка',
    '18+',
    'xxx',
    'қотақ',
    'kotak',
    'сігу',
    'амыңды',
    'боқ ',
  ];

  static String? validate(String raw) {
    final nick = raw.trim();
    if (nick.length < minLength) return S.nickTooShort;
    if (nick.length > maxLength) return S.nickTooLong;
    if (!_allowed.hasMatch(nick)) return S.nickBadChars;
    if (_phone.hasMatch(nick)) return S.nickNoContacts;
    if (_contact.hasMatch(nick)) return S.nickNoContacts;

    final folded = _fold(nick);
    for (final word in _banned) {
      if (folded.contains(_fold(word))) return S.nickBanned;
    }
    return null;
  }

  /// Lowercases and collapses common letter/number substitutions
  /// (s3xyboy -> sexyboy) so trivial obfuscation does not pass.
  static String _fold(String value) => value
      .toLowerCase()
      .replaceAll('0', 'o')
      .replaceAll('1', 'i')
      .replaceAll('3', 'e')
      .replaceAll('4', 'a')
      .replaceAll('5', 's')
      .replaceAll('7', 't')
      .replaceAll('@', 'a')
      .replaceAll('\$', 's')
      .replaceAll('_', '');
}
