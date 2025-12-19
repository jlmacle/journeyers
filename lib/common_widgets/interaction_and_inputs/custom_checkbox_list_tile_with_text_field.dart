import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_padded_text_field.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';

class CustomCheckBoxWithTextField extends StatefulWidget 
{
  /// The text of the checkbox 
  final String checkboxText;
  // The font size for the text 
  final double checkboxTextFontSize;
  /// The color of the text
  final Color checkboxTextColor;  
  /// The alignment for the text
  final TextAlign checkboxTextAlignment;
  /// If the checkbox is checked to start with
  final bool isChecked;  
  /// Where the checkbox is located
  final ListTileControlAffinity checkboxPosition;
  /// The hint text for the text field
  final String textFieldHintText;
  /// The left and right padding value for the text field
  final double textFieldHorizontalPadding;
  /// The bottom padding value for the text field
  final double textFieldBottomPadding;
  /// The minLines value for the text field 
  final int textFieldMinLines;
  /// The maxLines value for the text field 
  final int textFieldMaxLines;
  /// The maxLength for the text field
  final int textFieldMaxLength; 
  /// The counter for the text field
  final InputCounterWidgetBuilder textFieldCounter;
  /// A text field-related callback function for the parent widget
  final ValueChanged<String> parentWidgetTextFieldValueCallBackFunction;
  /// A checkbox-related callback function for the parent widget
  final ValueChanged<bool?> ?parentWidgetCheckboxValueCallBackFunction;

  static void placeHolderFunctionString(String value) {}
  static void placeHolderFunctionBool(bool? value) {}

  const CustomCheckBoxWithTextField
  ({
    super.key,
    required this.checkboxText,    
    this.checkboxTextFontSize = 24,
    this.checkboxTextColor = Colors.black,
    this.checkboxTextAlignment = TextAlign.left, 
    this.checkboxPosition = ListTileControlAffinity.leading,
    this.isChecked = false,
    required this.textFieldHintText,
    this.textFieldHorizontalPadding = 20.0,
    this.textFieldBottomPadding = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,    
    this.textFieldMaxLength = chars1Page, // a page as a reference
    this.textFieldCounter = absentCounter,
    this.parentWidgetTextFieldValueCallBackFunction = placeHolderFunctionString,
    this.parentWidgetCheckboxValueCallBackFunction = placeHolderFunctionBool,
  });

  @override
  State<CustomCheckBoxWithTextField> createState() => CustomCheckBoxWithTextFieldState();
}

class CustomCheckBoxWithTextFieldState extends State<CustomCheckBoxWithTextField> 
{
  bool _isChecked = false;

  @override
  void initState() 
  {
    super.initState(); 
  }
  
  @override
  Widget build(BuildContext context) 
  {
    final TextStyle checkboxTextStyle = TextStyle
    (
      fontSize: widget.checkboxTextFontSize,
      color: widget.checkboxTextColor,
    );

    return Column
    (
      children: 
      [
        CheckboxListTile
        (
          title: CustomText(text: widget.checkboxText, textStyle: checkboxTextStyle, textAlignment: widget.checkboxTextAlignment),
          value: _isChecked, 
          controlAffinity: widget.checkboxPosition,
          onChanged: (bool? value)
          {
            widget.parentWidgetCheckboxValueCallBackFunction!(value); 
            setState
            (() 
              {_isChecked = value!;}
            );
          },
        ),        
        if (_isChecked)
            CustomPaddedTextField 
            ( 
              textFieldHintText: widget.textFieldHintText, 
              textFieldMinLines: widget.textFieldMinLines,
              textFieldMaxLines: widget.textFieldMaxLines,
              textFieldMaxLength: widget.textFieldMaxLength,
              buildCounter: widget.textFieldCounter,
              parentWidgetTextFieldValueCallBackFunction: widget.parentWidgetTextFieldValueCallBackFunction           
            ),
      ],
    );
  }
}