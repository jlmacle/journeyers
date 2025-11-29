import 'package:flutter/material.dart';

class ContextAnalysisDashboardPage extends StatefulWidget {
  const ContextAnalysisDashboardPage({super.key});

  @override
  State<ContextAnalysisDashboardPage> createState() => _ContextAnalysisDashboardPageState();
}

class _ContextAnalysisDashboardPageState extends State<ContextAnalysisDashboardPage> 
{
  @override
  Widget build(BuildContext context) 
  {

    FocusNode contextAnalysisDashboardFocusNode = FocusNode();

    return Expanded
    (
      child: Center
      (      
        child: Semantics
        (        
          header: true,
          headingLevel: 2,
          focusable: true,
          child: Focus
          (
            focusNode: contextAnalysisDashboardFocusNode,
            child: Center(child: Text('Context analysis dashboard'))
          )
        ),
      ),
    );
  }
}