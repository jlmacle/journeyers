import 'package:flutter/material.dart';

import 'package:journeyers/widgets/utility/lists/list_dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/2a_list_dashboard_sorting_by_label.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/2c_list_dashboard_filtering_by_keywords.dart';

/// {@category Utility widgets}
/// {@category Lists}
/// A widget handling sorting and filtering of session data.
class ListDashboardSortingAndFilteringFeature extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// List containing all available lists data.
  final List<dynamic>? allLists;

  /// List containing all filtered lists data.
  final List<dynamic>? filteredLists;

  /// List containing the keywords used by the sessions.
  final List<String> usedKeywords;

  /// List containing the selected keywords.
  final List<String> selectedKeywords;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback parentCallbackFunctionToRefreshTheSessionsList;

  /// Global key used to identify the widget handling the filtering by keywords.
  final GlobalKey<ListDashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKey;

  const ListDashboardSortingAndFilteringFeature
  ({
    super.key,
    required this.dashboardContext,
    required this.allLists,
    required this.filteredLists,
    required this.usedKeywords,
    required this.selectedKeywords,
    required this.parentCallbackFunctionToRefreshTheSessionsList,
    required this.dashboardFilteringByKeywordsKey
  });

  @override
  State<ListDashboardSortingAndFilteringFeature> createState() => _ListDashboardSortingAndFilteringFeatureState();
}

class _ListDashboardSortingAndFilteringFeatureState extends State<ListDashboardSortingAndFilteringFeature> 
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
                  ListDashboardSortingByLabel
                  (
                    filteredListsToSort: widget.filteredLists,
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
        ListDashboardFilteringByKeywords
        (
          key: widget.dashboardFilteringByKeywordsKey,
          allLists: widget.allLists, 
          filteredLists: widget.filteredLists, 
          usedKeywords: widget.usedKeywords,
          selectedKeywords: widget.selectedKeywords,
          dashboardCallbackFunctionToRefreshTheSessionsList: widget.parentCallbackFunctionToRefreshTheSessionsList
        ),  
      ],
    );
  }
}