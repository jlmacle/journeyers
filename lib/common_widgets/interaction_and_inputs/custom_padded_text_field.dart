import 'package:flutter/material.dart';

class CustomPaddedTextField extends StatefulWidget 
{
    /// Alignment for the text
    final TextAlign textAlignment;
    /// The InputDecoration for the text field
    final InputDecoration textFieldInputDecoration;
    /// The minLines value for the text field
    final int textFieldMinLines;
    /// The maxLines value for the text field
    final int textFieldMaxLines;
    /// The maxLength for the text field
    final int textFieldMaxLength; 
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
     

    CustomPaddedTextField
    ({
        super.key,      
        this.textAlignment = TextAlign.left,
        required this.textFieldInputDecoration,
        this.textFieldMinLines = 1,
        this.textFieldMaxLines = 10,  
        this.textFieldMaxLength = 7330,// a page as a reference
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
          textAlign: widget.textAlignment,
          controller: widget.textFieldEditingController,
          decoration: widget.textFieldInputDecoration,
          minLines: widget.textFieldMinLines,
          maxLines: widget.textFieldMaxLines,
          maxLength: widget.textFieldMaxLength,
          onChanged: widget.onTextFieldChanged,
        ),
    );
  }
}