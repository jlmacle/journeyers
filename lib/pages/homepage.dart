import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:gap/gap.dart';

import '../l10n/app_localizations.dart'; 


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  String eol = Platform.lineTerminator;

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ContextAnalysisPage(),
    const GroupProblemSolvingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);

    FocusNode appBarTitleFocusNode = FocusNode();
    
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
////////////////////////////////////////////////////

class ContextAnalysisPage extends StatefulWidget {
  const ContextAnalysisPage({super.key});

  @override
  State<ContextAnalysisPage> createState() => _ContextAnalysisPageState();
}

class _ContextAnalysisPageState extends State<ContextAnalysisPage>  { 

  @override
  void initState() {
    super.initState();   
  }

 

  @override
  Widget build(BuildContext context) {
    
    FocusNode contextAnalysisDashboard = FocusNode();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics
          (        
            header: true,
            headingLevel: 2,
            focusable: true,
            role: SemanticsRole.main,
            child: Focus
            (
              focusNode: contextAnalysisDashboard,
              child: Center(child: Text('Context analysis dashboard'))
            )
          ),
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


////////////////////////////////////////////////////

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
    FocusNode groupProblemSolvingDashboard = FocusNode();

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
            role: SemanticsRole.main,
            child: Focus
            (
              focusNode: groupProblemSolvingDashboard,
              child: Center(child: Text("Group problem-solving dashboard")),
            ),
          ),
        ],
      )
    );
  }
}
