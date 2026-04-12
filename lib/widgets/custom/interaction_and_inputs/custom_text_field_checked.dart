import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_consts.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart' as tfu_proj;

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

   /// The minLines value for the text field.
  final int textFieldMinLines;

  /// The maxLength value for the text field.
  final int textFieldMaxLength;

  /// The counter for the text field.
  final InputCounterWidgetBuilder textFieldCounter;

  /// A callback function called when submitting the value.
  final ValueChanged<String> valueSubmittedCallbackFunction;

  /// A map with functions as keys, and error messages as values.
  /// The functions return true on a valid input, and false on an invalid input.
  final Map<StringSanitizerBundle, String> blockingFunctionsErrorMessagesMapping;

  const TextFieldChecked
  ({
    super.key,
    required this.textFieldStyle,
    required this.textFieldHint,
    required this.textFieldHintStyle,
    this.errorMessageKey = const Key('error_msg_key_default'),
    required this.errorMessageStyle,
    this.textFieldMinLines = 1,
    this.textFieldMaxLength = chars10Lines, // 10 lines as a reference
    this.textFieldCounter = TextFieldUtils.presentCounter,
    required this.valueSubmittedCallbackFunction,
    required this.blockingFunctionsErrorMessagesMapping    
  });

  @override
  State<TextFieldChecked> createState() => _TextFieldCheckedState();
}

class _TextFieldCheckedState extends State<TextFieldChecked> 
{
  bool submitIsBlocked = false;  

  // Useful for automatic scrolling
  final GlobalKey<_TextFieldCheckedState> textFieldKey = GlobalKey();

  TextEditingController textFieldEditingController = .new();
  String _errorMessageForDoubleQuotes = "";

  @override
  void dispose() 
  {
    textFieldEditingController.dispose();
    super.dispose();
  }

  // Method used to scroll the text field and error message into view
  Future<void> _scrollForBetterErrorViewing() async
  {
    final context = textFieldKey.currentContext;

    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // The method to call to modify the text field value if a " or line return is found
  // and to modify the error message to display.
  Future<void> userInputHandling(value) async
  {
    // Does the user input needs sanitization and does the submit needs to be blocked?

    // Yes, because a blocking function returned true
    List<Function> sanitizingFunctionsReturnedTrueList = [];
    if (tfu_proj.TextFieldUtils.stringSanitizerBundlesErrorsMapForCA
        .keys
        .any
        (
          (stringSanitizerBundle)
          {
            var recordResult = stringSanitizerBundle(value);
            // Getting the info from the record
            bool shouldStringBeSanitized = recordResult.shouldStringBeSanitized;
            // Adding the sanitizing function to the list for later sanitizing
            if (shouldStringBeSanitized) sanitizingFunctionsReturnedTrueList.add(recordResult.sanitizingFunction);
            return shouldStringBeSanitized;
          }
        )
        ) 
    {
      // TO MODIFY
      if (textFieldDebugging) pu.printd("Text Field: Straight quote or a found.");

      // Blocking the submit
      submitIsBlocked = true;
      if (textFieldDebugging) pu.printd("Text Field: submitIsBlocked: $submitIsBlocked");

      // Sanitizing the input
      // DESIGN NOTES: after research, 
      // it seems that only straight double quote are used to delimit text when importing CSV files
      // var cleanedValue = value.replaceAll(TextFieldUtils.quoteChar, '');
      // Going through the list of sanitizing functions
      var cleanedValue = value;
      for (final sanitizingFunction in sanitizingFunctionsReturnedTrueList)
      {
          // Looping the cleaning
          cleanedValue = sanitizingFunction(cleanedValue);
      }

      if (textFieldDebugging) pu.printd("Text Field: cleanedValue: $cleanedValue");
   
      setState(() 
      {
        // Updating the text editing controller's text with the sanitized input
        textFieldEditingController.text = cleanedValue;

        // Letting the user know that the input was sanitized
      _errorMessageForDoubleQuotes = TextFieldUtils.containsAStraightQuoteError;  
      });       

      // Scrolling for better error message communication to the user
      await _scrollForBetterErrorViewing();

      // Screen reader voicing
      // "The assertiveness level of the announcement is determined by assertiveness.
      // Currently, this is only supported by the web engine and has no effect on other platforms.
      // The default mode is Assertiveness.polite."
      // https://api.flutter.dev/flutter/semantics/SemanticsService/sendAnnouncement.html
      // TODO:  TextDirection.ltr: code to modify for l10n
      // Doesn't seem effective yet. Left for later. 
      SemanticsService.sendAnnouncement
      (
        View.of(context), _errorMessageForDoubleQuotes, 
        TextDirection.ltr, assertiveness: Assertiveness.assertive
      );

      // Updating the parental widget information with the sanitized value
      // Un-related to onSubmit
      widget.valueSubmittedCallbackFunction(cleanedValue);

      // Unblocking the submit
      submitIsBlocked = false;
    } 

    // No, because no blocking function returned true
    else 
    {
      if (textFieldDebugging) pu.printd("Text Field: No sanitizing needed: value: $value");

      // Removing the error message
      setState(() 
      {
        _errorMessageForDoubleQuotes = "";        
      });

      // Updating the parental widget information with the value
      widget.valueSubmittedCallbackFunction(value);
    }
  }

  onChanged(String newValue) async
  {
    // By default, submit is not blocked
    submitIsBlocked = false;

    if (textFieldDebugging) pu.printd("Text Field: onChanged: submitIsBlocked: $submitIsBlocked");

    // Checking the characters, and resetting the error message if relevant
    await userInputHandling(newValue);
  }

  onSubmitted(String newValue)
  {
    if (textFieldDebugging) pu.printd("Text Field: onSubmitted: submitIsBlocked: $submitIsBlocked");
    if (!submitIsBlocked) {
      widget.valueSubmittedCallbackFunction(newValue);
    }

  }

  @override
  Widget build(BuildContext context) 
  {
    return TextField
    (
      key: textFieldKey,
      controller: textFieldEditingController,
      // https://api.flutter.dev/flutter/services/TextInputType/text-constant.html
      keyboardType: TextInputType.text,
      minLines: widget.textFieldMinLines,
      // https://api.flutter.dev/flutter/material/TextField/maxLines.html
      // "If this is null, there is no limit to the number of lines, 
      // and the text container will start with enough vertical space for one line 
      // and automatically grow to accommodate additional lines as they are entered, 
      // up to the height of its constraints."
      maxLines: null,
      maxLength: widget.textFieldMaxLength,
      buildCounter: widget.textFieldCounter,
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
          error: Center
          (
            key: widget.errorMessageKey,
            child: Text
            (
              textAlign: TextAlign.center, 
              _errorMessageForDoubleQuotes, 
              style: widget.errorMessageStyle
            )
          ),
          errorMaxLines: 3
      ),
      onChanged: onChanged,
      onSubmitted: (!submitIsBlocked) ?  onSubmitted : null,  
      // on iOS, allows to dismiss the text field keyboard, if tapping outside the text field
      onTapOutside: (PointerDownEvent event) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}