import 'package:flutter/material.dart';

import '../utils/typedefs.dart';
import '../utils/placeholder_functions.dart';

// new category to consider
/// {@category Utils - Generic}
/// A widget used to edit text in a list.
class EditableListText extends StatefulWidget {

  /// The text to display.
  final String text;

  /// The style for the text to display.
  final TextStyle textStyle;

  /// The index of the list item in the tree structure.
  final int listItemIndex;

  /// The left padding for the text field.
  final double paddingLeft;

  /// The right padding for the text field.
  final double paddingRight;

  /// The top padding for the text field.
  final double paddingTop;

  /// The bottom padding for the text field.
  final double paddingBottom;

  /// Callback function used to update the list item value
  final FunctionStringAndInt parentCallbackFunctionToUpdateTheListItemValue;

  const EditableListText
  ({
    required this.text,
    required this.listItemIndex,
    this.textStyle = const TextStyle(fontWeight: FontWeight.bold), 
    this.paddingBottom = 8,
    this.paddingTop = 8,
    this.paddingLeft = 16,
    this.paddingRight = 16,
    this.parentCallbackFunctionToUpdateTheListItemValue = placeHolderFunctionStringAndInt,
    super.key
  });

  @override
  State<EditableListText> createState() => _EditableListTextState();
}

class _EditableListTextState extends State<EditableListText> 
{
  var _isEdited = false;
  var _tecEdition = TextEditingController();

  @override
  void dispose() {
    _tecEdition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
    _isEdited
    ?
    // Text field if edition mode
    TextField
    (
      controller: _tecEdition,
      decoration: InputDecoration
      (                    
        contentPadding: EdgeInsets.only
        (
          bottom: widget.paddingBottom, top: widget.paddingTop,
          left: widget.paddingLeft, right: widget.paddingRight
        ),
      ),
      textAlign: TextAlign.left,
      onSubmitted: 
        (value) => setState(() 
        {
          _isEdited = false;
          _tecEdition.clear();
          widget.parentCallbackFunctionToUpdateTheListItemValue(stringParam: value, intParam: widget.listItemIndex);
        }),
      
    )
    :
    // Text with gesture detection outside of edition mode
    GestureDetector
    (
      child:
        Text(widget.text, style: widget.textStyle),
        onTap: () 
            {
              print("GestureDetector: onTap");

              setState(() 
              {
                _isEdited = true;
                _tecEdition.text = widget.text;
              });
            }
    );
  }
}