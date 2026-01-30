/// Constantes de l'application EggGo
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'EggGo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Livraison d\'œufs frais au Cameroun';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';
  static const String onboardingKey = 'onboarding_complete';

  // Validation
  static const int minPasswordLength = 6;
  static const int phoneNumberLength = 9; // Format camerounais: 6XXXXXXXX

  // Pagination
  static const int defaultPageSize = 20;

  // Images
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';

  // Currency
  static const String currency = 'FCFA';
  static const String currencySymbol = 'XAF';

  // Contact
  static const String supportPhone = '+237 6XX XXX XXX';
  static const String supportEmail = 'support@egggo.cm';
}
