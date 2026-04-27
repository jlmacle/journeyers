import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/_context_analysis_form_text_field_misc_constants.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';

/// {@category Custom widgets}
/// A text field that checks the entered value with different functions,
/// and prevents the value from being submitted, in any of the functions returns true.
class TextFieldSanitizedAndCheckedUsingABlackList extends StatefulWidget 
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

  /// A callback function called when submitting the text field value.
  final ValueChanged<String> onTextFieldValueSubmittedCallbackFunction;

  /// Additional instructions to insert in the onChanged method.
  final ValueChanged<String> additionalOnChangedInstructions;

  /// Additional instructions to insert in the onSubmitted method.
  final ValueChanged<String> additionalOnSubmittedInstructions;

  /// A map with String sanitizer bundles as keys, and error messages as values.
  final Map<StringSanitizerBundle, String> stringSanitizerBundlesErrorsMapping;

  /// A map with blacklisting functions as keys, and error messages as values.
  final Map<BlacklistingFunction,String> blacklistingFunctionsErrorsMapping;

  const TextFieldSanitizedAndCheckedUsingABlackList
  ({
    super.key,
    required this.textFieldStyle,
    required this.textFieldHint,
    required this.textFieldHintStyle,
    this.errorMessageKey = const Key('error_msg_key_default'),
    required this.errorMessageStyle,
    this.textFieldMinLines = 1,
    this.textFieldMaxLength = CAFormTextFieldMiscConstants.chars10Lines, // 10 lines as a reference
    this.textFieldCounter = TextFieldUtils.counterPresent,
    required this.onTextFieldValueSubmittedCallbackFunction,
    this.additionalOnChangedInstructions = placeHolderFunctionString,
    this.additionalOnSubmittedInstructions = placeHolderFunctionString,
    required this.stringSanitizerBundlesErrorsMapping,
    required this.blacklistingFunctionsErrorsMapping  
  });

  @override
  State<TextFieldSanitizedAndCheckedUsingABlackList> createState() => _TextFieldSanitizedAndCheckedUsingABlackListState();
}

class _TextFieldSanitizedAndCheckedUsingABlackListState extends State<TextFieldSanitizedAndCheckedUsingABlackList> 
{
  bool submitIsBlocked = false;  

  // Useful for automatic scrolling
  final GlobalKey<_TextFieldSanitizedAndCheckedUsingABlackListState> textFieldKey = GlobalKey();

  TextEditingController textFieldEditingController = .new();
  String _errorMessage = "";
  Timer? stringSanitizedErrorTimer;
  // A field used to store if sanitizing was done
  // Need to have a sanitizing error message displayed for long enough before blacklisting check.
  bool wasStringSanitized = false;

  @override
  void initState() {
    // Cancelling the time if the user modified the input
    stringSanitizedErrorTimer?.cancel();
    super.initState();
  }

