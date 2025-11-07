import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:journeyers/l10n/app_localizations.dart'; 




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ContextAnalysisPage(),
    const GroupProblemSolvingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);
    
    return Scaffold
    (
      
      appBar: AppBar  
      (
        // forceMaterialTransparency: true, // to avoid the tint effect in the background color when scrolling down
        centerTitle: true,
        toolbarHeight: 90.00,
        backgroundColor: appTheme.appBarTheme.backgroundColor,      
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)?.appTitle ?? 'Default app title txt',
              // 'Journeyers',
              style: TextStyle(fontSize: 22, fontFamily: 'Georgia',), //https://accessibility.uncg.edu/make-content-accessible/design-elements/
            ),
            Gap(5),
            Text(
              'What story will we leave\n'
              'for our loved ones to tell?',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // The height of the border
          child: Container(
            color: Color(0xFFBF9D3E), // The color of the border
            height: 4.0, // The thickness of the border
          ),
        ),
        
      ),
      
      body: _pages[_currentIndex], // Body

      bottomNavigationBar: BottomNavigationBar // BottomNavigationBar
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
    

    return Scaffold(
      body: Center(child: Text('Context analysis dashboard')),
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
    return Scaffold
    (
      body: Center(child: Text("Group problem-solving dashboard")),
    );
  }
}
