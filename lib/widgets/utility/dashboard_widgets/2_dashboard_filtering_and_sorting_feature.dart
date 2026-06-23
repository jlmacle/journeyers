import 'package:flutter/material.dart';

import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2a_dashboard_sorting_by_title.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2b_dashboard_sorting_by_date.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2c_dashboard_filtering_by_keywords.dart';

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling sorting and filtering of session data.
class DashboardSortingAndFilteringFeature extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// List containing all available session data.
  final List<dynamic>? sessionsAll;

  /// List containing all filtered session data.
  final List<dynamic>? sessionsFiltered;

  /// List containing the keywords used by the sessions.
  final List<String> keywordsAll;

  /// List containing the selected keywords.
  final List<String> keywordsSelected;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback parentCallbackFunctionToRefreshTheSessionsList;

  /// Global key used to identify the widget handling the filtering by keywords.
  final GlobalKey<DashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKey;

  const DashboardSortingAndFilteringFeature
  ({
    super.key,
    required this.dashboardContext,
    required this.sessionsAll,
    required this.sessionsFiltered,
    required this.keywordsAll,
    required this.keywordsSelected,
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
                    filteredSessionsToSort: widget.sessionsFiltered,
                    dashboardCallbackFunctionToRefreshTheSessionsList: widget.parentCallbackFunctionToRefreshTheSessionsList
                  ),
                  // Sorting by date
                  DashboardSortingByDate
                  (
                    filteredSessionsToSort: widget.sessionsFiltered,
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
        DashboardFilteringByKeywords
        (
          key: widget.dashboardFilteringByKeywordsKey,
          sessionsAll: widget.sessionsAll, 
          sessionsFiltered: widget.sessionsFiltered, 
          keywordsAll: widget.keywordsAll,
          keywordsSelected: widget.keywordsSelected,
          dashboardCallbackFunctionToRefreshTheSessionsList: widget.parentCallbackFunctionToRefreshTheSessionsList
        ),  
      ],
    );
  }
}