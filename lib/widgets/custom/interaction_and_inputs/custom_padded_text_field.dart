import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_consts.dart';

/// {@category Custom widgets}
/// A customizable text field with customizable padding.
/// An error message is displayed if a straight double quote is entered in the text field.
/// Also, the straight double quote is automatically removed from the text field.
class CustomPaddedTextField extends StatefulWidget 
{
  /// If the text field maintains state, when the checkbox is unchecked for example.
  final bool maintainState;
  /// The start value for the text field.
  final String textFieldStartValue;

  /// The alignment of the text.
  final TextAlign textAlignment;

  /// The hint text for the text field.
  final String textFieldHint;

  /// The minLines value for the text field.
  final int textFieldMinLines;

  /// The maxLines value for the text field.
  final int textFieldMaxLines;

  /// The maxLength value for the text field.
  final int textFieldMaxLength;

  /// The counter for the text field.
  final InputCounterWidgetBuilder textFieldCounter;

  /// The text field-related callback function for the parent widget.
  final ValueChanged<String> parentTextFieldValueCallBackFunction;

  /// The left padding for the text field.
  final double paddingLeft;

  /// The right padding for the text field.
  final double paddingRight;

  /// The top padding for the text field.
  final double paddingTop;

  /// The bottom padding for the text field.
  final double paddingBottom;

  const CustomPaddedTextField
  ({
    super.key,
    this.maintainState = true,
    this.textFieldStartValue = "",
    this.textAlignment = TextAlign.center,
    required this.textFieldHint,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.textFieldMaxLength = chars10Lines, // 10 lines as a reference
    this.textFieldCounter = TextFieldUtils.presentCounter,
    this.parentTextFieldValueCallBackFunction = placeHolderFunctionString,
    this.paddingLeft = 20,
    this.paddingRight = 20,
    this.paddingTop = 10,
    this.paddingBottom = 10,
  });

  @override
  State<CustomPaddedTextField> createState() => _CustomPaddedTextFieldState();
}

class _CustomPaddedTextFieldState extends State<CustomPaddedTextField> 
{
  // The variable to update when a double quote has been found
  String _errorMessageForDoubleQuotes = "";
  final GlobalKey<_CustomPaddedTextFieldState> textFieldBeforeErrorMessageKey = GlobalKey();
  TextEditingController textFieldEditingController = .new();
  TextSelection? _currentTextSelection;
  bool _wasCharacterReplacedAtPreviousTyping = false;

  // Method used to scroll the error message into view
  Future<void> _scrollForBetterErrorViewing() async
  {
    final context = textFieldBeforeErrorMessageKey.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() 
  {
    super.initState();
    textFieldEditingController.text = widget.textFieldStartValue;
  }

  @override
  void dispose() 
  {
    textFieldEditingController.dispose();
    super.dispose();
  }

  // The method to call to modify the text field value if a " or line return is found
  // and to modify the error message to display
  void quoteAndLineReturnCheck(value) async
  {
   if (value.contains('"') || value.contains('\n')) 
    {
      // DESIGN NOTES: after research, it seems that only straight double quote are used to delimit text when importing CSV files
      value = value.replaceAll('"', '');
      value = value.replaceAll('\n', ''); 
      _wasCharacterReplacedAtPreviousTyping = true;
      // Removes the quotes or line returns from the text field
      textFieldEditingController.text = value;
      // Updates the error message
      _errorMessageForDoubleQuotes = 
      'Straight double quotes\nand line returns\nare removed from the text typed\nfor CSV-export reasons.\nWith apologies.';
      // Scrolling for better error message viewing
      await _scrollForBetterErrorViewing();
      setState(() {});
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
      // Updates the parental widget information on the text content
      widget.parentTextFieldValueCallBackFunction(value);
    } 
    // Neither " nor \n
    // Could be a character deletion
    else 
    {
      if (_wasCharacterReplacedAtPreviousTyping)
      {
        setState(() 
        {
          // To keep the cursor's position when deleting characters
          textFieldEditingController.selection = _currentTextSelection!;
          _errorMessageForDoubleQuotes = "";        
        });
        widget.parentTextFieldValueCallBackFunction(value);
        _wasCharacterReplacedAtPreviousTyping = false;
      }
      else 
      {
        setState(() 
        {
          _wasCharacterReplacedAtPreviousTyping = false; 
        });
      }      
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return 
    Padding
    (
      padding: EdgeInsets.only(left: widget.paddingLeft, right: widget.paddingRight, bottom: widget.paddingBottom, top: widget.paddingTop),
      child: 
      TextField
      (
        key: textFieldBeforeErrorMessageKey,
        style: analysisTextFieldStyle,
        textAlign: widget.textAlignment,
        controller: textFieldEditingController,
        decoration: 
        InputDecoration
        (
          hintText: widget.textFieldHint,
          error: Center(child: Text(textAlign: TextAlign.center, _errorMessageForDoubleQuotes , style: analysisTextFieldErrorStyle)),
          errorMaxLines: 3
        ),
        minLines: widget.textFieldMinLines,
        maxLines: widget.textFieldMaxLines,
        maxLength: widget.textFieldMaxLength,
        buildCounter: widget.textFieldCounter,
        onChanged: (String newValue) 
        {
          _currentTextSelection = textFieldEditingController.selection;          
          quoteAndLineReturnCheck(newValue); // updates textFieldEditingController.text
          if (widget.maintainState) widget.parentTextFieldValueCallBackFunction(textFieldEditingController.text);
        },
        // on iOS, allows to dismiss the text field keyboard, if tapping outside the text field
        onTapOutside: (PointerDownEvent event) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
    );
  }
}
