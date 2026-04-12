import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_consts.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_checked_and_padded.dart';


/// {@category Custom widgets}
/// A customizable segmented button that displays a customizable text field when a value is selected.
class CustomSegmentedButtonWithTextField extends StatefulWidget 
{
  /// The first option of the segmented button.
  final String textOption1;

  /// The second option of the segmented button.
  final String textOption2;

  /// The optional third option of the segmented button.
  final String textOption3;

  /// The font size for the text options.
  final double textOptionsfontSize;

  /// The color of the text options.
  final Color textOptionsColor;

  /// The boolean related to enabling multiselection.
  final bool multiSelectionEnabled;

  /// The boolean related to allowing an empty selection.
  final bool emptySelectionAllowed;

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

  const CustomSegmentedButtonWithTextField
  ({
    super.key,
    required this.textOption1,
    required this.textOption2,
    this.textOption3 = "undefined",
    this.multiSelectionEnabled = true,
    this.emptySelectionAllowed = true,
    this.textOptionsfontSize = 24,
    this.textOptionsColor = Colors.black,
    required this.textFieldHint,
    this.textFieldPaddingHorizontal = 20.0,
    this.textFieldPaddingBottom = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.textFieldMaxLength = chars1Page, // a page as a reference
    this.textFieldCounter = TextFieldUtils.absentCounter,
    this.parentTextFieldValueCallBackFunction = placeHolderFunctionString,
    this.parentSegmentedButtonValueCallBackFunction =
        placeHolderFunctionSetString,
  });

  @override
  State<CustomSegmentedButtonWithTextField> createState() => _CustomSegmentedButtonWithTextFieldState();
}

class _CustomSegmentedButtonWithTextFieldState extends State<CustomSegmentedButtonWithTextField> 
{
  Set<String> _selection = {};
  String _textFieldValue = "";

  @override
  Widget build(BuildContext context) 
  {
    final TextStyle textStyle = 
                    TextStyle
                    (
                      fontSize: widget.textOptionsfontSize,
                      color: widget.textOptionsColor,
                    );

    return 
    Column
    (
      crossAxisAlignment: CrossAxisAlignment.center,
      children: 
      [
        SegmentedButton<String>
        (
          multiSelectionEnabled: widget.multiSelectionEnabled,
          emptySelectionAllowed: widget.emptySelectionAllowed,
          segments: 
          <ButtonSegment<String>>
          [
            ButtonSegment<String>
            (
              value: widget.textOption1,
              label: Text(widget.textOption1, style: textStyle),
            ),
            ButtonSegment<String>
            (
              value: widget.textOption2,
              label: Text(widget.textOption2, style: textStyle),
            ),
            if (widget.textOption3 != "undefined")
              ButtonSegment<String>
              (
                value: widget.textOption3,
                label: Text(widget.textOption3, style: textStyle),
              ),
          ],
          onSelectionChanged: (newSelection) 
          {
            setState(() {_selection = newSelection;});
            widget.parentSegmentedButtonValueCallBackFunction(newSelection);
          },
          selected: _selection,
        ),
        if (_selection.isNotEmpty)
          Padding
          (
            padding: EdgeInsets.only(left: widget.textFieldPaddingHorizontal, right: widget.textFieldPaddingHorizontal, bottom: widget.textFieldPaddingBottom),
            child: 
            TextFieldCheckedAndPadded
            (
              blockingFunctionsErrorMessagesMapping: TextFieldUtils.stringSanitizerBundlesErrorsMap,
              textFieldStartValue: _textFieldValue,
              textFieldStyle: analysisTextFieldStyle,
              textFieldHint: widget.textFieldHint,
              textFieldHintStyle: analysisTextFieldHintStyle,
              errorMessageStyle: analysisTextFieldErrorStyle,
              parentTextFieldValueCallBackFunction: 
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
