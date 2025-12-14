import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // https://docs.flutter.dev/ui/internationalization
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
// import 'package:flutter/rendering.dart'; // https://api.flutter.dev/flutter/rendering/

import 'app_themes.dart';
import './pages/homepage.dart';
import 'l10n/app_localizations.dart';

void main() 
{
  // To help debug the layout
  // debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget 
{
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> 
{
  Locale? _currentLocale = Locale('en'); // TODO: to get eventually the value from user preferences

   void _setLocale(Locale newLocale) 
  {
    if (newLocale != _currentLocale)
    {
      setState
      (
        () 
        {
          printd("SetState: _currentLocale: $newLocale");
          _currentLocale = newLocale;
        }
      );
    }
    
  }

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      // To visualize the semantics tree
      // showSemanticsDebugger: true,
      theme: appTheme, 
      localizationsDelegates: 
      [
        AppLocalizations.delegate,

        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: 
      [
        Locale('en'), // English
        Locale('fr'), // French
      ],     

      locale: _currentLocale, // to be able to swap translated strings,

      home: SafeArea(child: MyHomePage(setLocale: _setLocale)),
    );
  }
}

