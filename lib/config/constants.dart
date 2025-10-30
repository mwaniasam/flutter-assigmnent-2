class AppConstants {
  // App Information
  static const String appName = 'BookSwap';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Swap Your Books\nWith Other Students';
  
  // Validation
  static const int minBookTitleLength = 2;
  static const int maxBookTitleLength = 100;
  static const int maxMessageLength = 500;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String emptyFieldError = 'This field cannot be empty';
}
