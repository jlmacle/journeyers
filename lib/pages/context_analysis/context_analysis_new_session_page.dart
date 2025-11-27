import 'package:flutter/material.dart';

class ContextAnalysisNewSessionPage extends StatefulWidget {
  const ContextAnalysisNewSessionPage({super.key});

  @override
  State<ContextAnalysisNewSessionPage> createState() => _ContextAnalysisNewSessionPageState();
}

class _ContextAnalysisNewSessionPageState extends State<ContextAnalysisNewSessionPage> {
  @override
  Widget build(BuildContext context) {

  FocusNode contextAnalysisNewSessionFocusNode = FocusNode();

  return SizedBox(
    height: 100,
    child: Semantics
    (        
      header: true,
      headingLevel: 2,
      focusable: true,
      child: Focus
      (
        focusNode: contextAnalysisNewSessionFocusNode,
        child: Center(child: Text('Context analysis new session'))
      )
    ),
  );
  }
}