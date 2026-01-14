import 'package:flutter/material.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_context_form_page.dart';

/// {@category Pages}
/// {@category Context analysis}
/// The page for a new session of context analysis.

class ContextAnalysisNewSessionPage extends StatefulWidget
{
  /// An "expansion tile expanded/folded"-related callback function for the parent widget, to enhance the tab navigation.
  final ValueChanged<bool> parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability;

  /// A placeholder void callback function with a bool parameter
  static void placeHolderFunctionBool(bool value) {}

  const ContextAnalysisNewSessionPage({
    super.key,
    this.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability = placeHolderFunctionBool
    });

  @override
  State<ContextAnalysisNewSessionPage> createState() => _ContextAnalysisNewSessionPageState();

}

class _ContextAnalysisNewSessionPageState extends State<ContextAnalysisNewSessionPage>
{

  FocusNode contextAnalysisNewSessionFocusNode = FocusNode();

  @override
  void dispose() {
    contextAnalysisNewSessionFocusNode.dispose();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) 
  {
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
          child: ContextAnalysisContextFormPage(parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability: widget.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability),
        ),
      ),
    );
  }
}
