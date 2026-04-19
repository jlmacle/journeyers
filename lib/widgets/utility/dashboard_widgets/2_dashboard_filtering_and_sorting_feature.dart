import 'package:flutter/material.dart';

import 'package:journeyers/widgets/utility/dashboard_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2a_dashboard_sorting_by_title.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2b_dashboard_sorting_by_date.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2c_dashboard_filtering_by_keywords.dart';

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling sorting and filtering of session data.
class DashboardSortingAndFilteringFeature extends StatefulWidget 
{
  /// The context for the dashboard (context analyses or group problem-solving sessions).
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
  final GlobalKey<DashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKey;

  const DashboardSortingAndFilteringFeature
  ({
    super.key,
    required this.dashboardContext,
    required this.allSessions,
    required this.filteredSessions,
    required this.usedKeywords,
    required this.selectedKeywords,
    required this.parentCallbackFunctionToRefreshTheSessionsList,
    required this.dashboardFilteringByKeywordsKey
  });

  @override
  State<DashboardSortingAndFilteringFeature> createState() => _DashboardSortingAndFilteringFeatureState();
}

class _DashboardSortingAndFilteringFeatureState extends State<DashboardSortingAndFilteringFeature> 
{  
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
                  DashboardSortingByTitle
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text // TODO: to move
                (
                  filterByKeywordsLabel, 
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)
                ),
              ),
            ],
          ),
        ),
        // Filtering by keywords
        Flexible(
          child: SingleChildScrollView(
            key: const Key('dashboard-scrollview'),
            child: DashboardFilteringByKeywords
            (
              key: widget.dashboardFilteringByKeywordsKey,
              allSessions: widget.allSessions, 
              filteredSessions: widget.filteredSessions, 
              usedKeywords: widget.usedKeywords,
              selectedKeywords: widget.selectedKeywords,
              dashboardCallbackFunctionToRefreshTheSessionsList: widget.parentCallbackFunctionToRefreshTheSessionsList
            ),
          ),
        ),      
      ],
    );
  }
}