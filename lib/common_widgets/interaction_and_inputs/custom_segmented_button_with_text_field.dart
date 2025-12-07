import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_padded_text_field.dart';

class CustomSegmentedButtonWithTextField extends StatefulWidget 
{
  /// The first option of the segmented button 
  final String textOption1;
  /// The second option of the segmented button 
  final String textOption2;
  /// The optional third option of the segmented button 
  final String textOption3;
  /// The boolean related to enabling multiselection
  final bool multiSelectionEnabled;
  /// The boolean related to allowing empty selection
  final bool emptySelectionAllowed;
  // The font size for the text options
  final double textOptionsfontSize;
  /// The color of the text options
  final Color textOptionsColor;
  /// The callback function to notify the parent widget of selection changes
  final ValueChanged<Set<String>>? onSelectionChanged;
  /// The callback function to notify the parent widget of selection changes
  final ValueChanged<String>? onTextChanged;
  /// The text field editing controller
  final TextEditingController textFieldEditingController;
  /// The text of the text field place holder
  final String textFieldPlaceholder;
  /// The left and right padding value for the text field
  final double textFieldHorizontalPadding;
  /// The bottom padding value for the text field
  final double textFieldBottomPadding;
  /// The minLines value for the text field 
  final int textFieldMinLines;
  /// The maxLines value for the text field 
  final int textFieldMaxLines;
  /// The cross axis alignment for the segmented button, and the text field
  final CrossAxisAlignment inputsCrossAxisAlignment;


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
    required this.onSelectionChanged,
    required this.onTextChanged,
    required this.textFieldEditingController,
    this.textFieldPlaceholder  = "Please develop or take some notes if relevant.",
    this.textFieldHorizontalPadding = 20.0,
    this.textFieldBottomPadding = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.inputsCrossAxisAlignment = CrossAxisAlignment.start,
     
  });

  @override
  State<CustomSegmentedButtonWithTextField> createState() => _CustomSegmentedButtonWithTextFieldState();
}

class _CustomSegmentedButtonWithTextFieldState extends State<CustomSegmentedButtonWithTextField> 
{
  Set<String> selection = {};
    
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
      crossAxisAlignment: widget.inputsCrossAxisAlignment,
      children: [
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
          selected: selection,
          onSelectionChanged: (newSelection) 
          {
            setState(() 
            {
              selection = newSelection;
            });
            
            // external callback so the parent knows the new selection
            widget.onSelectionChanged?.call(newSelection);
          },
        ),        
        if (selection.isNotEmpty)

          Padding
          (
            padding: EdgeInsets.only(left: widget.textFieldHorizontalPadding, right: widget.textFieldHorizontalPadding, bottom: widget.textFieldBottomPadding),
            child: CustomPaddedTextField(textFieldInputDecoration: InputDecoration(hintText: widget.textFieldPlaceholder), 
            textFieldEditingController: widget.textFieldEditingController, textFieldOnChangedCallbackFunction: widget.onTextChanged,
            textFieldMinLines:widget.textFieldMinLines, textFieldMaxLines:widget.textFieldMaxLines)
            
          ),
      ],
    );
  }
}