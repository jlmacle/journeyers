import 'package:flutter/material.dart';


/// {@category Utility widgets}
/// {@category Lists}
/// A widget handling bulk deletion of text items in a list.
class TextListItemDeletionByBulk extends StatefulWidget 
{
  /// Boolean used to store if some sessions are selected for deletion.
  final bool areSomeTextItemsForDeletion; 

  /// List containing the entered texts.
  final List<String>? newTextItemsList;

  /// List containing the sessions selected for deletion.
  final List<dynamic>? indexesOfTextItemsSelectedForDeletion;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback callbackFunctionToRefreshTheTextItemsList;

  const TextListItemDeletionByBulk
  ({
    super.key,
    required this.areSomeTextItemsForDeletion,
    required this.newTextItemsList,
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
  Future<void> _deleteSelectedTextItems() async 
  {
    print("_deleteSelectedSessions:  widget.indexesOfTextItemsSelectedForDeletion: ${widget.indexesOfTextItemsSelectedForDeletion}");
    print("_deleteSelectedSessions:  newTextItemsList: ${widget.newTextItemsList}");
    // Creating a new list to update _newTextsList
    List<String> updatedNewTextsList = widget.newTextItemsList!
    // to compare ints with ints
    .asMap().entries
    .where((entry) => !widget.indexesOfTextItemsSelectedForDeletion!.contains(entry.key))
    // to get the strings
    .map((entry) => entry.value)
    .toList();

    print("_deleteSelectedSessions:  updatedNewTextsList: $updatedNewTextsList");

    // Updating _newTextsList
    widget.newTextItemsList!.clear();
    widget.newTextItemsList!.addAll(updatedNewTextsList);
    widget.callbackFunctionToRefreshTheTextItemsList(); // setState

    // Clearing indexesOfTextItemsSelectedForDeletion 
    widget.indexesOfTextItemsSelectedForDeletion!.clear();
    
    print("Deletion by bulk: after deletion:  widget.newTextItemsList: ${widget.newTextItemsList}");

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
            onPressed: _deleteSelectedTextItems,
            icon: Icon(Icons.delete, color: (widget.areSomeTextItemsForDeletion == true)? Colors.red: Colors.transparent),
            label: Text(
              "Delete (${widget.indexesOfTextItemsSelectedForDeletion?.length ?? 0})",
              style: TextStyle(
                color: (widget.areSomeTextItemsForDeletion == true)? Colors.red: Colors.transparent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}