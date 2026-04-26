import 'dart:io';

import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';

/// {@category Group problem-solving}
/// A widget used to monitor the moods of the stakeholders involved in the group problem-solving process.
class GPSGroupMoods extends StatefulWidget 
{
  /// The number of the column (1 for the left side of the UI, 2 for the right side)
  final int columnNumber;

  /// The key for the first group moods widget
  final GlobalKey groupMoods1Key;

  /// The key for the first group moods widget
  final GlobalKey groupMoods2Key;

  // The list of stakeholders identifiers for the first column
  final List<String> identifiersCol1;

  // The list of stakeholders identifiers for the second column
  final List<String> identifiersCol2;

  // The list of stakeholders identifiers' colors for the first column
  final List<Color> identifiersColors1;

  // The list of stakeholders identifiers' colors for the second column
  final List<Color> identifiersColors2;

  // Mode for editing a stakeholder identifier
  final bool isEditMode;

  // Mode for deleting a stakeholder identifier
  final bool isDeleteMode;

  const GPSGroupMoods
  ({
    super.key,
    required this.columnNumber,
    required this.groupMoods1Key,
    required this.groupMoods2Key,
    required this.identifiersCol1,
    required this.identifiersCol2,
    required this.identifiersColors1,
    required this.identifiersColors2,
    required this.isEditMode,
    required this.isDeleteMode
  });

  @override
  State<GPSGroupMoods> createState() => GPSGroupMoodsState();
}

class GPSGroupMoodsState extends State<GPSGroupMoods> 
{
  // Bool used to suggest editing at start of adding identifiers
  bool _hasBeenEdited = false;
  
  // Bool used to store if a swipe left of right has happened
  bool? wasARightSwipe;
  
  // Callback function used to update the wasARightSwipe field
  final ValueChanged<bool> onSwipe = placeHolderFunctionBool;

  // Method used to trigger a re-build
  void updateData()
  {
    setState(() {});
  }

  // Method used to add stakeholder identifiers
  // Important: the knowledge of the state of both list (and colors) of identifiers is needed
  void addToIdentifiers()
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
      widget.groupMoods1Key.currentState?.setState(() {});
    }
    else 
    {
      widget.identifiersCol2.add("$totalIndexes");
      // All identifiers are green by default
      widget.identifiersColors2.add(greenShade900);
      widget.groupMoods2Key.currentState?.setState(() {});
    }    
  }

  // Function used to remove a stakeholder identifier
  void _removeIdentifier({int? index}) 
      => setState(() 
                  {
                    if (widget.columnNumber == 1) {widget.identifiersCol1.removeAt(index!);}
                    else {widget.identifiersCol2.removeAt(index!);}
                  });

  // Function used to delete all stakeholder identifiers
  void clearAllIdentifiers() 
  {
    widget.identifiersCol1.clear();
    widget.identifiersCol2.clear();
    widget.groupMoods1Key.currentState?.setState(() {});
    widget.groupMoods2Key.currentState?.setState(() {});

  }

  // Function used to edit a stakeholder identifier
  void _editIdentifier({int? index}) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = .new();
        return AlertDialog(
          title: const Text("Edit Value"),
          content: TextField
          (
            controller: controller, 
            keyboardType: TextInputType.name,
            onSubmitted: (_) 
                        {
                            if (!_hasBeenEdited) _hasBeenEdited = true;
                            setState(() 
                                      { 
                                        if (widget.columnNumber == 1) {widget.identifiersCol1[index!] = controller.text;}
                                        else {widget.identifiersCol2[index!] = controller.text;}
                                      });
                            Navigator.pop(context);
                          },
            ),
          actions: [
            TextButton(
              onPressed: () {
                if (!_hasBeenEdited) _hasBeenEdited = true;
                setState(() 
                          { 
                            if (widget.columnNumber == 1) {widget.identifiersCol1[index!] = controller.text;}
                            else {widget.identifiersCol2[index!] = controller.text;}
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
  void swipeStateUpdate(bool isSwipeRight)
  {
    setState(() {wasARightSwipe = isSwipeRight;});  
  }

  // Function used to change a stakeholder identifier's color
  void _changeIdentifierColor({required int index, required Color currentColor}) 
  { 
    final colors = [greenShade900, orange, red];
    int colorIndex = colors.indexOf(currentColor);
    Color? newColor;

    // Finding the right color
    if (wasARightSwipe!)
    {
      // Going up in indexes
        // if index out of range
      if ((colorIndex + 1) == 3) {newColor = greenShade900;}
      else {newColor = colors[colorIndex + 1];}      
    }
    else
      // Left swipe
    {
      // if index out of range
      if (colorIndex == 0) {newColor = red;}
      else {newColor = colors[colorIndex - 1];}
    }

    // Updating the lists of colors
   if (widget.columnNumber == 1){widget.identifiersColors1[index] = newColor;}
   else {widget.identifiersColors2[index] = newColor;}

    // Updating state data
    setState(() {});
  }

  // Method used to build the list of identifiers
  List<Widget> buildIdentifiersList
  ({
    required List<String> identifiers, 
    required List<Color> identifiersColors})
  {
    return identifiers.asMap().entries
        .map((entry) => _IdentifierWidget(
              value: entry.value,
              color: (widget.columnNumber == 1) ? widget.identifiersColors1[entry.key] : widget.identifiersColors2[entry.key],
              isEditMode: widget.isEditMode,
              isDeleteMode: widget.isDeleteMode,
              editionHappened: _hasBeenEdited,
              onDelete: () => _removeIdentifier(index: entry.key),
              onEdit: () => _editIdentifier(index: entry.key),
              onSwipe: (bool value)
              {
                swipeStateUpdate(value);
                _changeIdentifierColor(index: entry.key, currentColor: (widget.columnNumber == 1) ? widget.identifiersColors1[entry.key] : widget.identifiersColors2[entry.key]);
              },
              onClick: (bool value)
              {
                swipeStateUpdate(value);
                _changeIdentifierColor(index: entry.key, currentColor: (widget.columnNumber == 1) ? widget.identifiersColors1[entry.key] : widget.identifiersColors2[entry.key]);
              },
            ))
        .toList();
  }

  // Method used to decide which list of identifiers to build
  List<Widget> _whichIdentifiersListToBuild() 
  {
    if (widget.columnNumber == 1)
    {return buildIdentifiersList(identifiers: widget.identifiersCol1, identifiersColors: widget.identifiersColors1);}
    else 
    {return buildIdentifiersList(identifiers: widget.identifiersCol2, identifiersColors: widget.identifiersColors2);}
  }

  @override
  Widget build(BuildContext context) {
    return 
    // Expanded
    // (
      // child: 
      ListView
      (
        // shrinkWrap: true, // Allows the list to be as small as its children
        children: 
        [          
          ..._whichIdentifiersListToBuild()
        ],
      // ),
    );
  }
}

// Class for the stakeholders' identifiers
class _IdentifierWidget extends StatelessWidget 
{
  final String value;
  final Color color;
  final bool isEditMode;
  final bool isDeleteMode;
  final bool editionHappened;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ValueChanged<bool> onSwipe;
  final ValueChanged<bool> onClick;

  const _IdentifierWidget
  ({
    required this.value, 
    required this.color,
    required this.isEditMode, 
    required this.isDeleteMode,
    required this.editionHappened,
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
                customBorder: const CircleBorder(), // Keeps the ripple effect circular
                child: Center(
                  child: Text(
                    editionHappened ? value : '✏️$value',
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