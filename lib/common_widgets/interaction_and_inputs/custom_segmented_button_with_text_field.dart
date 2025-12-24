import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_padded_text_field.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';

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
  final String textFieldHintText;
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
  /// The cross axis alignment for the segmented button, and the text field.
  final CrossAxisAlignment customWidgetsCrossAxisAlignment;
  /// The text field-related callback function for the parent widget.
  final ValueChanged<String> parentWidgetTextFieldValueCallBackFunction;
  /// The segmented button-related callback function for the parent widget.
  final ValueChanged<Set<String>> parentWidgetSegmentedButtonValueCallBackFunction;

  /// A placeholder void callback function with a String parameter.
  static void placeHolderFunctionString(String value) {}
  /// A placeholder void callback function with a Set<String>? parameter.
  static void placeHolderFunctionSetString(Set<String>? values) {}

  /// {@category Custom widgets}
  const CustomSegmentedButtonWithTextField
  ({
    super.key,
    required this.textOption1,
    required this.textOption2,
    this.textOption3 = "undefined",
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = true,
    this.textOptionsfontSize = 24,
    this.textOptionsColor = Colors.black,
    required this.textFieldHintText,
    this.textFieldPaddingHorizontal = 20.0,
    this.textFieldPaddingBottom = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.textFieldMaxLength = FormUtils.chars1Page, // a page as a reference
    this.textFieldCounter = FormUtils.absentCounter,
    this.customWidgetsCrossAxisAlignment = CrossAxisAlignment.start,
    this.parentWidgetTextFieldValueCallBackFunction = placeHolderFunctionString,
    this.parentWidgetSegmentedButtonValueCallBackFunction = placeHolderFunctionSetString     
  });

  @override
  State<CustomSegmentedButtonWithTextField> createState() => _CustomSegmentedButtonWithTextFieldState();
}

class _CustomSegmentedButtonWithTextFieldState extends State<CustomSegmentedButtonWithTextField> 
{
  Set<String> _selection = {};

  @override
  Widget build(BuildContext context) 
  {
    final TextStyle textStyle = TextStyle
    (
      fontSize: widget.textOptionsfontSize,
      color: widget.textOptionsColor,
    );

    return Column
    (
      crossAxisAlignment: widget.customWidgetsCrossAxisAlignment,
      children: 
      [
        SegmentedButton<String>
        (
          multiSelectionEnabled: widget.multiSelectionEnabled,
          emptySelectionAllowed: widget.emptySelectionAllowed,
          
          segments: <ButtonSegment<String>>[
            ButtonSegment<String>(
              value: widget.textOption1,      
              label: Text
              (
                widget.textOption1,
                style: textStyle,
              ),
            ),
            ButtonSegment<String>
            (
              value: widget.textOption2,
              label: Text
              (
                widget.textOption2,
                style: textStyle,
              ),
            ),
            if (widget.textOption3 != "undefined")
              ButtonSegment<String>
              (
                value: widget.textOption3,          
                label: Text
                (
                  widget.textOption3,
                  style: textStyle,
                ),
              ),
          ],
          onSelectionChanged: (newSelection) 
          {
            setState(() 
            {
              _selection = newSelection;
            });            
            widget.parentWidgetSegmentedButtonValueCallBackFunction(newSelection);
          },
          selected: _selection,
        ),        
        if (_selection.isNotEmpty)
          Padding
          (
            padding: EdgeInsets.only(left: widget.textFieldPaddingHorizontal, right: widget.textFieldPaddingHorizontal, bottom: widget.textFieldPaddingBottom),
            child: CustomPaddedTextField(textFieldHintText: widget.textFieldHintText,  
            parentWidgetTextFieldValueCallBackFunction: widget.parentWidgetTextFieldValueCallBackFunction, 
            textFieldMinLines:widget.textFieldMinLines, textFieldMaxLines:widget.textFieldMaxLines, textFieldCounter: widget.textFieldCounter)            
          ),
      ],
    );
  }
}