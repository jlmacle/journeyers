import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

//**************** UTILITY CLASS ****************//
PrintUtils pu = PrintUtils();

// StatefulWidget necessary for overriding dispose() 

/// {@category Pages}
/// {@category Context analysis}
/// The title for the context analysis.
class ContextAnalysisTitle extends StatefulWidget 
{
  /// A callback function called after editing the title is complete.
  final ValueChanged<String> parentWidgetCallbackFunctionOnEditingComplete;

  const ContextAnalysisTitle
  ({
    super.key,
    required this.parentWidgetCallbackFunctionOnEditingComplete
  });

  @override
  State<ContextAnalysisTitle> createState() => _ContextAnalysisTitleState();
}

class _ContextAnalysisTitleState extends State<ContextAnalysisTitle> 
{

  @override
  Widget build(BuildContext context) {
    return 
    Padding(
      padding: EdgeInsets.only(top: 16.0, bottom:16 ),
      child: TextField
      (
        textAlign: TextAlign.center,
        style: analysisTitleStyle,
        decoration: InputDecoration
        (
          hint: Center(child: Text("Please enter a title for this analysis.")),
          hintStyle: analysisTitleStyle,                    
        ),
        maxLength: 150,
        onSubmitted: widget.parentWidgetCallbackFunctionOnEditingComplete,
      ),
    );
  }
}