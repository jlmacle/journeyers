import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dev/placeholder_functions.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/checklist.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_widgets/problem_to_solve.dart';

/// {@category Pages}
/// {@category Group problem-solving}
/// The root page for the group problem-solvings.
class GroupProblemSolvingPage extends StatefulWidget 
{
  const GroupProblemSolvingPage({super.key});

  @override
  State<GroupProblemSolvingPage> createState() => _GroupProblemSolvingPageState();
}

class _GroupProblemSolvingPageState extends State<GroupProblemSolvingPage> 
{
  FocusNode groupProblemSolvingDashboardFocusNode = FocusNode();

  // List of stakeholders identifiers
  final List<String> _identifiersCol1 = [];
  final List<String> _identifiersCol2 = [];

  // List of stakeholders identifiers' colors
  final List<Color> _identifiersColors1 = [];
  final List<Color> _identifiersColors2 = [];

  // Mode for modifying a stakeholder identifier
  bool _isModificationMode = false;
  // Mode for editing a stakeholder identifier
  bool _isEditMode = false;
  // Mode for deleting a stakeholder identifier
  bool _isDeleteMode = false;
  // Bool used to suggest editing at start of adding identifiers
  bool _hasBeenEdited = false;
  // Bool used to store if a swipe left of right has happened
  bool? wasARightSwipe;
  // Callback function used to update the wasARightSwipe field
  final ValueChanged<bool> onSwipe = placeHolderFunctionBool;

  void addToIdentifiers()
  {
    // There should be as much identifiers in the first column,
    // as in the second.

    // Adding to col 1
    int totalIndexes = _identifiersCol1.length+_identifiersCol2.length;
    if (_identifiersCol1.length <= _identifiersCol2.length) 
    {
      _identifiersCol1.add("$totalIndexes");
      // All identifiers are green by default
      _identifiersColors1.add(greenShade900);
    }
    else 
    {
      _identifiersCol2.add("$totalIndexes");
      // All identifiers are green by default
      _identifiersColors2.add(greenShade900);
    }    
  }

  // Function used to add a stakeholder identifier
  void _addIdentifier() => setState(() => addToIdentifiers());
  
  // Function used to remove a stakeholder identifier
  void _removeIdentifier({int? index, int? column}) 
      => setState(() 
                  {
                    if (column==1) {_identifiersCol1.removeAt(index!);}
                    else {_identifiersCol2.removeAt(index!);}
                  });

  // Function used to delete all stakeholder identifiers
  void _clearAllIdentifiers() => setState(() {_identifiersCol1.clear(); _identifiersCol2.clear();});

