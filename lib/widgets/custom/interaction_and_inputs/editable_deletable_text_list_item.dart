import 'package:flutter/material.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/type_defs2.dart';

/// {@category Utils - Generic}
/// {@category Lists}
/// A widget used to edit and delete text items in a list.
class EditableDeletableTextListItem extends StatefulWidget {

  /// The index of the list item.
  final int itemIndex;

  /// The item text.
  final String itemText;

  /// The theme data used.
  final ThemeData themeData;

  /// The left padding for the text field.
  final double paddingLeft;

  /// The right padding for the text field.
  final double paddingRight;

  /// The top padding for the text field.
  final double paddingTop;

  /// The bottom padding for the text field.
  final double paddingBottom;

  /// A callback function called when the checkbox is checked/unchecked.
  final FunctionNullableBoolAndInt onCheckboxChangedCallbackFunction;

  /// Callback function used to update the list item value.
  final FunctionStringAndInt parentCallbackFunctionToUpdateTheListItemValue;

  /// Callback function used to update the list of items selected for deletion.
  final ValueChanged<int> parentCallbackFunctionToUpdateTheListOfItemsSelectedForDeletion;

  /// {@category Utils - Generic}
  /// {@category Lists}
  /// Widget used for text list items that are editable.
  const EditableDeletableTextListItem
  ({
    super.key,
    required this.itemIndex,
    required this.itemText,
    this.paddingBottom = 8,
    this.paddingTop = 8,
    this.paddingLeft = 16,
    this.paddingRight = 16,
    required this.onCheckboxChangedCallbackFunction,
    required this.parentCallbackFunctionToUpdateTheListItemValue,
    required this.parentCallbackFunctionToUpdateTheListOfItemsSelectedForDeletion,
    required this.themeData
  });

  @override
  State<EditableDeletableTextListItem> createState() => _EditableDeletableTextListItemState();
}

class _EditableDeletableTextListItemState extends State<EditableDeletableTextListItem> {

  // for the checkbox state
  bool _isChecked = false;

  bool _isEdited = false;

  var _tecEdition = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return 
    Row(
      children: 
      [
        if (!_isEdited)
          // Not an edition mode: checkbox + text + edit icon
          ...
          [
            // Checkbox for list item deletion
            Checkbox
            (
              value: _isChecked, 
              onChanged: 
                (value)
                {
                  // Updating the checkbox state
                  setState(() {_isChecked = !_isChecked;});

                  // Adding the item index to the selection to delete
                  widget.onCheckboxChangedCallbackFunction
                  (
                    boolParam: value,
                    intParam: widget.itemIndex
                  );
                  
                  
                  // _textsSelectedForDeletion.add(_enteredTextItemsList[index]);
                  // print("Selected for deletion: $_textsSelectedForDeletion");
                }
            ),
            // List tile for reading/to start edition 
            // Expanded for constraints
            Expanded(
              child: ListTile
              (
                key: Key('text${widget.itemIndex}'),
                dense: true,
                leading: Text(
                  '${widget.itemIndex + 1}.',
                  style: widget.themeData.textTheme.bodySmall,
                ),                            
                title: Text(
                  widget.itemText,
                  style: widget.themeData.textTheme.titleMedium,
                ),
                trailing: const Icon(Icons.edit),
                onTap: () 
                {
                  setState(() 
                  {
                    _isEdited = true; 
                    _tecEdition.text = widget.itemText;
                  });
                },
              ),
            )
          ]
          // edition mode
          else
          Expanded(
            child: TextField
            (
              controller: _tecEdition,
              autofocus: true,
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
              
            ),
          )   
        ],
      );
  }
}