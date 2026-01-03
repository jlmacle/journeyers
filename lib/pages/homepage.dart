import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';

import 'package:journeyers/common_widgets/interaction_and_inputs/custom_language_switch.dart';
import 'package:journeyers/core/utils/l10n/l10n_utils.dart';
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
  (
    {
      super.key,
      required this.parentWidgetOnLanguageSelectedCallBackFunction
    }
  );
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  String? eol;  

  int _currentIndex = 0;  

  final List<Widget> _pages = 
  [
    const ContextAnalysisPage(),
    const GroupProblemSolvingPage(),
  ];

  // A method that updates the locale, if the language selected [languageName] has a language code different from the one of the current locale
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

  @override
  Widget build(BuildContext context) 
  {
    final ThemeData appTheme = Theme.of(context);

    FocusNode appBarTitleFocusNode = FocusNode();

    if (kIsWeb) 
    {
    eol = '\n';
    }
    else
    {
      eol = Platform.lineTerminator; // The use of Platform is not portable on the web
    } 
    
    return Scaffold
    (
      
      appBar: AppBar  
      (
       
        centerTitle: true,
        toolbarHeight: 90.00,
        backgroundColor: appTheme.appBarTheme.backgroundColor,           
        title: Semantics
        (
            focusable: true,           
            container: true,
            child: Focus(
              focusNode: appBarTitleFocusNode,
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>
                [                    
                  Text
                  (
                    AppLocalizations.of(context)?.appTitle ?? 'Default app title txt',              
                    style: TextStyle(fontSize: 22, fontFamily: 'Georgia',), //https://accessibility.uncg.edu/make-content-accessible/design-elements/
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
        bottom: PreferredSize
        (
          preferredSize: const Size.fromHeight(4.0), // the height of the border
          child: Container
          (
            color: Color(0xFFBF9D3E), 
            height: 4.0, 
          ),
        ),
      ),
      
      body: Column
      (children: 
      [
        // CustomLanguageSwitch(parentWidgetLanguageValueCallBackFunction: _updateLocale),
        Expanded(child:  _pages[_currentIndex])       
      ]
      ), 

      bottomNavigationBar: BottomNavigationBar 
      (
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) 
        {
          setState(() 
          {
            _currentIndex = index;
          });
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
    );
  }
}





