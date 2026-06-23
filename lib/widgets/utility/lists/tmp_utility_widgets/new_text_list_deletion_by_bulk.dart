import 'package:flutter/material.dart';


/// {@category Utils - Generic}
/// {@category Lists}
/// A widget handling bulk deletion of text items in a list.
class NewListDeletionByBulk extends StatefulWidget 
{
  /// Boolean used to store if some text items are selected for deletion.
  final bool areSomeTextItemsSelectedForDeletion; 

  /// List containing the entered texts.
  final List<String> enteredTextItemsList;

  /// List containing the indexes of the text items selected for deletion.
  final List<int> textItemsSelectedForDeletionIndexes;

  /// Callback function used to refresh the text items displayed.
  final VoidCallback callbackFunctionToRefreshTheList;

  const NewListDeletionByBulk
  ({
    super.key,
    required this.areSomeTextItemsSelectedForDeletion,
    required this.enteredTextItemsList,
    required this.textItemsSelectedForDeletionIndexes,
    required this.callbackFunctionToRefreshTheList,
  });

  @override
  State<NewListDeletionByBulk> createState() => NewListDeletionByBulkState();
}

class NewListDeletionByBulkState extends State<NewListDeletionByBulk> 
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
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            key: const Key('bulk-delete-button'),
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