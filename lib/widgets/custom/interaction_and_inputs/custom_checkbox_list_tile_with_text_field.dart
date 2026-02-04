import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_padded_text_field.dart';
import 'package:journeyers/widgets/custom/text/custom_focusable_text.dart';


// Utility class
PrintUtils pu = PrintUtils();

/// {@category Custom widgets}
/// A customizable checkbox that displays a customizable text field when the box is checked.
class CustomCheckBoxWithTextField extends StatefulWidget 
{
  /// The text of the checkbox.
  final String checkboxText;

  /// The style of the text.
  TextStyle checkboxTextStyle;

  /// The alignment of the text.
  final TextAlign checkboxTextAlignment;

  /// If the checkbox is checked at start.
  final bool checkboxIsChecked;

  /// Where the checkbox is located.
  final ListTileControlAffinity checkboxPosition;

  /// The hint text for the text field.
  final String textFieldHintText;

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
  final ValueChanged<String> parentWidgetTextFieldValueCallBackFunction;

  /// The checkbox-related callback function for the parent widget.
  final ValueChanged<bool?>? parentWidgetCheckboxValueCallBackFunction;

  /// A placeholder void callback function with a String parameter
  static void placeHolderFunctionString(String value) {}

  /// A placeholder void callback function with a bool parameter
  static void placeHolderFunctionBool(bool? value) {}

  CustomCheckBoxWithTextField
  ({
    super.key,
    required this.checkboxText,
    this.checkboxTextStyle = unselectedCheckboxTextStyle,
    this.checkboxTextAlignment = TextAlign.center,
    this.checkboxPosition = ListTileControlAffinity.leading,
    this.checkboxIsChecked = false,
    required this.textFieldHintText,
    this.textFieldPaddingHorizontal = 20.0,
    this.textFieldPaddingBottom = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.textFieldMaxLength = FormUtils.chars1Page, // a page as a reference
    this.textFieldCounter = FormUtils.absentCounter,
    this.parentWidgetTextFieldValueCallBackFunction = placeHolderFunctionString,
    this.parentWidgetCheckboxValueCallBackFunction = placeHolderFunctionBool,
  });

  @override
  State<CustomCheckBoxWithTextField> createState() =>  CustomCheckBoxWithTextFieldState();
}

class CustomCheckBoxWithTextFieldState extends State<CustomCheckBoxWithTextField> 
{
  bool _isChecked = false;
  String _textFieldValue = "";
  TextStyle _checkboxTextStyle = unselectedCheckboxTextStyle;

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
            widget.parentWidgetCheckboxValueCallBackFunction!(value);
            setState(() 
            {
              _isChecked = value!; 
              if(value){_checkboxTextStyle = selectedCheckboxTextStyle;}
              else {_checkboxTextStyle = unselectedCheckboxTextStyle;}
            });
          },
        ),
        if (_isChecked)
          CustomPaddedTextField
          (
            textFieldStartValue: _textFieldValue,
            textFieldHintText: widget.textFieldHintText,
            textFieldMinLines: widget.textFieldMinLines,
            textFieldMaxLines: widget.textFieldMaxLines,
            textFieldMaxLength: widget.textFieldMaxLength,
            textFieldCounter: widget.textFieldCounter,
            parentWidgetTextFieldValueCallBackFunction: 
              (String text) {widget.parentWidgetTextFieldValueCallBackFunction(text);setState(() {_textFieldValue = text;});},
          ),
      ],
    );
  }
}
