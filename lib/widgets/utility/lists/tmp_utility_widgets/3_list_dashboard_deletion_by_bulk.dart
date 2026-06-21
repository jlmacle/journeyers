
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
  final List<dynamic>? allLists;

  /// List containing all filtered lists.
  final List<dynamic>? filteredLists;

  /// List containing the keys of lists selected for deletion.
  final List<dynamic>? keysOfListsSelectedForDeletion;

  /// Callback function used to refresh the lists displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const ListDashboardDeletionByBulk
  ({
    super.key,
    required this.dashboardContext,
    required this.areListsForDeletion,
    required this.allLists,
    required this.filteredLists,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
    this.keysOfListsSelectedForDeletion    
  });

  @override
  State<ListDashboardDeletionByBulk> createState() => _ListDashboardDeletionByBulkState();
}

class _ListDashboardDeletionByBulkState extends State<ListDashboardDeletionByBulk> 
{
  final _textListsDB = TextListsDB();

  // ─── GLOBAL KEYS ───────────────────────────────────────
  final GlobalKey<ListDashboardFilteringByKeywordsState> _dashboardFilteringByKeywordsKey = GlobalKey();

  // ─── BULK DELETION OF SESSION DATA ───────────────────────────────────────
  // Method used to delete several lists data
  Future<void> _deleteSelectedLists() async 
  {
    // Creating a fixed list to iterate over so clearing doesn't break the loop
    final keysOfListsSelectedForDeletion = List<String>.from(widget.keysOfListsSelectedForDeletion!);

    // Updating the DB
    await _textListsDB.removeListData(keysOfListsSelectedForDeletion);    

    // Updating the filtered sessions list
    widget.filteredLists?.removeWhere
    (
      (session) => 
      keysOfListsSelectedForDeletion.contains(session[itemKey])
    );

    // Updating the _allLists list
    widget.allLists?.removeWhere
    (
      (session) => 
      keysOfListsSelectedForDeletion.contains(session[itemKey])
    );
    if (sessionDataDebug) pu.printd("Session Data: Deletion by bulk: after deletion:  widget.allLists: ${widget.allLists}");

    // Clearing the list of the selected sessions
    widget.keysOfListsSelectedForDeletion!.clear();

    // Updating the keywords list
    _dashboardFilteringByKeywordsKey.currentState?.refreshKeywordsAfterSessionDeletion();

    // Re-applying the keywords filtering
    await _dashboardFilteringByKeywordsKey.currentState?.applyFilteringByKeywords();    

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));

    // REFRESHING THE UI
    if (sessionDataDebug) pu.printd("Session Data: widget.allLists!.isEmpty?: ${widget.allLists!.isEmpty}");

    // 1. IF NO SESSION DATA LEFT
    // Refreshing and applying resetWasSessionDataSavedStatus
    if (widget.allLists!.isEmpty) 
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
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            key: const Key('bulk-delete-button'),
            onPressed: _deleteSelectedLists,
            icon: Icon(Icons.delete, color: (widget.areListsForDeletion == true)? Colors.red: transparent),
            label: Text(
              "Delete (${widget.keysOfListsSelectedForDeletion?.length ?? 0})",
              style: TextStyle(
                color: (widget.areListsForDeletion == true)? Colors.red: transparent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}