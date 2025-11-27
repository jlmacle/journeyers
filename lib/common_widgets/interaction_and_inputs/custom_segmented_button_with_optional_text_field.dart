import 'package:flutter/material.dart';

class CustomSegmentedButtonWithOptionalTextField extends StatefulWidget {
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
  /// The list of values that, when checked, lead to displaying a text field
  final List<String> textFieldFor;
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
  /// The callback function to notify the parent widget of selection changes
  final ValueChanged<Set<String>>? onSelectionChanged;

  const CustomSegmentedButtonWithOptionalTextField({
    super.key,
    required this.textOption1,
    required this.textOption2,
    this.textOption3 = "undefined",
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = true,
    this.textOptionsfontSize = 24,
    this.textOptionsColor = Colors.black,
    this.textFieldFor = const ["I don't know"],
    this.textFieldPlaceholder  = "Please develop or take some notes if relevant.",
    this.textFieldHorizontalPadding = 20.0,
    this.textFieldBottomPadding = 10.0,
    this.textFieldMinLines = 1,
    this.textFieldMaxLines = 10,
    this.onSelectionChanged, 
  });

  @override
  State<CustomSegmentedButtonWithOptionalTextField> createState() => _CustomSegmentedButtonWithOptionalTextFieldState();
}

class _CustomSegmentedButtonWithOptionalTextFieldState extends State<CustomSegmentedButtonWithOptionalTextField> {
  Set<String> selection = {};
  
  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: widget.textOptionsfontSize,
      color: widget.textOptionsColor,
    );

    return Column(
      children: [
        SegmentedButton<String>(
          multiSelectionEnabled: widget.multiSelectionEnabled,
          emptySelectionAllowed: widget.emptySelectionAllowed,
          segments: <ButtonSegment<String>>[
            ButtonSegment<String>(
              value: widget.textOption1,          
              label: Text(
                widget.textOption1,
                style: textStyle,
              ),
            ),
            ButtonSegment<String>(
              value: widget.textOption2,
                label: Text(
                widget.textOption2,
                style: textStyle,
              ),
            ),
            if (widget.textOption3 != "undefined")
              ButtonSegment<String>(
                value: widget.textOption3,          
                label: Text(
                  widget.textOption3,
                  style: textStyle,
                ),
              ),
          ],
          selected: selection,
          onSelectionChanged: (newSelection) {
            setState(() {
              selection = newSelection;
            });
            
            // external callback so the parent knows the new selection
            widget.onSelectionChanged?.call(newSelection);
          },
        ),
       // if (selection.contains('No') | selection.contains("I don't know"))
        if (selection.any((item) => widget.textFieldFor.contains(item)))

          Padding(
            padding: EdgeInsets.only(left: widget.textFieldHorizontalPadding, right: widget.textFieldHorizontalPadding, bottom: widget.textFieldBottomPadding),
            child: TextField(             
              decoration: InputDecoration(hintText: widget.textFieldPlaceholder),
              minLines: widget.textFieldMinLines,
              maxLines: widget.textFieldMaxLines,
            ),
          ),
      ],
    );
  }
}