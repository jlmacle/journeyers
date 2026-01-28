import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/l10n/l10n_utils.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_language_switch.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_page.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart';

/// {@category Pages}
/// The homepage for the app.
class MyHomePage extends StatefulWidget 
{
  /// The language switch-related callback function for the parent widget.
  final ValueChanged<Locale> parentWidgetOnLanguageSelectedCallBackFunction;

  const MyHomePage
  ({
    super.key,
    required this.parentWidgetOnLanguageSelectedCallBackFunction,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  FocusNode appBarTitleFocusNode = FocusNode();

  int _currentIndex = 0;
  bool _areBottomNavigationItemsFocusable = true;

  String? eol;

  final GlobalKey<ContextAnalysisPageState> _contextAnalysisKey = GlobalKey();

  List<Widget> get _pages => 
  [
    ContextAnalysisPage
    (
      key: _contextAnalysisKey,
      parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability: 
      (bool boolValue) 
      {
        setState(() {_areBottomNavigationItemsFocusable = boolValue;});
        pu.printd("_areBottomNavigationItemsFocusable: $_areBottomNavigationItemsFocusable");
      }
      ),
    const GroupProblemSolvingPage(),
  ];

  // A method that updates the locale, if the language selected [languageName] has a language code different from the one of the current locale.
  // The logic cannot be moved in main.dart, as the context would be called without having being built yet.
  void _updateLocale(String languageName) 
  {
    // The locale related to the language selected
    String? localeLangCodeFromLangName = L10nLanguages.getLangCodeFromLangName(languageName: languageName);
    // The language code from the current locale
    String? localeLangCodeFromContext = (Localizations.localeOf(context)).languageCode;

    pu.printd("");
    pu.printd("localeLangCodeFromLangName: $localeLangCodeFromLangName");
    pu.printd("localeLangCodeFromContext: $localeLangCodeFromContext");

    if ((localeLangCodeFromLangName != localeLangCodeFromContext) & (localeLangCodeFromLangName != null)) 
    {
      widget.parentWidgetOnLanguageSelectedCallBackFunction(Locale(localeLangCodeFromLangName!));
    }
  }

  void _handleContextAnalysisTap()
  {
    pu.printd("_handleContextAnalysisTap");
    // re-pulling the preferences from the context analysis page
    _contextAnalysisKey.currentState?.getPreferences();
    
  }

  @override
  void dispose() 
  {
    appBarTitleFocusNode.dispose();
    super.dispose();
  }

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
                  AppLocalizations.of(context)?.appTitle ?? 'Default app title txt',
                  style: 
                  TextStyle
                  (
                    fontSize: 22,
                    fontFamily: 'Georgia',
                  ), //https://accessibility.uncg.edu/make-content-accessible/design-elements/
                ),
                Gap(5),
                Text
                (
                  AppLocalizations.of(context)?.appSubTitle ?? 'Default app subtitle txt',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        bottom: 
        PreferredSize
        (
          preferredSize: const Size.fromHeight(4.0), // the height of the border
          child: Container(color: Color(0xFFBF9D3E), height: 4.0),
        ),
      ),

      body: 
      Column
      (
        children: 
        [
          // Commented as not all translations are done
          // CustomLanguageSwitch(parentWidgetLanguageValueCallBackFunction: _updateLocale),
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
          
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) 
          {
            setState(() {_currentIndex = index;});
            switch(index)
            {
              case 0:
                _handleContextAnalysisTap();
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
