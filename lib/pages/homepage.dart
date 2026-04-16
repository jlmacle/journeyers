import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/utils/generic/l10n/l10n_utils.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart';

/// {@category Pages}
/// The homepage for the app.
class MyHomePage extends StatefulWidget 
{
  /// The language switch-related callback function for the parent widget.
  final ValueChanged<Locale> parentOnLanguageSelectedCallBackFunction;

  const MyHomePage
  ({
    super.key,
    required this.parentOnLanguageSelectedCallBackFunction,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  //**************** GLOBAL KEYS related data ****************//
  final GlobalKey<CAPageState> _caPageKey = GlobalKey();

  //**************** BOTTOM NAVIGATION BAR related data and methods ****************//
  int _currentIndex = 0;
  bool _areBottomNavigationItemsFocusable = true;

  // Getter for the context analyses page and for the group problem solvings page
  List<Widget> get _pages => 
  [
    CAPage
    (
      key: _caPageKey,
      parentCallbackFunctionToSetFocusabilityOfBottomBarItems: 
      (bool boolValue) 
      {
        // Switches the focusability of the bottom bar items
        setState(() {_areBottomNavigationItemsFocusable = boolValue;});
        if (accessibilityDebug) pu.printd("Accessibility: _areBottomNavigationItemsFocusable: $_areBottomNavigationItemsFocusable");
      }
      ),
    const GPSPage(),
  ];

  // TODO: to check if still relevant
  // Method used to re-pull the preferences from the context analysis page
  void _handleCATap()
  {
    // re-pulling the preferences from the context analysis page
    _caPageKey.currentState?.getPreferences();    
  }
 
  //**************** LOCALE related method ****************//
  // A method that updates the locale, if the language selected [languageName] has a language code different from the one of the current locale.
  // The logic cannot be moved in main.dart, as the context would be called without having being built yet.
  void _updateLocale(String languageName) 
  {
    // The locale related to the language selected
    String? localeLangCodeFromLangName = L10nUtils.getLangCodeFromLangName(languageName: languageName);
    // The language code from the current locale
    String? localeLangCodeFromContext = (Localizations.localeOf(context)).languageCode;

    if (preferencesDebug) pu.printd("Preferences");
    if (preferencesDebug) pu.printd("Preferences: localeLangCodeFromLangName: $localeLangCodeFromLangName");
    if (preferencesDebug) pu.printd("Preferences: localeLangCodeFromContext: $localeLangCodeFromContext");

    if ((localeLangCodeFromLangName != localeLangCodeFromContext) & (localeLangCodeFromLangName != null)) 
    {
      widget.parentOnLanguageSelectedCallBackFunction(Locale(localeLangCodeFromLangName!));
    }
  }

  //**************** FOCUS NODE related data and methods ****************//
  FocusNode appBarTitleFocusNode = .new();

  @override
  void dispose() 
  {
    appBarTitleFocusNode.dispose();
    super.dispose();
  }

  // TODO: cross-platform end of line
  String? eol;

  @override
  Widget build(BuildContext context) 
  {
    if (kIsWeb) 
    {
      eol = '\n';
    } 
    else 
    {
      eol = Platform.lineTerminator; // The use of Platform is not portable on the web
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
        title: 
        Semantics
        (
          focusable: true,
          // container: true, // kept (TODO: further screen reader testing)
          child: 
          Focus
          (
            focusNode: appBarTitleFocusNode,
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
      Column
      (
        children: 
        [
          // Commented as not all translations are done
          // CustomLanguageSwitch(parentLanguageValueCallBackFunction: _updateLocale),
          Expanded(child: _pages[_currentIndex])
        ],
      ),


      bottomNavigationBar: 
      // Used to remove focus to the items when the expansion tiles are expanded (context analysis only as of 26/01/13)
      // Goal: to be able to scroll down the questions using tab navigation only
      ExcludeFocus(
        excluding: !_areBottomNavigationItemsFocusable,
        child: 
        BottomNavigationBar
        (
          
          backgroundColor: navyBlue,
          currentIndex: _currentIndex,
          onTap: (index) 
          {
            setState(() {_currentIndex = index;});
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
              icon: Icon(Icons.group),
              label: 'Group problem-solving',
            ),
          ],
        ),
      ),
    );
  }
}
