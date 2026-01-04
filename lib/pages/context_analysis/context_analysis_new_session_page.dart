import 'package:flutter/material.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_context_form_page.dart';

/// {@category Pages}
/// {@category Context analysis}
/// The page for a new session of context analysis.
class ContextAnalysisNewSessionPage extends StatefulWidget 
{
  const ContextAnalysisNewSessionPage({super.key});

  @override
  State<ContextAnalysisNewSessionPage> createState() => _ContextAnalysisNewSessionPageState();
}

class _ContextAnalysisNewSessionPageState extends State<ContextAnalysisNewSessionPage> 
{

  @override
  Widget build(BuildContext context) 
  {

    FocusNode contextAnalysisNewSessionFocusNode = FocusNode();

    return 
    Expanded
    (
      child: 
      Padding
      (
        padding: const EdgeInsets.all(15.0),
        child: 
        Focus
        (
          focusNode: contextAnalysisNewSessionFocusNode,
          child: ContextAnalysisContextFormPage()
        ),
      ),
    );
  }
}