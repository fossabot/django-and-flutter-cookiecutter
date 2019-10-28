import 'dart:async';

import 'package:flutter/material.dart';

class ScopedModelLocalizations {
  static ScopedModelLocalizations of(BuildContext context) {
    return Localizations.of<ScopedModelLocalizations>(context, ScopedModelLocalizations);
  }

  String get appTitle => 'Flutter DRF';

  String get welcometext => 'Welcome to Flutter Django Rest Framework';

  String get welcome => 'Welcome!';

  String get existing => 'Existing';

  String get textnew => 'New';

  String get emailaddress => 'Email Address';

  String get password => 'Password';

  String get login => 'Login';

  String get forgotpassword => 'Forgot Password?';

  String get or => 'Or';

  String get name => 'Name';

  String get confirmation => 'Confirmation';

  String get signup => 'Sign Up';

  String get emptyvalue => 'This cannot be empty';

  String get validemail => 'Please enter a valid email';

  String get validpassword => 'Passwords should be at least 6 characters';

  String get matchpassword => 'Passwords do not match';

  String get cancel => 'Cancel';

  String get checkconnection => 'Offline. Please check connection.';

  String get sendemail => 'Send email';

  String get checkemail => 'Please check your email for instructions to reset your password';
}

class ScopedModelLocalizationsDelegate extends LocalizationsDelegate<ScopedModelLocalizations> {
  @override
  Future<ScopedModelLocalizations> load(Locale locale) => Future(() => ScopedModelLocalizations());

  @override
  bool shouldReload(ScopedModelLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) => locale.languageCode.toLowerCase().contains('en');
}
