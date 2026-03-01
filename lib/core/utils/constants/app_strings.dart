class AppStrings {
  static final AppStrings _instance = AppStrings._internal();

  factory AppStrings() {
    return _instance;
  }

  AppStrings._internal();

  static const dbName = "socialseed";
  static const cloudName = "db33qrr6s";

  //network repository
  static String somethingWentWrong = "Something went wrong";
  static String authError = "Unauthorized";
  static String checkInternet = "Check your internet connection";

  static String recent = "RECENT";
  static String keyWord = "KEYWORD";
  static String helpTogether = "Let\'s help together in this";

  static String loginTypeSelectionDescription =
      'We provide school administration faster and easyers. It makes communication between parents, teachers, and students faster and more effective.';
  static String chooseCategory = "Choose your category";

  static String welcomeBack = "Welcome Back!";
  static String signInTo = "Sign in to Socialseed";
  static String forgotPassword = "Forgot Password?";

  static String click = " Click Here";
}
