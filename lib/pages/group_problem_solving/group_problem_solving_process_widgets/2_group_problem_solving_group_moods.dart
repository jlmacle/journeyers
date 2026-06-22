// ignore: file_names
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';

/// {@category Group problem-solving}
/// A widget used to monitor the moods of the stakeholders involved in the group problem-solving process.
class GPSGroupMoods extends StatefulWidget 
{
  /// The number of the column where the GPSGroupMoods instance is located (1 for the left side of the UI, 2 for the right side).
  final int columnNumber;

  /// The key for the first GPSGroupMoods widget.
  final GlobalKey groupMoodsKey1;

  /// The key for the second GPSGroupMoods widget.
  final GlobalKey groupMoodsKey2;

  /// The list of stakeholders identifiers for the first column.
  final List<String> identifiersCol1;

  /// The list of stakeholders identifiers for the second column.
  final List<String> identifiersCol2;

  /// The list of stakeholders identifiers' colors for the first column.
  final List<Color> identifiersColors1;

  /// The list of stakeholders identifiers' colors for the second column.
  final List<Color> identifiersColors2;

  /// Mode for editing a stakeholder identifier.
  final bool isEditMode;

  /// Mode for deleting a stakeholder identifier.
  final bool isDeleteMode;

  /// A callback function called to refresh the process page.
  final FutureVoidCallback gpsProcessCallbackFunctionToRefreshThePage;

  const GPSGroupMoods
  ({
    super.key,
    required this.columnNumber,
    required this.groupMoodsKey1,
    required this.groupMoodsKey2,
    required this.identifiersCol1,
    required this.identifiersCol2,
    required this.identifiersColors1,
    required this.identifiersColors2,
    required this.isEditMode,
    required this.isDeleteMode,
    required this.gpsProcessCallbackFunctionToRefreshThePage
  });

  @override
  State<GPSGroupMoods> createState() => GPSGroupMoodsState();
}

class GPSGroupMoodsState extends State<GPSGroupMoods> 
{
  // TODO: import of previous teams

  // Boolean used to store if a swipe left of right has happened
  bool? _wasARightSwipe;
  
  // Callback function used to update the wasARightSwipe field
  final ValueChanged<bool> _onSwipe = placeHolderFunctionBool;

  // Method used to trigger a re-build
  void _updateData()
  {
    setState(() {});
  }

  // Method used to add stakeholder identifiers
  // Important: the knowledge of the state of both list (and colors) of identifiers is needed
  void _addToIdentifiers()
  {
    // There should be as much identifiers in the first column,
    // as in the second.

    // Adding to col 1
    int totalIndexes = widget.identifiersCol1.length + widget.identifiersCol2.length;
    if (widget.identifiersCol1.length <= widget.identifiersCol2.length) 
    {
      widget.identifiersCol1.add("$totalIndexes");
      // All identifiers are green by default
      widget.identifiersColors1.add(greenShade900);
      widget.groupMoodsKey1.currentState?.setState(() {});
    }
    else 
    {
      widget.identifiersCol2.add("$totalIndexes");
      // All identifiers are green by default
      widget.identifiersColors2.add(greenShade900);
      widget.groupMoodsKey2.currentState?.setState(() {});
    }    
  }

  // Function used to remove a stakeholder identifier
  void _removeIdentifier({int? index}) 
      => setState(() 
                  {
                    if (widget.columnNumber == 1) 
                    {
                      widget.identifiersCol1.removeAt(index!);
                      widget.identifiersColors1.removeAt(index);
                    }
                    else {
                      widget.identifiersCol2.removeAt(index!);
                      widget.identifiersColors2.removeAt(index);
                    }
                  });

