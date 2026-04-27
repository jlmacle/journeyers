import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/_context_analysis_form_text_field_misc_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_custom_text_field_sanitized_and_padded.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart' as tfu_proj;


/// {@category Context analysis}
/// A segmented button that displays a text field when a value is selected.
/// The text field has string sanitization, and removes straight quotes, for CSV export reason. 
class CASegmentedButtonWithSanitizedAndPaddedTextField extends StatefulWidget 
{
  /// The first option of the segmented button.
  final String segButtonTextOption1;

  /// The second option of the segmented button.
  final String segButtonTextOption2;

  /// The optional third option of the segmented button.
  final String segButtonTextOption3;

  /// The font size for the text options.
  final double segButtonTextOptionsfontSize;

  /// The color of the text options.
  final Color segButtonTextOptionsColor;

  /// The boolean related to enabling multiselection.
  final bool segButtonMultiSelectionEnabled;

  /// The boolean related to allowing an empty selection.
  final bool segButtonEmptySelectionAllowed;

  /// The start value for the segmented button.
  final Set<String> segButtonStartValue;

  /// The start value for the text field.
  final String textFieldStartValue;

  /// The hint text for the text field.
  final String textFieldHint;

  /// The left and right padding value for the text field.
  final double textFieldPaddingHorizontal;

  /// The bottom padding value for the text field.
  final double textFieldPaddingBottom;

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

  /// The segmented button-related callback function for the parent widget.
  final ValueChanged<Set<String>>
  parentSegmentedButtonValueCallBackFunction;

  const CASegmentedButtonWithSanitizedAndPaddedTextField
  ({
    super.key,
    required this.segButtonTextOption1,
    required this.segButtonTextOption2,
    this.segButtonTextOption3 = "undefined",
    this.segButtonMultiSelectionEnabled = true,
    this.segButtonEmptySelectionAllowed = true,
    this.segButtonTextOptionsfontSize = 24,
    this.segButtonTextOptionsColor = Colors.black,
    this.segButtonStartValue = const {},
    this.textFieldStartValue = "",
    required this.textFieldHint,
    this.textFieldPaddingHorizontal = 20.0,
    this.textFieldPaddingBottom = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.textFieldMaxLength = CAFormTextFieldMiscConstants.chars1Page, // a page as a reference
    this.textFieldCounter = TextFieldUtils.counterAbsent,
    this.parentTextFieldValueCallBackFunction = placeHolderFunctionString,
    this.parentSegmentedButtonValueCallBackFunction =
        placeHolderFunctionSetString,
  });

  @override
  State<CASegmentedButtonWithSanitizedAndPaddedTextField> createState() => _CASegmentedButtonWithSanitizedAndPaddedTextFieldState();
}

class _CASegmentedButtonWithSanitizedAndPaddedTextFieldState extends State<CASegmentedButtonWithSanitizedAndPaddedTextField> 
{
  Set<String>? _selection;
  String _textFieldValue = "";

  @override
  void initState() {
    _selection = widget.segButtonStartValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) 
  {
    final TextStyle textStyle = 
                    TextStyle
                    (
                      fontSize: widget.segButtonTextOptionsfontSize,
                      color: widget.segButtonTextOptionsColor,
                    );

    return 
    Column
    (
      crossAxisAlignment: CrossAxisAlignment.center,
      children: 
      [
        SegmentedButton<String>
        (
          multiSelectionEnabled: widget.segButtonMultiSelectionEnabled,
          emptySelectionAllowed: widget.segButtonEmptySelectionAllowed,
          segments: 
          <ButtonSegment<String>>
          [
            ButtonSegment<String>
            (
              value: widget.segButtonTextOption1,
              label: Text(widget.segButtonTextOption1, style: textStyle),
            ),
            ButtonSegment<String>
            (
              value: widget.segButtonTextOption2,
              label: Text(widget.segButtonTextOption2, style: textStyle),
            ),
            if (widget.segButtonTextOption3 != "undefined")
              ButtonSegment<String>
              (
                value: widget.segButtonTextOption3,
                label: Text(widget.segButtonTextOption3, style: textStyle),
              ),
          ],
          onSelectionChanged: (newSelection) 
          {
            setState(() {_selection = newSelection;});
            widget.parentSegmentedButtonValueCallBackFunction(newSelection);
          },
          selected: _selection!,
        ),
        if (_selection!.isNotEmpty)
          Padding
          (
            padding: EdgeInsets.only(left: widget.textFieldPaddingHorizontal, right: widget.textFieldPaddingHorizontal, bottom: widget.textFieldPaddingBottom),
            child: 
            CATextFieldSanitizedAndPadded
            (
              stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
              textFieldStartValue: _textFieldValue,
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: widget.textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorMessageStyle,
              onTextFieldValueSubmittedCallbackFunction: 
                (String text)
                {
                  widget.parentTextFieldValueCallBackFunction(text); 
                  setState(() {_textFieldValue = text;});
                },
              textFieldMinLines: widget.textFieldMinLines,
              textFieldCounter: widget.textFieldCounter,
            ),
          ),
      ],
    );
  }
}
