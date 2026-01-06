import 'package:flutter/material.dart';

import 'package:journeyers/core/utils/form/form_utils.dart';
import 'package:journeyers/custom_widgets/display_and_content/custom_focusable_text.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_padded_text_field.dart';

/// {@category Custom widgets}
/// A customizable checkbox that displays a customizable text field when the box is checked.
class CustomCheckBoxWithTextField extends StatefulWidget {
  /// The text of the checkbox.
  final String checkboxText;

  /// The font size of the text.
  final double checkboxTextFontSize;

  /// The color of the text.
  final Color checkboxTextColor;

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

  const CustomCheckBoxWithTextField({
    super.key,
    required this.checkboxText,
    this.checkboxTextFontSize = 24,
    this.checkboxTextColor = Colors.black,
    this.checkboxTextAlignment = TextAlign.left,
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
  State<CustomCheckBoxWithTextField> createState() =>
      CustomCheckBoxWithTextFieldState();
}

class CustomCheckBoxWithTextFieldState
    extends State<CustomCheckBoxWithTextField> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle checkboxTextStyle = TextStyle(
      fontSize: widget.checkboxTextFontSize,
      color: widget.checkboxTextColor,
    );

    return Column(
      children: [
        CheckboxListTile(
          title: CustomFocusableText(
            text: widget.checkboxText,
            textStyle: checkboxTextStyle,
            textAlignment: widget.checkboxTextAlignment,
          ),
          value: _isChecked,
          controlAffinity: widget.checkboxPosition,
          onChanged: (bool? value) {
            widget.parentWidgetCheckboxValueCallBackFunction!(value);
            setState(() {
              _isChecked = value!;
            });
          },
        ),
        if (_isChecked)
          CustomPaddedTextField(
            textFieldHintText: widget.textFieldHintText,
            textFieldMinLines: widget.textFieldMinLines,
            textFieldMaxLines: widget.textFieldMaxLines,
            textFieldMaxLength: widget.textFieldMaxLength,
            textFieldCounter: widget.textFieldCounter,
            parentWidgetTextFieldValueCallBackFunction:
                widget.parentWidgetTextFieldValueCallBackFunction,
          ),
      ],
    );
  }
}
