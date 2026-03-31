import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/dev/util_files.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_sorting_by_keywords.dart';
import 'package:journeyers/widgets/utility/sessions_dashboard_page.dart';

/// {@category Utility widgets}
/// A widget handling bulk deletion of session data.
class DashboardDeletionByBulk extends StatefulWidget 
{
  /// The context for the dashboard (context analyses, group problem-solving sessions).
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
    this.sessionsSelectedForDeletion,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList
  });

  @override
  State<DashboardDeletionByBulk> createState() => _DashboardDeletionByBulkState();
}

class _DashboardDeletionByBulkState extends State<DashboardDeletionByBulk> 
{
  //**************** GLOBAL KEYS ****************//
  GlobalKey<GroupProblemSolvingPageState> groupProblemSolvingPageKey = GlobalKey();
  GlobalKey<SessionsDashboardPageState> sessionsDashboardPageStateKey = GlobalKey(debugLabel: "Sessions dashboard page");  
  GlobalKey<DashboardSortingByKeywordsState> dashboardSortingByKeywords = GlobalKey();

  //**************** BULK DELETION OF SESSION DATA ****************/
  // Method used to delete several session data
  Future<void> _deleteSelectedSessions() async 
  {
    // Creating a fixed list to iterate over so clearing doesn't break the loop
    final filesToDelete = List<String>.from(widget.sessionsSelectedForDeletion!);

    for (String filePath in filesToDelete) 
    {
      // Removing the file
      await fu.deleteCsvFile(filePath); 
      
      // Removing dashboard data from the stored data
      await du.deleteSessionData
      (
        typeOfContextData: widget.dashboardContext, 
        filePathRelatedToDataToDelete: filePath
      );
    }

    // To update the UI after all physical operations are done
    widget.filteredSessions?.removeWhere
    (
      (session) => 
      filesToDelete.contains(session[DashboardUtils.keyFilePath])
    );

    // To keep the _allSessions list updated
    widget.allSessions?.removeWhere
    (
      (session) => 
      filesToDelete.contains(session[DashboardUtils.keyFilePath])
    );

    // To clear the list of the selected sessions
    widget.sessionsSelectedForDeletion!.clear();

    // Updating the keyword list
    dashboardSortingByKeywords.currentState?.refreshKeywordsAfterSessionDeletion();

    // Refreshing the filtered list
    await dashboardSortingByKeywords.currentState?.applyFilteringByKeywords();    

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));

    // NO SESSION DATA LEFT
    // Refreshing and resetting "wasSessionDataSaved" if no session data left
    if (widget.allSessions != null  && widget.allSessions!.isEmpty) 
    {
      // resetting "wasSessionDataSaved" to false
      await upu.resetWasSessionDataSavedStatus(context: widget.dashboardContext);
      // refreshing the page
      groupProblemSolvingPageKey.currentState?.onAllSessionFilesDeleted();
    }
    // SOME SESSION DATA LEFT AND TO REFRESH
    else
    {
      // To update the keywords
      dashboardSortingByKeywords.currentState?.setState((){});

      // to update
      widget.dashboardCallbackFunctionToRefreshTheSessionsList();      
    }
  }
  
  @override
  Widget build(BuildContext context) 
  {
    return Center(
        child:        
          TextButton.icon(
            key: const Key('bulk_delete_button'),
            onPressed: _deleteSelectedSessions,
            icon: Icon(Icons.delete, color: (widget.areSessionsForDeletion)? Colors.red: white),
            label: Text(
              "Delete (${widget.sessionsSelectedForDeletion?.length ?? 0})",
              style: TextStyle(
                color: (widget.areSessionsForDeletion)? Colors.red: white, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),    
    );
  }
}