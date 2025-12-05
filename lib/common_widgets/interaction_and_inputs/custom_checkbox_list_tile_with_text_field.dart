import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';

class CustomCheckBoxWithTextField extends StatefulWidget 
{
  /// The text of the checkbox 
  final String text;
  // The font size for the text 
  final double textFontSize;
  /// The color of the text
  final Color textColor;  
  /// If the checkbox is checked to start with
  final bool isChecked;  
  /// Where the checkbox is located
  final ListTileControlAffinity controlAffinity;
  /// A placeholder for the text field
  final String textFieldPlaceholder;
  /// The left and right padding value for the text field
  final double textFieldHorizontalPadding;
  /// The bottom padding value for the text field
  final double textFieldBottomPadding;
  /// The minLines value for the text field 
  final int textFieldMinLines;
  /// The maxLines value for the text field 
  final int textFieldMaxLines;
  /// The cross axis alignment for the checkbox, and the text field
  final CrossAxisAlignment inputsCrossAxisAlignment;
  /// The callback function used to pass the checkbox state
  final Function onChanged;

  const CustomCheckBoxWithTextField
  ({
    super.key,
    required this.text,    
    this.textFontSize = 24,
    this.textColor = Colors.black,
    this.isChecked = false,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.textFieldPlaceholder  = "Please develop or take some notes if relevant.",
    this.textFieldHorizontalPadding = 20.0,
    this.textFieldBottomPadding = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.inputsCrossAxisAlignment = CrossAxisAlignment.start,
    required this.onChanged
  });

  @override
  State<CustomCheckBoxWithTextField> createState() => _CustomCheckBoxWithTextFieldState();
}

class _CustomCheckBoxWithTextFieldState extends State<CustomCheckBoxWithTextField> 
{
  bool? _isChecked;

  @override
  void initState() {
    super.initState();    
    _isChecked = widget.isChecked; 
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
      crossAxisAlignment: widget.inputsCrossAxisAlignment,
      children: 
      [
        CheckboxListTile
        (
          title: CustomText(text: widget.text, textStyle: textStyle, textAlign: TextAlign.left),
          value: _isChecked, 
          controlAffinity: widget.controlAffinity,
          onChanged: (value) => {setState((){_isChecked = value; widget.onChanged(_isChecked);})}
        ),        
        if (_isChecked!)
          Padding
          (
            padding: EdgeInsets.only(left: widget.textFieldHorizontalPadding, right: widget.textFieldHorizontalPadding, bottom: widget.textFieldBottomPadding),
            child: TextField
            (             
              decoration: InputDecoration(hintText: widget.textFieldPlaceholder),
              minLines: widget.textFieldMinLines,
              maxLines: widget.textFieldMaxLines,
            ),
          ),        
      ],
    );
  }
}