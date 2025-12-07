import 'package:flutter/material.dart';

class CustomPaddedTextField extends StatefulWidget 
{
    /// The InputDecoration for the text field
    final InputDecoration textFieldInputDecoration;
    /// The minLines value for the text field
    final int textFieldMinLines;
    /// The maxLines value for the text field
    final int textFieldMaxLines;
    /// The text field editing controller
    final TextEditingController textFieldEditingController;
    /// The callback function when the text field is modified
    final ValueChanged<String>? onTextFieldChanged;
    /// The left padding for the text field
    final double leftPadding;
    /// The right padding for the text field
    final double rightPadding;
    /// The top padding for the text field
    final double topPadding;
    /// The bottom padding for the text field
    final double bottomPadding;
    

    const CustomPaddedTextField
    ({
        super.key,      
        required this.textFieldInputDecoration,
        this.textFieldMinLines = 1,
        this.textFieldMaxLines = 10,  
        required this.textFieldEditingController,
        required this.onTextFieldChanged,
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
  @override
  Widget build(BuildContext context) 
  {
    return Padding
    (
        padding: EdgeInsets.only(left: widget.leftPadding, right: widget.rightPadding, bottom: widget.bottomPadding, top: widget.topPadding),
        child: TextField
        (
          controller: widget.textFieldEditingController,
          decoration: widget.textFieldInputDecoration,
          minLines: widget.textFieldMinLines,
          maxLines: widget.textFieldMaxLines,
          onChanged: widget.onTextFieldChanged,
        ),
    );
  }
}