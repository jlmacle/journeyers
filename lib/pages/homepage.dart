import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/l10n/l10n_utils.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_language_switch.dart';

/// {@category Pages}
/// The homepage for the app.
class HomePage extends StatefulWidget 
{
  /// The language switch-related callback function for the parent widget.
  final ValueChanged<Locale> onLanguageSelectedMainCallbackFunction;

  const HomePage
  ({
    super.key,
    required this.onLanguageSelectedMainCallbackFunction,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> 
{
  // ─── BOTTOM NAVIGATION BAR related data and methods ───────────────────────────────────────
  int _bottomNavigationItemCurrentIndex = 0;
  bool _bottomNavigationItemsFocusable = true;

  // Getter for the context analyses page and for the group problem solvings page
  List<Widget> get _pages => 
  [
    CAPage
    (
      key: caPageKey,
      homepageCallbackFunctionToSetFocusabilityOfBottomBarItems: 
      (bool boolValue) 
      {
        // Switches the focusability of the bottom bar items
        setState(() {_bottomNavigationItemsFocusable = boolValue;});
        if (accessibilityDebug) pu.printd("Accessibility: HomePage: _bottomNavigationItemsFocusable: $_bottomNavigationItemsFocusable");
      }
    ),

    GPSPage
    (
      key: gpsPageKey
    ),
  ];

  // TODO: to check if still relevant
  // Method used to re-pull the preferences from the context analysis page
  void _handleCATap()
  {
    // re-pulling the preferences from the context analysis page
    caPageKey.currentState?.getRuntimeData();    
  }
 
  // ─── LOCALE related method ───────────────────────────────────────
  // A method that updates the locale, if the language selected [languageName] has a language code different from the one of the current locale.
  // The logic cannot be moved in main.dart, as the context would be called without having being built yet.
  void _updateLocale(String languageName) 
  {
    // The locale related to the language selected
    String? localeLangCodeFromLangName = L10nUtils.getLangCodeFromLangName(languageName: languageName);
    // The language code from the current locale
    String? localeLangCodeFromContext = (Localizations.localeOf(context)).languageCode;

    if (runtimeDataDebug) pu.printd("Runtime Data: localeLangCodeFromLangName: $localeLangCodeFromLangName");
    if (runtimeDataDebug) pu.printd("Runtime Data: localeLangCodeFromContext: $localeLangCodeFromContext");

    if ((localeLangCodeFromLangName != localeLangCodeFromContext) & (localeLangCodeFromLangName != null)) 
    {
      widget.onLanguageSelectedMainCallbackFunction(Locale(localeLangCodeFromLangName!));
    }
  }

  // ─── FOCUS NODE related data and methods ───────────────────────────────────────
  final FocusNode _appBarTitleFocusNode = .new();

  @override
  void dispose() 
  {
    _appBarTitleFocusNode.dispose();
    super.dispose();
  }

  // TODO: cross-platform end of line
  String? _eol;

  @override
  Widget build(BuildContext context) 
  {
    if (kIsWeb) 
    {
      _eol = '\n';
    } 
    else 
    {
      _eol = Platform.lineTerminator; // The use of Platform is not portable on the web
    }
    
    return 
    Scaffold
    (
      appBar: 
      AppBar
      (
        centerTitle: true,
        toolbarHeight: 90.00,
        backgroundColor: appTheme.appBarTheme.backgroundColor,
        systemOverlayStyle: appTheme.appBarTheme.systemOverlayStyle,
        title: 
        Semantics
        (
          focusable: true,
          // container: true, // kept (TODO: further screen reader testing)
          child: 
          Focus
          (
            focusNode: _appBarTitleFocusNode,
            child: 
            Column
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>
              [
                Text
                (
                  AppLocalizations.of(context)?.appTitle ?? 'Issue with the application title text',
                  style: 
                  const TextStyle
                  (
                    fontSize: 22,
                    fontFamily: 'Georgia',
                  ), //https://accessibility.uncg.edu/make-content-accessible/design-elements/
                ),
                const Gap(5),
                Text
                (
                  AppLocalizations.of(context)?.appSubTitle ?? 'Issue with the application subtitle text',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),

      body: 
      SafeArea
      (
        child:
          Column
          (
            children: 
            [
              // Commented as not all translations are done
              // CustomLanguageSwitch(onLanguageSelectedHomePageCallbackFunction: _updateLocale),
              Expanded(child: _pages[_bottomNavigationItemCurrentIndex])
            ],
          ),
      ),


      bottomNavigationBar: 
      // Used to remove focus to the items when the expansion tiles are expanded (context analysis only as of 26/01/13)
      // Goal: to be able to scroll down the questions using tab navigation only
      ExcludeFocus(
        excluding: !_bottomNavigationItemsFocusable,
        child: 
        BottomNavigationBar
        (
          
          backgroundColor: navyBlue,
          currentIndex: _bottomNavigationItemCurrentIndex,
          onTap: (index) 
          {
            setState(() {_bottomNavigationItemCurrentIndex = index;});
            switch(index)
            {
              case 0:
                _handleCATap();
            }
          },
          items: const 
          [
            BottomNavigationBarItem
            (
              icon: Icon(Icons.task_alt),
              label: 'Context analysis',
            ),
            BottomNavigationBarItem
            (
              key: Key('homepage-bottom-navigation-bar-item-gps'),
              icon: Icon(Icons.group),
              label: 'Group problem-solving',
            ),
          ],
        ),
      ),
    );
  }
}
