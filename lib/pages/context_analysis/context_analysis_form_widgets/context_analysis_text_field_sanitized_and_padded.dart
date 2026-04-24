import 'package:flutter/material.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_text_field_misc.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_sanitized_and_checked_using_a_black_list.dart';


/// {@category Context analysis}
/// A customizable text field with customizable padding.
/// The text field has string sanitization ability. 
class CATextFieldSanitizedAndPadded extends StatefulWidget 
{
  /// If the text field maintains state, when the CheckboxWithTextField instance is unchecked for example.
  final bool maintainState;

  /// The start value for the text field.
  final String textFieldStartValue;

  /// The alignment of the text.
  final TextAlign textAlignment;

  // The text style for the text field.
  final TextStyle textFieldStyle;

  /// The hint text for the text field.
  final String textFieldHint;

  /// The hint text style for the text field.
  final TextStyle textFieldHintStyle;

  /// The error message style for the text field.
  final TextStyle errorMessageStyle;

  /// The minLines value for the text field.
  final int textFieldMinLines;

  /// The maxLength value for the text field.
  final int textFieldMaxLength;

  /// The counter for the text field.
  final InputCounterWidgetBuilder textFieldCounter;

  /// A map with functions as keys, and error messages as values.
  /// The functions return true on a valid input, and false on an invalid input.
  final Map<StringSanitizerBundle, String> stringSanitizerBundlesErrorsMap;

  /// The text field-related callback function for the parent widget.
  final ValueChanged<String> onTextFieldValueSubmittedCallbackFunction;

  /// The left padding for the text field.
  final double paddingLeft;

  /// The right padding for the text field.
  final double paddingRight;

  /// The top padding for the text field.
  final double paddingTop;

  /// The bottom padding for the text field.
  final double paddingBottom;

  const CATextFieldSanitizedAndPadded
  ({
    super.key,
    this.maintainState = true,
    this.textFieldStartValue = "",
    this.textAlignment = TextAlign.center,
    required this.textFieldStyle,
    required this.textFieldHint,
    required this.textFieldHintStyle,
    required this.errorMessageStyle,
    this.textFieldMinLines = 1,
    this.textFieldMaxLength = chars10Lines, // 10 lines as a reference
    this.textFieldCounter = TextFieldUtils.presentCounter,
    required this.stringSanitizerBundlesErrorsMap,
    this.onTextFieldValueSubmittedCallbackFunction = placeHolderFunctionString,
    this.paddingLeft = 20,
    this.paddingRight = 20,
    this.paddingTop = 10,
    this.paddingBottom = 10,
  });

  @override
  State<CATextFieldSanitizedAndPadded> createState() => _CATextFieldSanitizedAndPaddedState();
}

class _CATextFieldSanitizedAndPaddedState extends State<CATextFieldSanitizedAndPadded> 
{
  final GlobalKey<_CATextFieldSanitizedAndPaddedState> textFieldBeforeErrorMessageKey = GlobalKey();
  TextEditingController textFieldEditingController = .new();

  @override
  void initState() 
  {
    super.initState();
    textFieldEditingController.text = widget.textFieldStartValue;
  }

  @override
  void dispose() 
  {
    textFieldEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return 
    Padding
    (
      padding: EdgeInsets.only(left: widget.paddingLeft, right: widget.paddingRight, bottom: widget.paddingBottom, top: widget.paddingTop),
      child: 
      TextFieldSanitizedAndCheckedUsingABlackList
      (
        key: textFieldBeforeErrorMessageKey,
        stringSanitizerBundlesErrorsMapping: widget.stringSanitizerBundlesErrorsMap,
        textFieldStyle: widget.textFieldStyle,
        textFieldHint: widget.textFieldHint,
        textFieldHintStyle: widget.textFieldHintStyle,
        errorMessageStyle: widget.errorMessageStyle,      
        textFieldMinLines: widget.textFieldMinLines,
        textFieldMaxLength: widget.textFieldMaxLength,
        textFieldCounter: widget.textFieldCounter,
        onTextFieldValueSubmittedCallbackFunction: widget.onTextFieldValueSubmittedCallbackFunction,
        blacklistingFunctionsErrorsMapping: const {},    
      ),
    );
  }
}
