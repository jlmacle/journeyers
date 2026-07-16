import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_localizations/flutter_localizations.dart"; // https://docs.flutter.dev/ui/internationalization

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/pages/homepage.dart";

void main() async
{
  // To help debug the layout
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  // On mobile: keeping the app in portrait mode for usability
  if (Platform.isAndroid || Platform.isIOS)
  {
    await SystemChrome.setPreferredOrientations
    ([
      DeviceOrientation.portraitUp,   
      DeviceOrientation.portraitDown
    ]);
  }
  
  runApp(const GPSapp());
}

class GPSapp extends StatefulWidget 
{
  const GPSapp({super.key});
  @override
  State<GPSapp> createState() => _GPSappState();
}

class _GPSappState extends State<GPSapp> 
{
  // to wait on the file names loading
  var areFileNamesLoading = true;

  @override
  void initState() {
    super.initState();
    
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSapp");

    // Getting the stored file names at start on mobile
    if (Platform.isAndroid || Platform.isIOS)
    {
      du.getStoredFileNamesOnMobile();
      setState(() {
        areFileNamesLoading = false;
      });
    }   
    // no file names to load on desktop
    else
    {
      areFileNamesLoading = false;
    } 
    
  }
  // ─── LOCALE related data and methods ───────────────────────────────────────

  // Temporarily defining English as the locale
  // TODO: to get eventually the value from user preferences
  Locale? _currentLocale = const Locale("en");
  // To get the locale from the platform
  // Locale? _currentLocale = PlatformDispatcher.instance.locale;

  // Method used to set a new locale value
  void _setLocale(Locale newLocale) 
  {
    if (newLocale != _currentLocale) 
    {
      setState(() {        
        _currentLocale = newLocale;
        if (runtimeDataDebug) pu.printd("Runtime Data: GPSapp: _setLocale: new locale: $newLocale");
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
      localizationsDelegates: const
      [
        AppLocalizations.delegate,

        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // "By default only the American English locale is supported. 
      // Apps should configure this list to match the locales they support."
      supportedLocales: const
      [
        Locale("en"), // English
        Locale("fr"), // French
      ],

      locale: _currentLocale, // to be able to swap translated strings,
      home: 
      SafeArea
      (
        child: 
        (areFileNamesLoading)
        // Waiting on the stored file names
        ?
          const CircularProgressIndicator()
        :
        // Loading the homepage when done
          HomePage
          (
            onLanguageSelectedCallbackFunction: _setLocale,
          ),
      ),
    );
  }
}
