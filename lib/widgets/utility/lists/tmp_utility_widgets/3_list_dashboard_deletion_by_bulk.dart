
import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/lists/models/text_lists_storage.dart';
import 'package:journeyers/widgets/utility/lists/models/text_lists_storage_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/2c_list_dashboard_filtering_by_keywords.dart';


/// {@category Utility widgets}
/// {@category Lists}
/// A widget handling bulk deletion of session data.
class ListDashboardDeletionByBulk extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// Boolean used to store if some lists are selected for deletion.
  final bool areListsForDeletion; 

  /// List containing all available lists.
  final List<dynamic>? listsAll;

  /// List containing all filtered lists.
  final List<dynamic>? listsFiltered;

  /// List containing the keys of lists selected for deletion.
  final List<dynamic>? listsSelectedForDeletionKeys;

  /// Callback function used to refresh the lists displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const ListDashboardDeletionByBulk
  ({
    super.key,
    required this.dashboardContext,
    required this.areListsForDeletion,
    required this.listsAll,
    required this.listsFiltered,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
    this.listsSelectedForDeletionKeys    
  });

  @override
  State<ListDashboardDeletionByBulk> createState() => _ListDashboardDeletionByBulkState();
}

class _ListDashboardDeletionByBulkState extends State<ListDashboardDeletionByBulk> 
{
  final _listsDB = ListsDB();

  // ─── GLOBAL KEYS ───────────────────────────────────────
  final GlobalKey<ListDashboardFilteringByKeywordsState> _dashboardFilteringByKeywordsKey = GlobalKey();

  // ─── BULK DELETION OF SESSION DATA ───────────────────────────────────────
  // Method used to delete several lists data
  Future<void> _selectedListsDelete() async 
  {
    // Creating a fixed list to iterate over so clearing doesn't break the loop
    final keysOfListsSelectedForDeletion = List<String>.from(widget.listsSelectedForDeletionKeys!);

    // Updating the DB
    await _listsDB.removeListData(keysOfListsSelectedForDeletion);    

    // Updating the filtered sessions list
    widget.listsFiltered?.removeWhere
    (
      (session) => 
      keysOfListsSelectedForDeletion.contains(session[itemKey])
    );

    // Updating the _allLists list
    widget.listsAll?.removeWhere
    (
      (session) => 
      keysOfListsSelectedForDeletion.contains(session[itemKey])
    );
    if (sessionDataDebug) pu.printd("Session Data: Deletion by bulk: after deletion:  widget.allLists: ${widget.listsAll}");

    // Clearing the list of the selected sessions
    widget.listsSelectedForDeletionKeys!.clear();

    // Updating the keywords list
    _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();

    // Re-applying the keywords filtering
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsApplyFiltering();    

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));

    // REFRESHING THE UI
    if (sessionDataDebug) pu.printd("Session Data: widget.allLists!.isEmpty?: ${widget.listsAll!.isEmpty}");

    // 1. IF NO SESSION DATA LEFT
    // Refreshing and applying resetWasSessionDataSavedStatus
    if (widget.listsAll!.isEmpty) 
    {
      // resetWasSessionDataSavedStatus to false
      await rtdu.resetWasSessionDataSavedStatus(context: widget.dashboardContext);

      widget.dashboardCallbackFunctionToRefreshTheSessionsList();
    }
    // 2. ELSE: SOME SESSION DATA LEFT AND TO REFRESH
    else
    {

      // Updating the keywords UI
      _dashboardFilteringByKeywordsKey.currentState?.setState((){});

      // Updating the sessions list UI
      widget.dashboardCallbackFunctionToRefreshTheSessionsList();      
    }

  }
  
  @override
  void initState() {
    super.initState();

    pu.printdLine();
    pu.printd("ListDashboardDeletionByBulk");
  }

  @override
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            key: const Key('bulk-delete-button'),
            onPressed: _selectedListsDelete,
            icon: Icon(Icons.delete, color: (widget.areListsForDeletion == true)? Colors.red: transparent),
            label: Text(
              "Delete (${widget.listsSelectedForDeletionKeys?.length ?? 0})",
              style: TextStyle(
                color: (widget.areListsForDeletion == true)? Colors.red: transparent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}