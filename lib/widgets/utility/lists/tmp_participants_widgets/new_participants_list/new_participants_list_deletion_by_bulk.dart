import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";


/// {@category Utils - Generic}
/// {@category Lists}
/// A widget handling bulk deletion of text items in a list.
class NewTextListDeletionByBulk extends StatefulWidget 
{
  /// Boolean used to store if some text items are selected for deletion.
  final bool areSomeTextItemsSelectedForDeletion; 

  /// List containing the entered texts.
  final List<String> enteredTextItemsList;

  /// List containing the indexes of the text items selected for deletion.
  final List<int> textItemsSelectedForDeletionIndexes;

  /// Callback function used to refresh the text items displayed.
  final VoidCallback callbackFunctionToRefreshTheList;

  const NewTextListDeletionByBulk
  ({
    super.key,
    required this.areSomeTextItemsSelectedForDeletion,
    required this.enteredTextItemsList,
    required this.textItemsSelectedForDeletionIndexes,
    required this.callbackFunctionToRefreshTheList,
  });

  @override
  State<NewTextListDeletionByBulk> createState() => NewTextListDeletionByBulkState();
}

class NewTextListDeletionByBulkState extends State<NewTextListDeletionByBulk> 
{
  // ─── BULK DELETION OF LIST ITEMS ───────────────────────────────────────
  // Method used to delete several list items
  Future<void> _selectedTextItemsDelete() async 
  {
    // Creating a new list to update enteredTextItemsList
    List<String> updatedNewTextsList = widget.enteredTextItemsList
    // to compare ints with ints
    .asMap().entries
    .where((entry) => !widget.textItemsSelectedForDeletionIndexes.contains(entry.key))
    // to get the strings
    .map((entry) => entry.value)
    .toList();

    // Clearing textItemsSelectedForDeletionIndexes 
    widget.textItemsSelectedForDeletionIndexes.clear();

    // Updating enteredTextItemsList
    widget.enteredTextItemsList.clear();
    widget.enteredTextItemsList.addAll(updatedNewTextsList);

    // Updating the UI
    widget.callbackFunctionToRefreshTheList(); // setState    
    
    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected items deleted.")));
 
  }

  @override
  void initState() {
    super.initState();
        
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("NewTextListDeletionByBulk");
  }
  
  @override
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            onPressed: _selectedTextItemsDelete,
            icon: Icon(Icons.delete, color: (widget.areSomeTextItemsSelectedForDeletion == true)? Colors.red: Colors.transparent),
            label: Text(
              "Delete (${widget.textItemsSelectedForDeletionIndexes.length})",
              style: TextStyle(
                color: (widget.areSomeTextItemsSelectedForDeletion == true)? Colors.red: Colors.transparent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}