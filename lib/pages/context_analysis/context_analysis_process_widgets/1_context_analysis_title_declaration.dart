import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_form_misc_constants.dart';

/// {@category Context analysis}
/// A widget used for the title of the context analysis.
class CATitleDeclaration extends StatefulWidget 
{
  /// A boolean used to state if the title is autofocused.
  final bool analysisTitleAutofocused;

  // Todo: to clean
  /// A title value used at editing time.
  final String analysisTitleWhenEdition;

  /// A boolean used to state if an edition is in progress.
  final bool isSessionDataEdited;  
  
  /// A callback function called after editing the title is complete.
  final ValueChanged<String> onAnalysisTitleUpdatedProcessCallbackFunction;

  const CATitleDeclaration
  ({
    super.key,
    this.isSessionDataEdited = false,
    this.analysisTitleAutofocused = false,
    required this.analysisTitleWhenEdition,
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
      child: CATextFieldSanitizedAndPadded
      (
        autofocus: widget.analysisTitleAutofocused,
        textFieldStartValue: widget.analysisTitleWhenEdition,
        textFieldStyle: analysisTextFieldStyle, 
        textFieldHint: CAFormMiscConstants.caTitleDeclarationHintText, 
        textFieldHintStyle: analysisTextFieldHintStyle, 
        errorMessageStyle: analysisTextFieldErrorMessageStyle, 
        stringSanitizerBundlesErrorsMap: const {},
        textFieldMaxLength: 150,
        onTextFieldValueChangedCallbackFunction : widget.onAnalysisTitleUpdatedProcessCallbackFunction,
        
      )
    );
  }
}