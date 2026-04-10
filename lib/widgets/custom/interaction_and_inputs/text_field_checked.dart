import 'package:flutter/material.dart';

/// {@category Custom widgets}
/// A text field that checks the entered value with different functions,
/// and prevents the value from being submitted, in any of the functions returns true.
class TextFieldChecked extends StatefulWidget 
{
  /// The style for the text field.
  final TextStyle textFieldStyle;

  /// The hint text for the text field.
  final String textFieldHint;

  /// The style for the hint text.
  final TextStyle textFieldHintStyle;

  /// A map with functions as keys, and error messages as values.
  final Map<Function, String> functionErrorMessageMapping;

  const TextFieldChecked
  ({
    super.key,
    required this.textFieldStyle,
    required this.textFieldHint,
    required this.textFieldHintStyle,
    required this.functionErrorMessageMapping    
  });

  @override
  State<TextFieldChecked> createState() => _TextFieldCheckedState();
}

class _TextFieldCheckedState extends State<TextFieldChecked> 
{



  @override
  Widget build(BuildContext context) {
    return TextField
    (
      style: widget.textFieldStyle,
      decoration: InputDecoration
      (
          hint: Center
          (
            child: 
              Text
              (
                textAlign: TextAlign.center,
                widget.textFieldHint,
                style: widget.textFieldHintStyle
              )
          ),
          error: Center(key: errorMessageKey, child: Text(textAlign: TextAlign.center, _errorMessageForFileName , style: analysisTextFieldErrorStyle)),
          errorMaxLines: 3
      ),
      onChanged: (_){},
    );
  }
}