enum Language {
  uzbekLatin('uz'),
  uzbekCyrillic('uz-Cyrl'),
  russian('ru'),
  kazakh('kk'),
  kyrgyz('ky'),
  tajik('tg'),
  turkmen('tk'),
  azerbaijani('az'),
  armenian('hy'),
  georgian('ka'),
  ukrainian('uk'),
  english('en'),
  ozbekCyrillic('oz');

  const Language(this.locale);

  final String locale;

  /// Convert locale string to Language enum
  static Language fromLocale(String locale) {
    return Language.values.firstWhere(
      (lang) => lang.locale.toLowerCase() == locale.toLowerCase(),
      orElse: () => Language.uzbekLatin,
    );
  }
}
