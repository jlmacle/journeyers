import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_dismissable_rectangular_area.dart';
// import 'package:journeyers/common_widgets/interaction_and_inputs/custom_language_switcher.dart';
import 'package:journeyers/core/utils/l10n/l10n_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart'; 
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/l10n/app_localizations.dart'; 
import 'package:journeyers/pages/context_analysis/context_analysis_new_session_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef NewVisibilityStatusCallback = void Function(bool newVisibilityStatus);



class MyHomePage extends StatefulWidget 
{
  final void Function(Locale) setLocale; 

  const MyHomePage
  (
    {
      super.key,
      required this.setLocale
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

  /// A method that updates the locale, if the language selected [languageName] has a language code different from the one of the current locale
  /// Parameters: - [languageName] 
  void _updateLocale(String languageName) 
  {
    // The related to the language selected
    String? localeLangCodeFromLangName = L10nLanguages.getLangCodeFromLangName(languageName);   
    // The language code from the current locale
    String? localeLangCodeFromContext = (Localizations.localeOf(context)).languageCode;

    printd("");
    printd("localeLangCodeFromLangName: $localeLangCodeFromLangName");    
    printd("localeLangCodeFromContext: $localeLangCodeFromContext");   
         
    if ((localeLangCodeFromLangName != localeLangCodeFromContext) & (localeLangCodeFromLangName != null)) 
    {
      widget.setLocale(Locale(localeLangCodeFromLangName!)); 
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
        // forceMaterialTransparency: true, // to avoid the tint effect in the background color when scrolling down
        
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
        // CustomLanguageSwitcher(onLanguageChanged: _updateLocale),
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

//---------------------------------------------------

class ContextAnalysisPage extends StatefulWidget 
{
  const ContextAnalysisPage({super.key});

  @override
  State<ContextAnalysisPage> createState() => _ContextAnalysisPageState();
}

class _ContextAnalysisPageState extends State<ContextAnalysisPage>  
{ 
  bool _preferencesLoading = true;
  late bool? _isStartMessageAcknowledged;  
  bool isContextAnalysisSessionDataSaved = false;

  _getPreferences() async{
    _isStartMessageAcknowledged = await isStartMessageAcknowledged();
    if (mounted)
    {
      setState(() {  
        _preferencesLoading = false;
      });
    }

  }

  @override
  void initState() 
  { 
    super.initState();
    _getPreferences();     
  }

    void _hideMessageArea()
    {
      setState(() {
        saveStartMessageAcknowledgement();
        _isStartMessageAcknowledged = true;
      });
      
    }

  void resetAcknowledgement() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('startMessageAcknowledged', false);
  }

  @override
  Widget build(BuildContext context) 
  { 

    FocusNode dismissableMsgFocusNode = FocusNode();    

    return Scaffold
    (
      body: 
      Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: 
        [
        if (_preferencesLoading)
          Center(child: CircularProgressIndicator())
        else
          ...[
            ContextAnalysisNewSessionPage(),
            if (!(_isStartMessageAcknowledged!))
              Semantics
              (
                focusable: true,
                focused: true,
                child: Focus
                (
                  focusNode: dismissableMsgFocusNode,
                  child: 
                  CustomDismissableRectangularArea
                  (
                    buildContext:context, 
                    message1: 'This is your first context analysis.', 
                    message2: 'The dashboard will be displayed after data from the context analysis has been saved.',
                    messagesColor: paleCyan, // from app_themes
                    actionText:'Please click the message area to acknowledge.',
                    actionTextColor: paleCyan, // from app_themes,
                    areaBackgroundColor: navyBlue, // from app_themes
                    setStateCallBack: _hideMessageArea
                  )
                ),
              ),                
            if (isContextAnalysisSessionDataSaved)
            ...[
              Divider(),
              ContextAnalysisDashboardPage()
            ],
            // ElevatedButton(onPressed: resetAcknowledgement, child: Text('Reset acknowledgement'))
          ]
        // TextButton(
        //   onPressed: () {
        //     // This dumps the Semantics Tree's structure and properties to the console.
        //     debugDumpSemanticsTree(); 
        //   },
        //     child: const Text('Dump Semantics'),
        //   )
        ],
      ),
    );
  }
}


//---------------------------------------------------

class GroupProblemSolvingPage extends StatefulWidget 
{
  const GroupProblemSolvingPage({super.key});
  @override
  State<GroupProblemSolvingPage> createState() => _GroupProblemSolvingPageState();
}


class _GroupProblemSolvingPageState extends State<GroupProblemSolvingPage> 
{   
  @override
  Widget build(BuildContext context) 
  {
    
    FocusNode groupProblemSolvingDashboardFocusNode = FocusNode();

    return Scaffold
    (
      body: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: 
        [
          Semantics
          (        
            header: true,
            headingLevel: 2,
            focusable: true,            
            child: Focus
            (
              focusNode: groupProblemSolvingDashboardFocusNode,
              child: Center(child: Text("Group problem-solving dashboard")),
            ),
          ),
        ],
      )
    );
  }
}
