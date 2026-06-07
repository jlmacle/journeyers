import 'package:flutter/material.dart';


/// {@category Utils - Generic}
/// {@category Lists}
/// A widget handling bulk deletion of text items in a list.
class TextListItemDeletionByBulk extends StatefulWidget 
{
  /// Boolean used to store if some text items are selected for deletion.
  final bool areSomeTextItemsSelectedForDeletion; 

  /// List containing the entered texts.
  final List<String> enteredTextItemsList;

  /// List containing the indexes of the text items selected for deletion.
  final List<int> indexesOfTextItemsSelectedForDeletion;

  /// Callback function used to refresh the text items displayed.
  final VoidCallback callbackFunctionToRefreshTheTextItemsList;

  const TextListItemDeletionByBulk
  ({
    super.key,
    required this.areSomeTextItemsSelectedForDeletion,
    required this.enteredTextItemsList,
    required this.indexesOfTextItemsSelectedForDeletion,
    required this.callbackFunctionToRefreshTheTextItemsList,
  });

  @override
  State<TextListItemDeletionByBulk> createState() => TextListItemDeletionByBulkState();
}

class TextListItemDeletionByBulkState extends State<TextListItemDeletionByBulk> 
{
  // ─── BULK DELETION OF LIST ITEMS ───────────────────────────────────────
  // Method used to delete several list items
  Future<void> _deleteSelectedLists() async 
  {
    print("_deleteSelectedLists:  widget.indexesOfTextItemsSelectedForDeletion: ${widget.indexesOfTextItemsSelectedForDeletion}");
    print("_deleteSelectedLists:  widget.enteredTextItemsList: ${widget.enteredTextItemsList}");
    // Creating a new list to update _enteredTextItemsList
    List<String> updatedNewTextsList = widget.enteredTextItemsList
    // to compare ints with ints
    .asMap().entries
    .where((entry) => !widget.indexesOfTextItemsSelectedForDeletion.contains(entry.key))
    // to get the strings
    .map((entry) => entry.value)
    .toList();

    print("_deleteSelectedLists:  updatedNewTextsList: $updatedNewTextsList");

    // Clearing indexesOfTextItemsSelectedForDeletion 
    widget.indexesOfTextItemsSelectedForDeletion.clear();

    // Updating _enteredTextItemsList
    widget.enteredTextItemsList.clear();
    widget.enteredTextItemsList.addAll(updatedNewTextsList);

    // Updating the UI
    widget.callbackFunctionToRefreshTheTextItemsList(); // setState    
    
    print("Deletion by bulk: after deletion:  widget.enteredTextItemsList: ${widget.enteredTextItemsList}");

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));
 
  }
  
  @override
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            key: const Key('bulk-delete-button'),
            onPressed: _deleteSelectedLists,
            icon: Icon(Icons.delete, color: (widget.areSomeTextItemsSelectedForDeletion == true)? Colors.red: Colors.transparent),
            label: Text(
              "Delete (${widget.indexesOfTextItemsSelectedForDeletion.length})",
              style: TextStyle(
                color: (widget.areSomeTextItemsSelectedForDeletion == true)? Colors.red: Colors.transparent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}