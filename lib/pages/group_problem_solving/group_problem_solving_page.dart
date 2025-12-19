import 'package:flutter/material.dart';

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
