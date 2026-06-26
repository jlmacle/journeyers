import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_form_misc_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart' as tfu_proj;
import 'package:journeyers/widgets/custom/text/custom_focusable_text.dart';


/// {@category Context analysis}
/// A checkbox that displays a text field when the box is checked.
/// The text field has string sanitization, and removes straight quotes, for CSV export reason.
class CACheckboxWithSanitizedAndPaddedTextField extends StatefulWidget 
{
  /// The text of the checkbox.
  final String checkboxText;

  /// The style of the text.
  final TextStyle checkboxTextStyle;

  /// The alignment of the text.
  final TextAlign checkboxTextAlignment;

  /// If the checkbox is checked at start.
  final bool checkboxStartValue;

  /// Where the checkbox is located.
  final ListTileControlAffinity checkboxPosition;

  /// The start value for the text field.
  final String textFieldStartValue;

  /// The hint text for the text field.
  final String textFieldHint;

  /// The left and right padding value for the text field.
  final double textFieldPaddingHorizontal;

  /// The bottom padding value for the text field.
  final double textFieldPaddingBottom;

  /// The minLines value for the text field.
  final int textFieldMinLines;

  /// The maxLines value for the text field.
  final int textFieldMaxLines;

  /// The maxLength value for the text field.
  final int textFieldMaxLength;

  /// The counter for the text field.
  final InputCounterWidgetBuilder textFieldCounter;

  /// The text field-related callback function for the parent widget.
  final ValueChanged<String> onTextFieldValueChangedCallbackFunction;

  /// The checkbox-related callback function for the parent widget.
  final ValueChanged<bool?>? onCheckboxValueChangedCallbackFunction;

  const CACheckboxWithSanitizedAndPaddedTextField
  ({
    super.key,
    required this.checkboxText,
    this.checkboxTextStyle = unselectedCheckboxTextStyle,
    this.checkboxTextAlignment = TextAlign.center,
    this.checkboxPosition = ListTileControlAffinity.leading,
    this.checkboxStartValue = false,
    this.textFieldStartValue = "",
    required this.textFieldHint,
    this.textFieldPaddingHorizontal = 20.0,
    this.textFieldPaddingBottom = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.textFieldMaxLength = CAFormMiscConstants.chars1Page, // a page as a reference
    this.textFieldCounter = TextFieldUtils.counterAbsent,
    this.onTextFieldValueChangedCallbackFunction = placeHolderFunctionString,
    this.onCheckboxValueChangedCallbackFunction = placeHolderFunctionNullableBool,
  });

  @override
  State<CACheckboxWithSanitizedAndPaddedTextField> createState() =>  CACheckboxWithSanitizedAndPaddedTextFieldState();
}

class CACheckboxWithSanitizedAndPaddedTextFieldState extends State<CACheckboxWithSanitizedAndPaddedTextField> 
{
  late bool _isChecked;

  // The default checkbox style
  TextStyle _checkboxTextStyle = unselectedCheckboxTextStyle;
  
  // To store the text field value if the checkbox is unchecked
  late String _textFieldValue;
  

  @override
  void initState() {
    super.initState();

    _isChecked = widget.checkboxStartValue;
    _textFieldValue = widget.textFieldStartValue;
  }

  @override
  Widget build(BuildContext context)
  {
    return 
    Column
    (
      children: 
      [
        CheckboxListTile
        (
          title: 
          CustomFocusableText
          (
            text: widget.checkboxText,
            textStyle: _checkboxTextStyle,
            textAlignment: widget.checkboxTextAlignment,
          ),
          value: _isChecked,
          controlAffinity: widget.checkboxPosition,
          onChanged: (bool? value) 
          {
            widget.onCheckboxValueChangedCallbackFunction!(value);
            setState(() 
            {
              _isChecked = value!; 
              if(value){_checkboxTextStyle = selectedCheckboxTextStyle;}
              else {_checkboxTextStyle = unselectedCheckboxTextStyle;}
            });
          },
        ),
        if (_isChecked)
          CATextFieldSanitizedAndPadded
          (
            stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
            // Getting the start value from the checkbox, in case the text field would have been removed from the tree
            textFieldStartValue: _textFieldValue,
            textFieldStyle: analysisTextFieldStyle,
            textFieldHint: widget.textFieldHint,
            textFieldHintStyle: analysisTextFieldHintStyle,
            errorMessageStyle: analysisTextFieldErrorMessageStyle,
            textFieldMinLines: widget.textFieldMinLines,
            textFieldMaxLength: widget.textFieldMaxLength,
            textFieldCounter: widget.textFieldCounter,
            onTextFieldValueChangedCallbackFunction: 
              (String text) 
              {
                widget.onTextFieldValueChangedCallbackFunction(text);
                setState(() {_textFieldValue = text;});
              },
          ),
          
      ],
    );
  }
}
