import 'package:flutter/material.dart';

import 'package:journeyers/utils/generic/dev/type_defs.dart';

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

  /// A key for the error message.
  final Key errorMessageKey;

  /// The style for the error message.
  final TextStyle errorMessageStyle;

  /// A callback function called when submitting the value.
  final ValueChanged<String> valueSubmittedCallbackFunction;

  /// A map with functions as keys, and error messages as values.
  /// The functions return true on a valid input, and false on an invalid input.
  final Map<StringValidator, String> blockingFunctionsErrorMessagesMapping;

  const TextFieldChecked
  ({
    super.key,
    required this.textFieldStyle,
    required this.textFieldHint,
    required this.textFieldHintStyle,
    required this.errorMessageKey,
    required this.errorMessageStyle,
    required this.valueSubmittedCallbackFunction,
    required this.blockingFunctionsErrorMessagesMapping    
  });

  @override
  State<TextFieldChecked> createState() => _TextFieldCheckedState();
}

class _TextFieldCheckedState extends State<TextFieldChecked> 
{
  String _errorMessage = "";
  bool submitIsBlocked = false;

  onChanged(String newValue)
  {
    for (final blockingFunction in widget.blockingFunctionsErrorMessagesMapping.keys)
    {
      if (blockingFunction(newValue))
      {
        // Blocking the submit
        submitIsBlocked = true;

        // Rendering the error message
        setState(() {
          _errorMessage = widget.blockingFunctionsErrorMessagesMapping[blockingFunction]!;
        });
      }
    }
  }

  onSubmitted(String newValue)
  {
    if (!submitIsBlocked)
    {
      widget.valueSubmittedCallbackFunction(newValue);
    }
  }

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
          error: 
          Center
          (
            key: widget.errorMessageKey, 
            child: Text
            (
              textAlign: TextAlign.center, 
              _errorMessage, 
              style: widget.errorMessageStyle)),
          errorMaxLines: 3
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted
    );
  }
}