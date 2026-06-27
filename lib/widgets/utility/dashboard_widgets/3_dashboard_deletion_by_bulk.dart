import 'dart:io';

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
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// Boolean used to store if some sessions are selected for deletion.
  final bool areSessionsForDeletion; 

  /// List containing all available session metadata.
  final List<dynamic>? sessionsMetadataAll;

  /// List containing all filtered session metadata.
  final List<dynamic>? sessionsMetadataFiltered;

  /// List containing the sessions selected for deletion metadata.
  final List<dynamic>? sessionsMetadataSelectedForDeletion;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardDeletionByBulk
  ({
    super.key,
    required this.dashboardContext,
    required this.areSessionsForDeletion,
    required this.sessionsMetadataAll,
    required this.sessionsMetadataFiltered,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
    this.sessionsMetadataSelectedForDeletion    
  });

  @override
  State<DashboardDeletionByBulk> createState() => _DashboardDeletionByBulkState();
}

class _DashboardDeletionByBulkState extends State<DashboardDeletionByBulk> 
{
  // ─── GLOBAL KEYS ───────────────────────────────────────
  final GlobalKey<DashboardFilteringByKeywordsState> _dashboardFilteringByKeywordsKey = GlobalKey();

  // ─── BULK DELETION OF SESSION DATA ───────────────────────────────────────
  // Method used to delete several session data
  Future<void> _sessionsMetadataSelectedDelete() async 
  {
    // Creating a fixed list to iterate over so clearing doesn't break the loop
    final filesToDeleteMetadata = List<String>.from(widget.sessionsMetadataSelectedForDeletion!);

    for (String filePath in filesToDeleteMetadata) 
    {
      // Removing the file
      await fu.deleteFile(filePath); 
      
      // Removing the metadata from the stored metadata
      await du.deleteSpecificSessionMetadata
      (
        typeOfDashboardContext: widget.dashboardContext, 
        filePathRelatedToDataToDelete: filePath
      );
    }

    // Updating the filtered sessions list
    widget.sessionsMetadataFiltered?.removeWhere
    (
      (session) => 
      filesToDeleteMetadata.contains(session[DashboardUtils.keyFilePath])
    );

    // Updating the sessionsMetadataAll list
    widget.sessionsMetadataAll?.removeWhere
    (
      (session) => 
      filesToDeleteMetadata.contains(session[DashboardUtils.keyFilePath])
    );
    if (sessionDataDebug) pu.printd("Session Data: Deletion by bulk: after deletion:  widget.sessionsMetadataAll: ${widget.sessionsMetadataAll}");

    // Clearing the list of the selected sessions
    widget.sessionsMetadataSelectedForDeletion!.clear();

    // Updating the keywords list
    _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();

    // Re-applying the keywords filtering
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsApplyFiltering();    

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));

    // REFRESHING THE UI
    if (sessionDataDebug) pu.printd("Session Data: widget.sessionsMetadataAll!.isEmpty?: ${widget.sessionsMetadataAll!.isEmpty}");

    // 1. IF NO SESSION DATA LEFT
    // Refreshing and applying resetWasSessionDataSavedStatus
    if (widget.sessionsMetadataAll!.isEmpty) 
    {
      // resetWasSessionDataSavedStatus to false
      await rtdu.resetWasSessionDataSavedStatus(context: widget.dashboardContext);

      // refreshing the page, to re-start in the process page
      if (widget.dashboardContext == DashboardUtils.caContext) {caPageKey.currentState?.onAllSessionFilesDeleted();}
      else if (widget.dashboardContext == DashboardUtils.gpsContext) {gpsPageKey.currentState?.gpsOnAllSessionsDataDeleted();}
      else {pu.printd("Error: Unexpected context: ${widget.dashboardContext}");}
    }
    // 2. ELSE: SOME SESSION DATA LEFT AND TO REFRESH
    else
    {

      // Updating the keywords UI
      _dashboardFilteringByKeywordsKey.currentState?.setState((){});

      // Updating the sessions list UI
      widget.dashboardCallbackFunctionToRefreshTheSessionsList();      
    }

    // Updating the file names list: _deleteSelectedSessions
    if(Platform.isAndroid || Platform.isIOS) 
    {
      await du.getStoredFileNamesOnMobile();
      if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
    }    
  }
  
  @override
  void initState() {

    super.initState();
                                                
    pu.printdLine();
    pu.printd("DashboardDeletionByBulk");
  }


  @override
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            key: const Key('bulk-delete-button'),
            onPressed: _sessionsMetadataSelectedDelete,
            icon: Icon(Icons.delete, color: (widget.areSessionsForDeletion == true)? Colors.red: transparent),
            label: Text(
              "Delete (${widget.sessionsMetadataSelectedForDeletion?.length ?? 0})",
              style: TextStyle(
                color: (widget.areSessionsForDeletion == true)? Colors.red: transparent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}