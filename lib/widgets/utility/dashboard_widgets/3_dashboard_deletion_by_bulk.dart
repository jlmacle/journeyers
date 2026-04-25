import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2c_dashboard_filtering_by_keywords.dart';


/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling bulk deletion of session data.
class DashboardDeletionByBulk extends StatefulWidget 
{
  /// The context for the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// Bool used to store if some sessions are selected for deletion.
  final bool areSessionsForDeletion; 

  /// List storing all available session data.
  final List<dynamic>? allSessions;

  /// List storing all filtered session data.
  final List<dynamic>? filteredSessions;

  /// List storing the sessions selected for deletion.
  final List<dynamic>? sessionsSelectedForDeletion;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardDeletionByBulk
  ({
    super.key,
    required this.dashboardContext,
    required this.areSessionsForDeletion,
    required this.allSessions,
    required this.filteredSessions,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
    this.sessionsSelectedForDeletion    
  });

  @override
  State<DashboardDeletionByBulk> createState() => _DashboardDeletionByBulkState();
}

class _DashboardDeletionByBulkState extends State<DashboardDeletionByBulk> 
{
  // ─── GLOBAL KEYS ───────────────────────────────────────
  GlobalKey<DashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKey = GlobalKey();

  // ─── BULK DELETION OF SESSION DATA ───────────────────────────────────────
  // Method used to delete several session data
  Future<void> _deleteSelectedSessions() async 
  {
    // Creating a fixed list to iterate over so clearing doesn't break the loop
    final filesToDelete = List<String>.from(widget.sessionsSelectedForDeletion!);

    for (String filePath in filesToDelete) 
    {
      // Removing the file
      await fu.deleteCsvFile(filePath); 
      
      // Removing the metadata from the stored metadata
      await du.deleteSpecificSessionMetadata
      (
        typeOfDashboardContext: widget.dashboardContext, 
        filePathRelatedToDataToDelete: filePath
      );
    }

    // Updating the filtered sessions list
    widget.filteredSessions?.removeWhere
    (
      (session) => 
      filesToDelete.contains(session[DashboardUtils.keyFilePath])
    );

    // Updating the _allSessions list
    widget.allSessions?.removeWhere
    (
      (session) => 
      filesToDelete.contains(session[DashboardUtils.keyFilePath])
    );
    if (sessionDataDebug) pu.printd("Session Data: Deletion by bulk: after deletion:  widget.allSessions: ${widget.allSessions}");

    // Clearing the list of the selected sessions
    widget.sessionsSelectedForDeletion!.clear();

    // Updating the keywords list
    dashboardFilteringByKeywordsKey.currentState?.refreshKeywordsAfterSessionDeletion();

    // Re-applying the keywords filtering
    await dashboardFilteringByKeywordsKey.currentState?.applyFilteringByKeywords();    

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));

    // REFRESHING THE UI
    if (sessionDataDebug) pu.printd("Session Data: widget.allSessions!.isEmpty: ${widget.allSessions!.isEmpty}");

    // 1. IF NO SESSION DATA LEFT
    // Refreshing and applying resetWasSessionDataSavedStatus
    if (widget.allSessions!.isEmpty) 
    {
      // resetWasSessionDataSavedStatus to false
      await upu.resetWasSessionDataSavedStatus(context: widget.dashboardContext);

      // refreshing the page, to re-start in the process page
      if (widget.dashboardContext == DashboardUtils.caContext) {caPageKey.currentState?.onAllSessionFilesDeleted();}
      else if (widget.dashboardContext == DashboardUtils.gpsContext) {gpsPageKey.currentState?.onAllSessionFilesDeleted();}
      else {pu.printd("Error: Unexpected context: ${widget.dashboardContext}");}
    }
    // 2. ELSE: SOME SESSION DATA LEFT AND TO REFRESH
    else
    {

      // Updating the keywords UI
      dashboardFilteringByKeywordsKey.currentState?.setState((){});

      // Updating the sessions list UI
      widget.dashboardCallbackFunctionToRefreshTheSessionsList();      
    }

    // Updating the file names list: _deleteSelectedSessions
    await du.getStoredFileNamesOnMobile();
    if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames: (after retrieval) ${du.currentListOfStoredFileNames}");
  }
  
  @override
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            key: const Key('bulk-delete-button'),
            onPressed: _deleteSelectedSessions,
            icon: Icon(Icons.delete, color: (widget.areSessionsForDeletion == true)? Colors.red: transparent),
            label: Text(
              "Delete (${widget.sessionsSelectedForDeletion?.length ?? 0})",
              style: TextStyle(
                color: (widget.areSessionsForDeletion == true)? Colors.red: transparent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}