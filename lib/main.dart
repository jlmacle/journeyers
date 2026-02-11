import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // https://docs.flutter.dev/ui/internationalization
// import 'package:flutter/rendering.dart'; // https://api.flutter.dev/flutter/rendering/

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/homepage.dart';

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
  // Utility class
  PrintUtils pu = PrintUtils();

  // Temporarily defining English as the locale
  // TODO: to get eventually the value from user preferences
  Locale? _currentLocale = Locale('en');

  void _setLocale(Locale newLocale) 
  {
    if (newLocale != _currentLocale) 
    {
      setState(() {
        pu.printd("SetState: _currentLocale: $newLocale");
        _currentLocale = newLocale;
      });
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return 
    MaterialApp
    (
      // To visualize the semantics tree
      // showSemanticsDebugger: true,
      debugShowCheckedModeBanner: false,
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
      // https://api.flutter.dev/flutter/widgets/SafeArea-class.html
      home: 
      SafeArea
      (
        child: 
        MyHomePage
        (
          parentWidgetOnLanguageSelectedCallBackFunction: _setLocale,
        ),
      ),
    );
  }
}
