import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';

/// {@category Context analysis}
/// A widget used for the title of the context analysis.
class CATitle extends StatefulWidget 
{
  /// A callback function called after editing the title is complete.
  final ValueChanged<String> onAnalysisTitleUpdatedCallbackFunction;

  const CATitle
  ({
    super.key,
    required this.onAnalysisTitleUpdatedCallbackFunction
  });

  @override
  State<CATitle> createState() => _CATitleState();
}

class _CATitleState extends State<CATitle> 
{

  @override
  Widget build(BuildContext context) {
    return 
    Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom:16 ),
      child: TextField
      (
        textAlign: TextAlign.center,
        style: analysisTextFieldStyle,
        decoration: const InputDecoration
        (
          hint: Center(child: Text("Please enter a title for this analysis.", style: analysisTextFieldHintStyle)),
          hintStyle: analysisTextFieldHintStyle,                    
        ),
        maxLength: 150,
        onChanged: widget.onAnalysisTitleUpdatedCallbackFunction,
      ),
    );
  }
}