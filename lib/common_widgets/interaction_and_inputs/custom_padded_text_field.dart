import 'package:flutter/material.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';

class CustomPaddedTextField extends StatefulWidget 
{
    /// Alignment for the text
    final TextAlign textAlignment;
    /// The hint text for the text field
    final String textFieldHintText;
    /// The minLines value for the text field
    final int textFieldMinLines;
    /// The maxLines value for the text field
    final int textFieldMaxLines;
    /// The maxLength for the text field
    final int textFieldMaxLength; 
    /// The counter for the text field
    final InputCounterWidgetBuilder buildCounter;
    /// The text field editing controller
    final TextEditingController textFieldEditingController;
    /// A callback function for the parent widget
    final ValueChanged<String> parentWidgetTextFieldValueCallBackFunction;
    /// The left padding for the text field
    final double leftPadding;
    /// The right padding for the text field
    final double rightPadding;
    /// The top padding for the text field
    final double topPadding;
    /// The bottom padding for the text field
    final double bottomPadding;   

    static void _placeHolderFunction(String value) {}

    CustomPaddedTextField
    ({
        super.key,      
        this.textAlignment = TextAlign.left,
        required this.textFieldHintText,
        this.textFieldMinLines = 1,
        this.textFieldMaxLines = 10,  
        this.textFieldMaxLength = chars10Lines,// 10 lines as a reference
        this.buildCounter = presentCounter,
        required this.textFieldEditingController,
        this.parentWidgetTextFieldValueCallBackFunction = _placeHolderFunction,
        this.leftPadding = 20,
        this.rightPadding = 20,
        this.topPadding = 10,
        this.bottomPadding = 10
    });

    @override
    State<CustomPaddedTextField> createState() => _CustomPaddedTextFieldState();
}

class _CustomPaddedTextFieldState extends State<CustomPaddedTextField> 
{
  String _errorMessageForDoubleQuotes = "";

  void onTextFieldChanged(value) 
  { 
    widget.parentWidgetTextFieldValueCallBackFunction(value);
    if (value.contains('"')) 
    {
      value = value.replaceAll('"', '');     
      setState(() {
         widget.textFieldEditingController.text = value;         
        _errorMessageForDoubleQuotes = 'Double quotes are reserved for CSV-related use.';         
      });
    } 
    else 
    {
      setState(() {
         widget.textFieldEditingController.text = value; 
        _errorMessageForDoubleQuotes = "";
      });
    }    
  }

  @override
  Widget build(BuildContext context) 
  {
    return Padding
    (
        padding: EdgeInsets.only(left: widget.leftPadding, right: widget.rightPadding, bottom: widget.bottomPadding, top: widget.topPadding),
        child: TextField
        (
          textAlign: widget.textAlignment,
          controller: widget.textFieldEditingController,
          decoration: InputDecoration(hintText: widget.textFieldHintText, errorText: _errorMessageForDoubleQuotes),
          minLines: widget.textFieldMinLines,
          maxLines: widget.textFieldMaxLines,
          maxLength: widget.textFieldMaxLength,
          buildCounter: widget.buildCounter,
          onChanged: onTextFieldChanged,
        ),
    );
  }
}