import 'package:flutter/material.dart';

import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_form_misc_constants.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_sanitized_and_checked_using_a_blacklist.dart';


/// {@category Context analysis}
/// A text field with customizable padding.
/// The text field has string sanitization ability. 
class CATextFieldSanitizedAndPadded extends StatefulWidget 
{
  /// A boolean used to state if the title is autofocused.
  final bool autofocus;

  /// If the text field maintains state, when a checkbox with filled text field is unchecked for example.
  final bool maintainState;

  /// The start value for the text field.
  final String textFieldStartValue;

  /// The alignment of the text.
  final TextAlign textAlignment;

  /// The text style for the text field.
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

  /// A map with [StringSanitizerBundle]s as keys, and error messages as values.
   final Map<StringSanitizerBundle, String> stringSanitizerBundlesErrorsMap;

  /// The text field-related callback function for the parent widget.
  final ValueChanged<String> onTextFieldValueChangedCallbackFunction;

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
    this.autofocus = false,
    this.maintainState = true,
    this.textFieldStartValue = "",
    this.textAlignment = TextAlign.center,
    required this.textFieldStyle,
    required this.textFieldHint,
    required this.textFieldHintStyle,
    required this.errorMessageStyle,
    this.textFieldMinLines = 1,
    this.textFieldMaxLength = CAFormMiscConstants.chars10Lines, // 10 lines as a reference
    this.textFieldCounter = TextFieldUtils.counterPresent,
    required this.stringSanitizerBundlesErrorsMap,
    this.onTextFieldValueChangedCallbackFunction = placeHolderFunctionString,
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
  final GlobalKey<_CATextFieldSanitizedAndPaddedState> _textFieldBeforeErrorMessageKey = GlobalKey();
  final TextEditingController _tfec = .new();

  @override
  void initState() 
  {
    super.initState();

    _tfec.text = widget.textFieldStartValue;
  }

  @override
  void dispose() 
  {
    _tfec.dispose();
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
        autofocus: widget.autofocus,
        key: _textFieldBeforeErrorMessageKey,
        stringSanitizerBundlesErrorsMapping: widget.stringSanitizerBundlesErrorsMap,
        textFieldStartValue: widget.textFieldStartValue,
        textFieldStyle: widget.textFieldStyle,
        textFieldHint: widget.textFieldHint,
        textFieldHintStyle: widget.textFieldHintStyle,
        errorMessageStyle: widget.errorMessageStyle,      
        textFieldMinLines: widget.textFieldMinLines,
        textFieldMaxLength: widget.textFieldMaxLength,
        textFieldCounter: widget.textFieldCounter,
        onTextFieldValueChangedCallbackFunction: widget.onTextFieldValueChangedCallbackFunction,
        blacklistingFunctionsErrorsMapping: const {},    
      ),
    );
  }
}
