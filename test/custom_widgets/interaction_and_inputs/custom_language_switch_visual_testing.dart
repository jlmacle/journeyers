// Line for automated processing
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_language_switch_visual_testing.dart -d chrome
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_language_switch_visual_testing.dart -d linux
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_language_switch_visual_testing.dart -d macos
// flutter run -t ./test/custom_widgets/interaction_and_inputs/custom_language_switch_visual_testing.dart -d windows
// Line for automated processing

// "When locales specify a script code or country code,
// a base locale (without the script code or country code) should exist as the fallback."
// flutter gen-l10n

import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/l10n/l10n_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_language_switch.dart';
import 'package:journeyers/l10n/app_localizations.dart';

// Utility class
final PrintUtils pu = PrintUtils();

void main() 
{
  WidgetsFlutterBinding.ensureInitialized(); // was not necessary on Windows, was necessary for macos
  runApp(const MyTestingApp());
}

class MyTestingApp extends StatefulWidget 
{
  const MyTestingApp({super.key});
  @override
  State<MyTestingApp> createState() => _MyTestingAppState();
}

class _MyTestingAppState extends State<MyTestingApp> 
{
  Locale? _currentLocale = Locale('en'); // TODO: to get eventually the value from user preferences

  void _setLocale(Locale newLocale) 
  {
    if (newLocale != _currentLocale) 
    {
      setState(() 
      {
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
      theme: appTheme,

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      locale: _currentLocale, // to be able to swap translated strings

      home: HomePage(setLocale: _setLocale),
    );
  }
}
//---------------------------------------------------

class HomePage extends StatefulWidget 
{
  final void Function(Locale) setLocale;

  const HomePage({super.key, required this.setLocale});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> 
{
  /// A method that updates the locale, if the language selected [languageName] has a language code different from the one of the current locale
  /// Parameters: - [languageName]
  void _updateLocale(String languageName) 
  {
    // The related to the language selected
    String? localeLangCodeFromLangName = L10nLanguages.getLangCodeFromLangName(languageName: languageName);
    // The language code from the current locale
    String? localeLangCodeFromContext = (Localizations.localeOf(context)).languageCode;

    pu.printd("");
    pu.printd("localeLangCodeFromLangName: $localeLangCodeFromLangName");
    pu.printd("localeLangCodeFromContext: $localeLangCodeFromContext");

    if ((localeLangCodeFromLangName != localeLangCodeFromContext) & (localeLangCodeFromLangName != null))
      {widget.setLocale(Locale(localeLangCodeFromLangName!));}
  }

  @override
  Widget build(BuildContext context) 
  {
    final appLocalization = AppLocalizations.of(context);

    FocusNode appBarTitleFocusNode = FocusNode();

    return 
    Scaffold
    (
      appBar: 
      AppBar
      (
        title: 
        Semantics
        (
          focusable: true,
          child: 
          Focus
          (
            focusNode: appBarTitleFocusNode,
            child: Text(appLocalization?.appTitle ?? 'Default app title txt'),
          ),
        ),
      ),
      body: 
      Center
      (
        child: 
        Column
        (
          children: 
          [
            CustomLanguageSwitch
            (
              parentWidgetLanguageValueCallBackFunction: _updateLocale,
            ),
          ],
        ),
      ),
    );
  }
}
