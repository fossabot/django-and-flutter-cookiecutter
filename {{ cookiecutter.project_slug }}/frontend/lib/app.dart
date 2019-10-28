import 'package:flutter_drf/localization.dart';
import 'package:flutter_drf/models/user_model.dart';
import 'package:flutter_drf/pages/home_page.dart';
import 'package:flutter_drf/pages/signin_page.dart';
import 'package:flutter_drf/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scoped_model/scoped_model.dart';

class ScopedModelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.grey[900],
    ));
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: MaterialApp(
        title: ScopedModelLocalizations().appTitle,
        theme: darkTheme,
        localizationsDelegates: [
          ScopedModelLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', 'US'), // English
        ],
        routes: {
          '/': (context) => HomeScreen(),
          '/signin': (context) => SigninPage()
        },
      ),
    );
  }
}
