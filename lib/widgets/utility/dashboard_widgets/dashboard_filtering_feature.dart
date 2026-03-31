import 'package:flutter/material.dart';
import 'package:journeyers/core/utils/dev/util_files.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_sorting_by_date.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_sorting_by_title.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_sorting_by_keywords.dart';

class DashboardFilteringFeature extends StatefulWidget 
{
  /// The context for the dashboard (context analyses, group problem-solving sessions).
  final String dashboardContext;

  /// List storing all available session data.
  final List<dynamic>? allSessions;

  /// List storing all filtered session data.
  final List<dynamic>? filteredSessions;

  /// List storing the keywords used in the session data.
  final List<String> usedKeywords;

  /// List storing the selected keywords.
  final List<String> selectedKeywords;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback parentCallbackFunctionToRefreshTheSessionsList;

  /// Global key used to identify the widget handling the sorting by keywords.
  final GlobalKey<DashboardSortingByKeywordsState> dashboardSortingByKeywordsKey;

  const DashboardFilteringFeature
  ({
    super.key,
    required this.dashboardContext,
    required this.allSessions,
    required this.filteredSessions,
    required this.usedKeywords,
    required this.selectedKeywords,
    required this.parentCallbackFunctionToRefreshTheSessionsList,
    required this.dashboardSortingByKeywordsKey
  });

  @override
  State<DashboardFilteringFeature> createState() => _DashboardFilteringFeatureState();
}

class _DashboardFilteringFeatureState extends State<DashboardFilteringFeature> 
{  
  final List<String> _selectedSessionsForDeletion = [];

  // Method used to delete several session data
  Future<void> _deleteSelectedSessions() async 
  {
    // Creating a fixed list to iterate over so clearing doesn't break the loop
    final filesToDelete = List<String>.from(_selectedSessionsForDeletion);

    for (String filePath in filesToDelete) 
    {
      // Removing the file
      await fu.deleteCsvFile(filePath); 
      
      // Removing dashboard data
      await du.deleteSessionData
      (
        typeOfContextData: widget.dashboardContext, 
        filePathRelatedToDataToDelete: filePath
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column
    (      
      children: 
      [
        Padding
        (
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column
          (
            crossAxisAlignment: CrossAxisAlignment.center,
            children: 
            [
              // Sorting by date/title wrapped for small screens
              Wrap
              (
                spacing: 8.0,   // horizontal gap between buttons
                runSpacing: 4.0, // vertical gap between wrapped lines
                alignment: WrapAlignment.start,
                children: 
                [
                  // Sorting by title
                  DashboardFilteringByTitle
                  (
                    filteredSessionsToSort: widget.filteredSessions,
                    dashboardCallbackFunctionToRefreshTheSessionsList: widget.parentCallbackFunctionToRefreshTheSessionsList
                  ),
                  // Sorting by date
                  DashboardSortingByDate
                  (
                    sessionsToSort: widget.filteredSessions,
                    dashboardCallbackFunctionToRefreshTheSessionsList: widget.parentCallbackFunctionToRefreshTheSessionsList
                  ),
                ],
              ),
              // Filtering by keywords
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text
                (
                  "Filter by Keywords:", 
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)
                ),
              ),
            ],
          ),
        ),
        DashboardSortingByKeywords
        (
          key: widget.dashboardSortingByKeywordsKey,
          allSessions: widget.allSessions, 
          filteredSessions: widget.filteredSessions, 
          usedKeywords: widget.usedKeywords,
          selectedKeywords: widget.selectedKeywords,
          dashboardCallbackFunctionToRefreshTheSessionsList: widget.parentCallbackFunctionToRefreshTheSessionsList
          ),
        // Bulk Deletion Button added here
        if (_selectedSessionsForDeletion.isNotEmpty)
          TextButton.icon
          (
            key: const Key('bulk_delete_button'),
            onPressed: _deleteSelectedSessions,
            icon: const Icon
            (
              Icons.delete, color: Colors.red),
              label: Text
              (
                "Delete (${_selectedSessionsForDeletion.length})",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ),
      ],
    );
  }
}