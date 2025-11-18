import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // https://docs.flutter.dev/ui/internationalization
// import 'package:flutter/rendering.dart'; // https://api.flutter.dev/flutter/rendering/

import 'app_themes.dart';
import './pages/homepage.dart';
import 'l10n/app_localizations.dart';

void main() {
  // To help debug the layout
  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // To visualize the semantics tree
      // showSemanticsDebugger: true,
      theme: appTheme, 
      localizationsDelegates: [
        AppLocalizations.delegate,

        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('fr'), // Spanish
      ],     
      home: SafeArea(child: MyHomePage()),
    );
  }
}