  // Function used to edit a stakeholder identifier
  void _editIdentifier({int? index}) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = .new();
        if (widget.columnNumber == 1) 
        {
          controller.text = widget.identifiersCol1[index!];
        }
        else 
        {
          controller.text = widget.identifiersCol2[index!];
        }
        return AlertDialog(
          title: const Text(editIdentifierLabel),
          content: TextField
          (
            controller: controller, 
            autofocus: true,
            keyboardType: TextInputType.name,
            onSubmitted: (_) async
                        {
                            // Updating the identifier                            
                            setState(() 
                                      { 
                                        if (widget.columnNumber == 1) 
                                        {
                                          widget.identifiersCol1[index] = controller.text;
                                        }
                                        else {widget.identifiersCol2[index] = controller.text;}
                                      });

                            Navigator.pop(context);
                          },
            ),
          actions: [
            TextButton(
              onPressed: () async {
                // Updating the identifier                            
                setState(() 
                          { 
                            if (widget.columnNumber == 1) 
                            {
                              widget.identifiersCol1[index] = controller.text;
                            }
                            else {widget.identifiersCol2[index] = controller.text;}
                          });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  // Method used to update if a swipe happened
  void _swipeStateUpdate(bool isSwipeRight)
  {
    setState(() {_wasARightSwipe = isSwipeRight;});  
  }

  // Function used to change a stakeholder identifier's color
  void _changeIdentifierColor({required int index, required Color currentColor}) 
  { 
    int colorIndex = identifierColors.indexOf(currentColor);
    Color? newColor;

    // Finding the right color
    if (_wasARightSwipe!)
    {
      // Going up in indexes
        // if index out of range
      if ((colorIndex + 1) == 3) {newColor = greenShade900;}
      else {newColor = identifierColors[colorIndex + 1];}      
    }
    else
      // Left swipe
    {
      // if index out of range
      if (colorIndex == 0) {newColor = red;}
      else {newColor = identifierColors[colorIndex - 1];}
    }

    // Updating the lists of colors
   if (widget.columnNumber == 1){widget.identifiersColors1[index] = newColor;}
   else {widget.identifiersColors2[index] = newColor;}

    // Updating state data
    setState(() {});
  }

  // Method used to build the list of identifiers
  List<Widget> _buildIdentifiersList
  ({
    required List<String> identifiers, 
    required List<Color> identifiersColors})
  {
    return identifiers.asMap().entries
        .map((entry) => IdentifierWidget(
              identifierValue: entry.value,
              color: (widget.columnNumber == 1) ? widget.identifiersColors1[entry.key] : widget.identifiersColors2[entry.key],
              isEditMode: widget.isEditMode,
              isDeleteMode: widget.isDeleteMode,
              onDelete: () => _removeIdentifier(index: entry.key),
              onEdit: () => _editIdentifier(index: entry.key),
              onSwipe: (bool value)
              {
                _swipeStateUpdate(value);
                _changeIdentifierColor(index: entry.key, currentColor: (widget.columnNumber == 1) ? widget.identifiersColors1[entry.key] : widget.identifiersColors2[entry.key]);
              },
              onClick: (bool value)
              {
                _swipeStateUpdate(value);
                _changeIdentifierColor(index: entry.key, currentColor: (widget.columnNumber == 1) ? widget.identifiersColors1[entry.key] : widget.identifiersColors2[entry.key]);
              },
            ))
        .toList();
  }

  // Method used to decide which list of identifiers to build
  List<Widget> _whichIdentifiersListToBuild() 
  {
    if (widget.columnNumber == 1)
    {return _buildIdentifiersList(identifiers: widget.identifiersCol1, identifiersColors: widget.identifiersColors1);}
    else 
    {return _buildIdentifiersList(identifiers: widget.identifiersCol2, identifiersColors: widget.identifiersColors2);}
  }

  // Function used to delete all stakeholder identifiers
  // Used in GPSProcess.
  void clearAllIdentifiers() 
  {
    widget.identifiersCol1.clear();
    widget.identifiersCol2.clear();
    widget.groupMoodsKey1.currentState?.setState(() {});
    widget.groupMoodsKey2.currentState?.setState(() {});

  }
  
  @override
  Widget build(BuildContext context) {
    return 
      ListView
      (
        // shrinkWrap: true, // Allows the list to be as small as its children
        children: 
        [          
          ..._whichIdentifiersListToBuild()
        ],
    );
  }
}

// Class for the stakeholders' identifiers
class IdentifierWidget extends StatelessWidget 
{
  final String identifierValue;
  final Color color;
  final bool isEditMode;
  final bool isDeleteMode;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ValueChanged<bool> onSwipe;
  final ValueChanged<bool> onClick;

  const IdentifierWidget
  ({
    super.key, 
    this.identifierValue = editEmoji, 
    this.color = green,
    required this.isEditMode, 
    required this.isDeleteMode,
    required this.onDelete, 
    required this.onEdit,
    required this.onSwipe,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return 
    GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          onSwipe(true);
        } else if (details.primaryVelocity! < 0) {
          onSwipe(false);
        }
      },
      child:    
        Stack(
          alignment: Alignment.center,
          children: [
            // The Circle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 70, height: 70,
              decoration: 
              BoxDecoration
              (
                color: Colors.white, shape: BoxShape.circle, 
                border: Border.all(width: 5, color: color), 
              ),
              child: 
                InkWell(
                  onTap: 
                      isEditMode ? onEdit 
                                : isDeleteMode ? onDelete
                                // Color swapping if neither edit nor delete mode
                                :  () {onSwipe(true);}, 
                  customBorder: const CircleBorder(), 
                  child: Center(
                    child: Text(
                      // Testing if identifierValue is an int
                      int.tryParse(identifierValue) != null ? editEmoji :  identifierValue,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            if (isDeleteMode) ...[
              Positioned(
                right: (Platform.isAndroid || Platform.isIOS) ? 0 : 100, top: 0,
                child: IconButton(icon: const Icon(Icons.delete_rounded, size: 35, color:  Color(0xFFB71C1C)), onPressed: onDelete),
              ),
            ],
          ],
        )
    );
  }
}