  @override
  void dispose() 
  {
    textFieldEditingController.dispose();
    stringSanitizedErrorTimer?.cancel();
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

  // Method to call to modify the text field value if a " or line return is found
  // and to modify the error message to display.
  Future<void> userInputSanitizing(String text) async
  {
    // Does the user input needs sanitization and does the submit needs to be blocked?

    // Yes, because a blocking function returned true
    StringSanitizerBundle? bundleWithSanitizingFunctionThatReturnedTrue;
    if (widget.stringSanitizerBundlesErrorsMapping
        .keys
        .any
        (
          (stringSanitizerBundle)
          {
            var recordResult = stringSanitizerBundle(text);
            // Getting the info from the record
            bool shouldStringBeSanitized = recordResult.shouldStringBeSanitized;
            // Adding the sanitizing function to the list for later sanitizing
            if (shouldStringBeSanitized) 
            {
              // Storing to add a delay, for the error message to be displayed long enough to be read
              wasStringSanitized = true; 

              bundleWithSanitizingFunctionThatReturnedTrue = stringSanitizerBundle;
              if (textFieldDebugging) pu.printd("Text Field: bundleWithSanitizingFunctionThatReturnedTrue: $bundleWithSanitizingFunctionThatReturnedTrue");
            }
            return shouldStringBeSanitized;
          }
        )
        ) 
    {
      if (textFieldDebugging) pu.printd("Text Field: bundleWithSanitizingFunctionThatReturnedTrue: ${bundleWithSanitizingFunctionThatReturnedTrue.toString()}");
      
      // Blocking the submit
      submitIsBlocked = true;
      if (textFieldDebugging) pu.printd("Text Field: submitIsBlocked: $submitIsBlocked");

      // Sanitizing the input
      // DESIGN NOTES: after research, 
      // it seems that only straight double quote are used to delimit text when importing CSV files
      // var cleanedValue = value.replaceAll(TextFieldUtils.quoteChar, '');
      // Going through the list of sanitizing functions
      var cleanedValue = text;
      cleanedValue = bundleWithSanitizingFunctionThatReturnedTrue!(cleanedValue).sanitizingFunction(text);

      if (textFieldDebugging) pu.printd("Text Field: cleanedValue: $cleanedValue");
   
      setState(() 
      {
        // Updating the text editing controller's text with the sanitized input
        textFieldEditingController.text = cleanedValue;

        // Letting the user know that the input was sanitized
        _errorMessage = widget.stringSanitizerBundlesErrorsMapping[bundleWithSanitizingFunctionThatReturnedTrue]!;  
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
        View.of(context), _errorMessage, 
        TextDirection.ltr, assertiveness: Assertiveness.assertive
      );

      // Updating the parental widget information with the sanitized value
      // Un-related to onSubmit
      widget.onTextFieldValueSubmittedCallbackFunction(cleanedValue);

      // Unblocking the submit
      submitIsBlocked = false;
    } 

    // No, because no blocking function returned true
    else 
    {
      // Re-setting the variable
      wasStringSanitized = false; 

      if (textFieldDebugging) pu.printd("Text Field: No sanitizing needed: value: $text");

      // Removing the error message
      setState(() 
      {
        _errorMessage = "";        
      });

      // Updating the parental widget information with the value
      widget.onTextFieldValueSubmittedCallbackFunction(text);
    }
  }

  Future<void> userInputBlacklistCheck(String text) async
  {
    // Does the user input needs to be blacklisted and does the submit needs to be blocked?

    // Yes, because a blacklisting function returned true
    List<Function> blacklistingFunctionsReturnedTrueList = [];
    if (widget.blacklistingFunctionsErrorsMapping
        .keys
        .any
        (
          (blacklistingFunction)
          {
            bool shouldStringBeBlocked = blacklistingFunction(text);
            // Adding the sanitizing function to the list for later sanitizing
            if (shouldStringBeBlocked) 
            {
              blacklistingFunctionsReturnedTrueList.add(blacklistingFunction);
              if (textFieldDebugging) pu.printd("Text Field: Added to blacklistingFunctionsReturnedTrueList: ${blacklistingFunction.toString()}");
            }
            return shouldStringBeBlocked;
          }
        )
        ) 
    {
      if (textFieldDebugging) pu.printd("Text Field: blacklistingFunctionsReturnedTrueList: ${blacklistingFunctionsReturnedTrueList.toString()}");
      
      // Blocking the submit
      submitIsBlocked = true;
      if (textFieldDebugging) pu.printd("Text Field: submitIsBlocked: $submitIsBlocked");
   
      setState(() 
      {
        // Letting the user know that the input was blocked
        _errorMessage = widget.blacklistingFunctionsErrorsMapping[blacklistingFunctionsReturnedTrueList[0]]!;  
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
        View.of(context), _errorMessage, 
        TextDirection.ltr, assertiveness: Assertiveness.assertive
      );

      // Keeping the input blocked until new onChanged check
      // No need to update the parental widget
    } 

    // No, because no blacklisting function returned true
    else 
    {
      if (textFieldDebugging) pu.printd("Text Field: No blacklisting needed: value: $text");

      // Removing the error message, after delay if string was sanitized
      if (wasStringSanitized) 
      {
        if (textFieldDebugging) pu.printd("wasStringSanitized: $wasStringSanitized: Timer started");
        stringSanitizedErrorTimer = Timer
        (
          const Duration(
            seconds:5), 
            ()
            {
              setState(() { _errorMessage = "";});
            }
        );
      }
      // Otherwise, resetting the error message
      else
      {
        setState(() {_errorMessage = "";});
      }
      
      // Updating the parental widget information with the value
      widget.onTextFieldValueSubmittedCallbackFunction(text);
    }
  }

  // Method used for the onChanged named parameter
  onTextFieldValueChanged(String newValue) async
  {
    // By default, submit is not blocked
    submitIsBlocked = false;

    if (textFieldDebugging) pu.printd("Text Field: onChanged: submitIsBlocked: $submitIsBlocked");

    // Sanitizing the text, and resetting the error message if relevant
    await userInputSanitizing(newValue);

    // Checking if the text is part of a blacklist
    await userInputBlacklistCheck(newValue);

    // Additional onChanged instructions 
    widget.additionalOnChangedInstructions(newValue);
  }

  // Method used for the onSubmitted named parameter
  onTextFieldValueSubmitted(String newValue)
  {
    // Additional onSubmitted instructions 
    widget.additionalOnSubmittedInstructions(newValue);

    if (textFieldDebugging) pu.printd("Text Field: onSubmitted: submitIsBlocked: $submitIsBlocked");
    // Data submission if not blocked
    if (!submitIsBlocked) {
      widget.onTextFieldValueSubmittedCallbackFunction(newValue);
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
              _errorMessage, 
              style: widget.errorMessageStyle
            )
          ),
          errorMaxLines: 3
      ),
      onChanged: onTextFieldValueChanged,
      onSubmitted: (!submitIsBlocked) ?  onTextFieldValueSubmitted : null,  
      // on iOS, allows to dismiss the text field keyboard, if tapping outside the text field
      onTapOutside: (PointerDownEvent event) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}