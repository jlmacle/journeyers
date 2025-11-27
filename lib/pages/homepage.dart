import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_dismissable_rectangular_area.dart'; 
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/l10n/app_localizations.dart'; 
import 'package:journeyers/pages/context_analysis/context_analysis_new_session_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_dashboard_page.dart';

typedef NewVisibilityStatusCallback = void Function(bool newVisibilityStatus);



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  String? eol;  

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ContextAnalysisPage(),
    const GroupProblemSolvingPage(),
  ];

  @override
  Widget build(BuildContext context) {
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
              focused: true,
              focusable: true,
              header:true,
              headingLevel: 1,
              container: true,
              child: Focus(
                focusNode: appBarTitleFocusNode,
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[                    
                    Text(
                      AppLocalizations.of(context)?.appTitle ?? 'Default app title txt',              
                      style: TextStyle(fontSize: 22, fontFamily: 'Georgia',), //https://accessibility.uncg.edu/make-content-accessible/design-elements/
                    ),
                    Gap(5),
                    Text(
                      'What story will we leave$eol'
                      'for our loved ones to tell?',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),            
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // the height of the border
          child: Container(
            color: Color(0xFFBF9D3E), 
            height: 4.0, 
          ),
        ),
      ),
      
      body: _pages[_currentIndex], 

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
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Context analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Group problem-solving',
          ),
        ],
      ),
    );
  }
}

//---------------------------------------------------

class ContextAnalysisPage extends StatefulWidget {
  const ContextAnalysisPage({super.key});

  @override
  State<ContextAnalysisPage> createState() => _ContextAnalysisPageState();
}

class _ContextAnalysisPageState extends State<ContextAnalysisPage>  { 

  late bool _startMessageVisibilityStatus = true;
  bool isContextAnalysisSessionDataSaved = false;

  @override
  void initState() {
    super.initState();   
  }

    void _hideMessageArea()
    {
      setState(() {
        _startMessageVisibilityStatus = false;
      });
      saveStartMessageAcknowledgement();
    }

  @override
  Widget build(BuildContext context) { 

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
         children: [
          ContextAnalysisNewSessionPage(),
          if (_startMessageVisibilityStatus)
            CustomDismissableRectangularArea(buildContext:context, 
                message1: 'This is your first context analysis.', 
                message2: 'The dashboard will be displayed after data from the context analysis has been saved.',
                messagesColor: paleCyan, // from app_themes
                actionText:'Please click the message area to acknowledge.',
                actionTextColor: paleCyan, // from app_themes,
                areaBackgroundColor: navyBlue, // from app_themes
                setStateCallBack: _hideMessageArea),
                
          if (isContextAnalysisSessionDataSaved)
          ...[
            Divider(),
            ContextAnalysisDashboardPage()
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
