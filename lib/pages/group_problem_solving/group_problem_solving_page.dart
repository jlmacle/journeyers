import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';

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
  // Mode for modifying a stakeholder identifier
  bool _isModificationMode = false;
  // Mode for editing a stakeholder identifier
  bool _isEditMode = false;
  // Mode for deleting a stakeholder identifier
  bool _isDeleteMode = false;
  // Bool used to suggest editing at start of adding identifiers
  bool _hasBeenEdited = false;

  void addToIdentifiers()
  {
    // There should be as much identifiers in the first column,
    // as in the second.
    int totalIndexes = _identifiersCol1.length+_identifiersCol2.length;
    if (_identifiersCol1.length <= _identifiersCol2.length) {_identifiersCol1.add("$totalIndexes");}
    else {_identifiersCol2.add("$totalIndexes");}
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

  @override
  void dispose() 
  {
    groupProblemSolvingDashboardFocusNode.dispose();
    super.dispose();
  }
    
 @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // COLUMN 1: 'Add' Button, 'Clear One' button + Identifier widgets
        Expanded(
          child: ListView(
            children: [
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
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[200],
            child: const Center(child: Text("Main Scrollable Area")),
          ),
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


  List<Widget> buildIdentifiersList({int? column, List<String>? identifiers})
  {
    return identifiers!.asMap().entries
        // To apply the identifiers to the right column
        // Odd ones in the first column
        // Even ones in the second column
        // .where((entry) => entry.key % 2 == remainder)
        .map((entry) => _IdentifierWidget(
              value: entry.value,
              isEditMode: _isEditMode,
              isDeleteMode: _isDeleteMode,
              editionHappened: _hasBeenEdited,
              onDelete: () => _removeIdentifier(index: entry.key, column: column),
              onEdit: () => _editIdentifier(index: entry.key, column: column),
            ))
        .toList();
  }

  // Method used to build the stakeholders' identifiers
  List<Widget> _whichIdentifiersListToBuild({int? column}) 
  {
    if (column==1)
    {return buildIdentifiersList(column: column, identifiers: _identifiersCol1);}
    else 
    {return buildIdentifiersList(column: column, identifiers: _identifiersCol2);}
  }
}

// Class for the stakeholders' identifiers
class _IdentifierWidget extends StatelessWidget 
{
  // The value for the identifier.
  final String value;
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

  const _IdentifierWidget
  ({
    required this.value, 
    required this.isEditMode, 
    required this.isDeleteMode,
    required this.editionHappened,
    required this.onDelete, 
    required this.onEdit
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 70, height: 70,
          // green shade 900
          decoration: const BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle),
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
    );
  }
}