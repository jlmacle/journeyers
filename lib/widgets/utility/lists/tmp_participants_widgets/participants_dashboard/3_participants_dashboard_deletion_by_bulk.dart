
import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/database/participants_lists_db.dart";
import "package:journeyers/widgets/utility/lists/database/participants_lists_db_externalized_strings.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/2c_participants_dashboard_filtering_by_keywords.dart";


/// {@category Utils - Project-specific}
/// {@category Lists}
/// A widget handling bulk deletion on the participants lists dashboard.
class ParticipantsListsDashboardDeletionByBulk extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// Boolean used to store if some lists are selected for deletion.
  final bool areListsForDeletion; 

  /// List containing all available lists.
  final List<dynamic>? participantsListsAll;

  /// List containing all filtered lists.
  final List<dynamic>? participantsListsFiltered;

  /// List containing the keys of lists selected for deletion.
  final List<dynamic>? participantsListsSelectedForDeletionKeys;

  /// Callback function used to refresh the lists displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheParticipantsLists;

  const ParticipantsListsDashboardDeletionByBulk
  ({
    super.key,
    required this.dashboardContext,
    required this.areListsForDeletion,
    required this.participantsListsAll,
    required this.participantsListsFiltered,
    required this.dashboardCallbackFunctionToRefreshTheParticipantsLists,
    this.participantsListsSelectedForDeletionKeys    
  });

  @override
  State<ParticipantsListsDashboardDeletionByBulk> createState() => _ParticipantsListsDashboardDeletionByBulkState();
}

class _ParticipantsListsDashboardDeletionByBulkState extends State<ParticipantsListsDashboardDeletionByBulk> 
{
  final _listsDB = ParticipantsListsDB();

  // ─── GLOBAL KEYS ───────────────────────────────────────
  final GlobalKey<ParticipantsListsDashboardFilteringByKeywordsState> _dashboardFilteringByKeywordsKey = GlobalKey();

  // ─── BULK DELETION OF SESSION DATA ───────────────────────────────────────
  // Method used to delete several lists data
  Future<void> _selectedListsDelete() async 
  {
    // Creating a fixed list to iterate over so clearing doesn"t break the loop
    final keysOfListsSelectedForDeletion = List<String>.from(widget.participantsListsSelectedForDeletionKeys!);

    // Updating the DB
    await _listsDB.removeListData(keysOfListsSelectedForDeletion);    

    // Updating the filtered sessions list
    widget.participantsListsFiltered?.removeWhere
    (
      (session) => 
      keysOfListsSelectedForDeletion.contains(session[itemKey])
    );

    // Updating the _allLists list
    widget.participantsListsAll?.removeWhere
    (
      (session) => 
      keysOfListsSelectedForDeletion.contains(session[itemKey])
    );
    if (sessionDataDebug) pu.printd("Session Data: Deletion by bulk: after deletion:  widget.allLists: ${widget.participantsListsAll}");

    // Clearing the list of the selected sessions
    widget.participantsListsSelectedForDeletionKeys!.clear();

    // Updating the keywords list
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();

    // Re-applying the keywords filtering
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsApplyFiltering();    

    if (!mounted) return;
    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));

    // REFRESHING THE UI
    if (sessionDataDebug) pu.printd("Session Data: widget.allLists!.isEmpty?: ${widget.participantsListsAll!.isEmpty}");

    // 1. IF NO SESSION DATA LEFT
    // Refreshing and applying resetWasSessionDataSavedStatus
    if (widget.participantsListsAll!.isEmpty) 
    {
      // resetWasSessionDataSavedStatus to false
      await rtdu.resetWasSessionDataSavedStatus(context: widget.dashboardContext);

      widget.dashboardCallbackFunctionToRefreshTheParticipantsLists();
    }
    // 2. ELSE: SOME SESSION DATA LEFT AND TO REFRESH
    else
    {

      // Updating the keywords UI
      _dashboardFilteringByKeywordsKey.currentState?.setState((){});

      // Updating the sessions list UI
      widget.dashboardCallbackFunctionToRefreshTheParticipantsLists();      
    }

  }
  
  @override
  void initState() {
    super.initState();

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ParticipantsListsDashboardDeletionByBulk");
  }

  @override
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            onPressed: _selectedListsDelete,
            icon: Icon(Icons.delete, color: (widget.areListsForDeletion == true)? Colors.red: transparent),
            label: Text(
              "Delete (${widget.participantsListsSelectedForDeletionKeys?.length ?? 0})",
              style: TextStyle(
                color: (widget.areListsForDeletion == true)? Colors.red: transparent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}