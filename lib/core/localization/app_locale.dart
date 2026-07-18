/// The three supported UI languages. Kazakh is the default; the whole app
/// is centralized in `core/constants/strings.dart` so this is the only
/// place that needs to change to add another language.
enum AppLocale {
  kk('kk', 'Қазақша'),
  ru('ru', 'Русский'),
  en('en', 'English');

  const AppLocale(this.code, this.label);
  final String code;
  final String label;

  static AppLocale fromCode(String? code) =>
      values.firstWhere((l) => l.code == code, orElse: () => AppLocale.kk);
}
