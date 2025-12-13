import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';
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
  /// The maxLength for the text field
  final int textFieldMaxLength; 
  /// The counter for the text field
  final InputCounterWidgetBuilder buildCounter;

  /// The callback function used to pass the checkbox state
  final Function onCheckboxChanged;
  /// The callback function used to pass the text field state
  final Function onTextFieldChanged;

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
    required this.onCheckboxChanged,
    required this.onTextFieldChanged
  });

  @override
  State<CustomCheckBoxWithTextField> createState() => CustomCheckBoxWithTextFieldState();
}

class CustomCheckBoxWithTextFieldState extends State<CustomCheckBoxWithTextField> 
{
  bool? _isChecked;
  late TextEditingController _textFieldEditingController;

  @override
  void initState() {
    super.initState();    
    _isChecked = widget.isChecked; 
    _textFieldEditingController =  TextEditingController(text:"");    
  }

  @override
  void dispose()
  {
    _textFieldEditingController.dispose();
    super.dispose();
  }

  /// Callback function to update the checkbox state
  importCheckBoxState(bool importedValue){setState(() {_isChecked = importedValue;});}
  Function(bool) get updateCheckBoxStateFunction => importCheckBoxState;

  /// Callback function to update the text field state
  importTextFieldState(String importedValue){setState(() {_textFieldEditingController.text = importedValue;});}
  Function(String) get updateTextFieldStateFunction => importTextFieldState;
  
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
          onChanged: (value) => {setState((){_isChecked = value; widget.onCheckboxChanged(_isChecked);})}
        ),        
        if (_isChecked!)
          Padding
          (
            padding: EdgeInsets.only(left: widget.textFieldHorizontalPadding, right: widget.textFieldHorizontalPadding, bottom: widget.textFieldBottomPadding),
            child: TextField
            ( 
              controller: _textFieldEditingController,
              decoration: InputDecoration(hintText: widget.textFieldPlaceholder),
              minLines: widget.textFieldMinLines,
              maxLines: widget.textFieldMaxLines,
              maxLength: widget.textFieldMaxLength,
              buildCounter: widget.buildCounter,
              onChanged: (value) => {setState(() {widget.onTextFieldChanged(value);})}
            ),
          ),
      ],
    );
  }
}