  // Function used to edit a stakeholder identifier
  void _editIdentifier({int? index, int? column}) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Edit Value"),
          content: TextField(controller: controller, keyboardType: TextInputType.name),
          actions: [
            TextButton(
              onPressed: () {
                if (!_hasBeenEdited) _hasBeenEdited = true;
                setState(() 
                          { 
                            if (column==1) {_identifiersCol1[index!] = controller.text;}
                            else {_identifiersCol2[index!] = controller.text;}
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
  void _changeIdentifierColor({required int index, required int column, required Color currentColor}) 
  { 
    final colors = [greenShade900, orangeShade900, redShade900];
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
      if (colorIndex == 0) {newColor = redShade900;}
      else {newColor = colors[colorIndex - 1];}
    }

    // Updating the lists of colors
   if (column == 1){_identifiersColors1[index] = newColor;}
   else {_identifiersColors2[index] = newColor;}

    // Updating state data
    setState(() {});
  }


  @override
  void dispose() 
  {
    groupProblemSolvingDashboardFocusNode.dispose();
    super.dispose();
  }
    
 @override
  Widget build(BuildContext context) {
    return Column(   
      children: [
        // The problem to be solved 
        const ProblemToSolve(),
        // The row with the stakeholder identifiers and the main content
        Expanded(
          child:
          Row(
            children: 
            [
              // COLUMN 1: 'Add' Button, 'Clear One' button + Identifier widgets
              Expanded(
                child: ListView
                (
                  children: 
                  [
                    _buildHeaderButton("➕", Colors.white, _addIdentifier),
                    // In 'Edit' mode, a button to delete, or edit, an identifier
                    if (_isModificationMode)
                      // Red and orange shade 900
                      _buildHeaderButton(_isDeleteMode ? "Edit" : "Clear One",_isDeleteMode ? const Color(0xFFB71C1C) : const Color(0xFFE65100), () =>  setState(() { _isDeleteMode = !_isDeleteMode; _isEditMode = !_isEditMode;})),
                    ..._whichIdentifiersListToBuild(column: 1),
                  ],
                ),
              ),
              
              // CENTER: Main Content
              Expanded
              (
                flex: 2,
                child: 
                CustomScrollView
                (
                  // Using a CustomScrollView to coordinate the fade effect of the checklist and solutions
                  slivers: 
                  [
                    // Checklist
                    const SliverToBoxAdapter
                    (
                      child: Padding
                      (
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: 
                        Checklist(),
                      )                        
                    ),  

                    // Previously entered solutions
                    SliverToBoxAdapter
                    (
                      child: Padding
                      (
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: 
                        Column
                        (
                          children: 
                          [
                            const Center(child: Text("List of solutions", style:problemSolvingSolutionsTitle)),
                            ...List<Widget>.generate
                            (
                            30,
                            (i) => Text('Solution $i')
                            ),
                          ]
                        )                        
                      )                        
                    ),
                  ]
                )
              ),

          
              // COLUMN 2: ✏️/'Done' button,  'Clear All' button + Identifier widgets
              Expanded(
                child: ListView(
                  children: [
                    _buildHeaderButton(
                      _isModificationMode ? "Done" : "✏️", 
                      _isModificationMode ? Colors.orange : Colors.white, 
                      _isModificationMode 
                        ? () =>
                          setState(() 
                          {                      
                            _isEditMode = false;
                            _isDeleteMode = false;
                            _isModificationMode = !_isModificationMode;                      
                          })
                          
                        : () => setState(() {_isEditMode = true; _isModificationMode = !_isModificationMode;})
                    ),
                    
                    if (_isModificationMode)
                      // red shade 900
                      _buildHeaderButton("Clear All", const Color(0xFFB71C1C), _clearAllIdentifiers),
                    ..._whichIdentifiersListToBuild(column: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method used to build the header buttons
  Widget _buildHeaderButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: appBarWhite),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }


  List<Widget> buildIdentifiersList
  ({
    required int column, required List<String> identifiers, 
    required List<Color> identifiersColors})
  {
    return identifiers.asMap().entries
        // To apply the identifiers to the right column
        // Odd ones in the first column
        // Even ones in the second column
        .map((entry) => _IdentifierWidget(
              value: entry.value,
              color: (column==1) ? _identifiersColors1[entry.key] : _identifiersColors2[entry.key],
              isEditMode: _isEditMode,
              isDeleteMode: _isDeleteMode,
              editionHappened: _hasBeenEdited,
              onDelete: () => _removeIdentifier(index: entry.key, column: column),
              onEdit: () => _editIdentifier(index: entry.key, column: column),
              onSwipe: (bool value)
              {
                swipeStateUpdate(value);
                _changeIdentifierColor(index: entry.key, column: column, currentColor: (column==1) ? _identifiersColors1[entry.key] : _identifiersColors2[entry.key]);
              },
            ))
        .toList();
  }

  // Method used to build the stakeholders' identifiers
  List<Widget> _whichIdentifiersListToBuild({required int column}) 
  {
    if (column==1)
    {return buildIdentifiersList(column: column, identifiers: _identifiersCol1, identifiersColors: _identifiersColors1);}
    else 
    {return buildIdentifiersList(column: column, identifiers: _identifiersCol2, identifiersColors: _identifiersColors2);}
  }
}


// Class for the stakeholders' identifiers
class _IdentifierWidget extends StatelessWidget 
{
  // The value for the identifier.
  final String value;
  // The color for the identifier.
  final Color color;
  // If the identifier's value is in edition mode or not.
  final bool isEditMode;
  // If the identifier is in deletion mode or not.
  final bool isDeleteMode;
  // If an identifier has been already edited 
  final bool editionHappened;
  // A callback function called to delete the identifier.
  final VoidCallback onDelete;
  // A callback function called to edit the identifier.
  final VoidCallback onEdit;
  // A callback function called to update if a swipe happened, and which type of swipe, left or right.
  final ValueChanged<bool> onSwipe;

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
  });

  

  @override
  Widget build(BuildContext context) {
    return 
    GestureDetector(
    onHorizontalDragEnd: (details) {
      if (details.primaryVelocity! > 0) {
        // Right swipe
        onSwipe(true);
      } else if (details.primaryVelocity! < 0) {
        // Left swipe
        onSwipe(false);
      }
    },
    child:    
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 70, height: 70,
            decoration: 
            BoxDecoration
            (
              color: Colors.white, shape: BoxShape.circle, 
              border: BoxBorder.all(width: 5, color: color), 
            ),
            child: Center(child: Text(editionHappened ? value : '✏️$value', style: const TextStyle(color: appBarWhite))),
          ),
          if (isDeleteMode) ...[
            Positioned(
              right: 0, top: 0,
              // TODO: size/placement according to platform
              // red shade 900
              child: IconButton(icon: const Icon(Icons.delete_rounded, size: 35, color:  Color(0xFFB71C1C)), onPressed: onDelete),
            ),
          ],
          if (isEditMode) ...[
            Positioned(
              left: 20, top: 15,
              // TODO: to do without the icon
              child: IconButton(icon: const Icon(Icons.edit, size: 35, color: Colors.transparent), onPressed: onEdit),
            ),
          ]
        ],
      )
    );
  }
}