import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_form_misc_constants.dart';

/// {@category Context analysis}
/// A widget used for the title of the context analysis.
class CATitleDeclaration extends StatefulWidget 
{
  /// A callback function called after editing the title is complete.
  final ValueChanged<String> onAnalysisTitleUpdatedProcessCallbackFunction;

  const CATitleDeclaration
  ({
    super.key,
    required this.onAnalysisTitleUpdatedProcessCallbackFunction
  });

  @override
  State<CATitleDeclaration> createState() => _CATitleDeclarationState();
}

class _CATitleDeclarationState extends State<CATitleDeclaration> 
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
          hint: Center(child: Text(CAFormMiscConstants.caTitleDeclarationHintText, style: analysisTextFieldHintStyle)),
          hintStyle: analysisTextFieldHintStyle,                    
        ),
        maxLength: 150,
        onChanged: widget.onAnalysisTitleUpdatedProcessCallbackFunction,
      ),
    );
  }
}