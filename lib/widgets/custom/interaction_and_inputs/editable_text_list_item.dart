import "package:flutter/material.dart";

import "package:journeyers/widgets/utility/lists/tmp_utility_widgets/type_defs2.dart";
import "../../../utils/generic/dev/placeholder_functions.dart";

/// {@category Utils - Generic}
/// {@category Lists}
/// A widget used to edit text items in a list.
class EditableTextListItem extends StatefulWidget {

  /// The index of the list item.
  final int itemIndex;

  /// The item text.
  final String itemText;

  /// The style for the text to display.
  final TextStyle itemTextStyle;  

  /// The left padding for the text field.
  final double paddingLeft;

  /// The right padding for the text field.
  final double paddingRight;

  /// The top padding for the text field.
  final double paddingTop;

  /// The bottom padding for the text field.
  final double paddingBottom;

  /// Callback function used to update the list item value.
  final FunctionStringAndInt parentCallbackFunctionToUpdateTheListItemValue;

  const EditableTextListItem
  ({
    required this.itemText,
    required this.itemIndex,
    this.itemTextStyle = const TextStyle(fontWeight: FontWeight.bold), 
    this.paddingBottom = 8,
    this.paddingTop = 8,
    this.paddingLeft = 16,
    this.paddingRight = 16,
    this.parentCallbackFunctionToUpdateTheListItemValue = placeHolderFunctionStringAndInt,
    super.key
  });

  @override
  State<EditableTextListItem> createState() => _EditableTextListItemState();
}

class _EditableTextListItemState extends State<EditableTextListItem> 
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
          widget.parentCallbackFunctionToUpdateTheListItemValue(stringParam: value, intParam: widget.itemIndex);
        }),
      
    )
    :
    // Text with gesture detection outside of edition mode
    GestureDetector
    (
      child:
        Text(widget.itemText, style: widget.itemTextStyle),
        onTap: () 
            {
              setState(() 
              {
                _isEdited = true;
                _tecEdition.text = widget.itemText;
              });
            }
    );
  }
}