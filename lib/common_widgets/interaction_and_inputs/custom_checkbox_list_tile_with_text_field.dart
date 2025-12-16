import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_padded_text_field.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';

class CustomCheckBoxWithTextField extends StatefulWidget 
{
  /// The text of the checkbox 
  final String text;
  // The font size for the text 
  final double textFontSize;
  /// The color of the text
  final Color textColor;  
  /// The alignment for the text
  final TextAlign textAlign;
  /// If the checkbox is checked to start with
  final bool isChecked;  
  /// Where the checkbox is located
  final ListTileControlAffinity controlAffinity;
  /// The hint text for the text field
  final String textFieldPlaceholder;
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
  final InputCounterWidgetBuilder buildCounter;
  /// A callback function for the parent widget
  final ValueChanged<String> parentWidgetTextFieldValueCallBackFunction;
  /// A callback function for the parent widget
  final ValueChanged<bool?> ?parentWidgetCheckboxValueCallBackFunction;

  static void placeHolderFunctionString(String value) {}
  static void placeHolderFunctionBool(bool? value) {}

  const CustomCheckBoxWithTextField
  ({
    super.key,
    required this.text,    
    this.textFontSize = 24,
    this.textColor = Colors.black,
    this.textAlign = TextAlign.left, 
    this.controlAffinity = ListTileControlAffinity.leading,
    this.isChecked = false,
    required this.textFieldPlaceholder,
    this.textFieldHorizontalPadding = 20.0,
    this.textFieldBottomPadding = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,    
    this.textFieldMaxLength = chars1Page, // a page as a reference
    this.buildCounter = absentCounter,
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
    final TextStyle textStyle = TextStyle
    (
      fontSize: widget.textFontSize,
      color: widget.textColor,
    );

    return Column
    (
      children: 
      [
        CheckboxListTile
        (
          title: CustomText(text: widget.text, textStyle: textStyle, textAlign: widget.textAlign),
          value: _isChecked, 
          controlAffinity: widget.controlAffinity,
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
          Padding
          (
            padding: EdgeInsets.only(left: widget.textFieldHorizontalPadding, right: widget.textFieldHorizontalPadding, bottom: widget.textFieldBottomPadding),
            child: CustomPaddedTextField 
            ( 
              textFieldHintText: widget.textFieldPlaceholder, 
              textFieldMinLines: widget.textFieldMinLines,
              textFieldMaxLines: widget.textFieldMaxLines,
              textFieldMaxLength: widget.textFieldMaxLength,
              buildCounter: widget.buildCounter,
              parentWidgetTextFieldValueCallBackFunction: widget.parentWidgetTextFieldValueCallBackFunction           
            ),
          ),
      ],
    );
  }
}