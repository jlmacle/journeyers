import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';

/// {@category Custom widgets}
/// A customizable text field with customizable padding.
class CustomPaddedTextField extends StatefulWidget 
{
    /// The alignment of the text.
    final TextAlign textAlignment;
    /// The hint text for the text field.
    final String textFieldHintText;
    /// The minLines value for the text field.
    final int textFieldMinLines;
    /// The maxLines value for the text field.
    final int textFieldMaxLines;
    /// The maxLength value for the text field.
    final int textFieldMaxLength; 
    /// The counter for the text field.
    final InputCounterWidgetBuilder textFieldCounter;
    /// The callback function called when the text field value has changed.
    final ValueChanged<String> parentWidgetTextFieldValueCallBackFunction;
    /// The left padding for the text field.
    final double paddingLeft;
    /// The right padding for the text field.
    final double paddingRight;
    /// The top padding for the text field.
    final double paddingTop;
    /// The bottom padding for the text field.
    final double paddingBottom;   
    
    /// A placeholder void callback function with a String parameter.
    static void placeHolderFunction(String value) {}

    const CustomPaddedTextField
    ({
        super.key,      
        this.textAlignment = TextAlign.left,
        required this.textFieldHintText,
        this.textFieldMinLines = 1,
        this.textFieldMaxLines = 10,  
        this.textFieldMaxLength = chars10Lines,// 10 lines as a reference
        this.textFieldCounter = presentCounter,
        this.parentWidgetTextFieldValueCallBackFunction = placeHolderFunction,
        this.paddingLeft = 20,
        this.paddingRight = 20,
        this.paddingTop = 10,
        this.paddingBottom = 10
    });

    @override
    State<CustomPaddedTextField> createState() => _CustomPaddedTextFieldState();
}

class _CustomPaddedTextFieldState extends State<CustomPaddedTextField> 
{
  // The variable to update when a double quote has been found
  String _errorMessageForDoubleQuotes = "";

  TextEditingController textFieldEditingController = TextEditingController();
  @override
  void dispose()
  {
    textFieldEditingController.dispose();
    super.dispose();
  }

  /// The method to call to modify the text field value if a " is found
  /// and to modify the error message to display
  void quoteCheck(value) 
  { 
    if (value.contains('"')) 
    {
      // DESIGN NOTES: after research, it seems that only straight double quote are used to delimit text when importing CSV files
      value = value.replaceAll('"', '');     
      setState(() {  
        // Removes the quotes from the text field
        textFieldEditingController.text = value;
        // Updates the error message
        _errorMessageForDoubleQuotes = 'Straight double quotes are reserved for CSV-related use, and are for this reason removed from the text typed. With apologies.';         
        // "The assertiveness level of the announcement is determined by assertiveness. 
        // Currently, this is only supported by the web engine and has no effect on other platforms. 
        // The default mode is Assertiveness.polite."
        // https://api.flutter.dev/flutter/semantics/SemanticsService/sendAnnouncement.html
        // TODO:  TextDirection.ltr: code to modify for l10n
        // Doesn't seem effective yet. Left for later.
        SemanticsService.sendAnnouncement(View.of(context), _errorMessageForDoubleQuotes, TextDirection.ltr, assertiveness: Assertiveness.assertive);  
        // Updates the parental widget information on the text content
        widget.parentWidgetTextFieldValueCallBackFunction(value);     
      });
    } 
    else 
    {
      setState(() {
        textFieldEditingController.text = value;
        _errorMessageForDoubleQuotes = "";
        widget.parentWidgetTextFieldValueCallBackFunction(value);   
      });
    }    
  }


  @override
  Widget build(BuildContext context) 
  {
    return Padding
    (
        padding: EdgeInsets.only(left: widget.paddingLeft, right: widget.paddingRight, bottom: widget.paddingBottom, top: widget.paddingTop),
        child: TextField
        (
          textAlign: widget.textAlignment,
          controller: textFieldEditingController,
          decoration: InputDecoration(hintText: widget.textFieldHintText, errorText: _errorMessageForDoubleQuotes),
          minLines: widget.textFieldMinLines,
          maxLines: widget.textFieldMaxLines,
          maxLength: widget.textFieldMaxLength,
          buildCounter: widget.textFieldCounter,
          onChanged: (String newValue) {quoteCheck(newValue); }
        ),
    );
  }
}