class AppFontSize {
  static final AppFontSize _instance = AppFontSize._internal();

  factory AppFontSize() {
    return _instance;
  }

  AppFontSize._internal();

  static const String appFontOpenSans = 'eca_mediuam';
  static const double textUltraSmall = 8.0;
  static const double textSuperSmall = 10.0;
  static const double textSmall = 12.0;
  static const double textMedium = 14.0;
  static const double textLarge = 16.0;
  static const double textExtraLarge = 18.0;
  static const double textSuperLarge = 20.0;
  static const double textUltraLarge = 24.0;
  static const double textExtraUltraLarge = 28.0;
}
