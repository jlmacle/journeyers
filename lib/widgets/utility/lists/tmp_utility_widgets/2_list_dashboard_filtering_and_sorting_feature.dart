import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/list_dashboard_const_strings.dart";
import "package:journeyers/widgets/utility/lists/tmp_utility_widgets/2a_list_dashboard_sorting_by_label.dart";
import "package:journeyers/widgets/utility/lists/tmp_utility_widgets/2c_list_dashboard_filtering_by_keywords.dart";

/// {@category Utility widgets}
/// {@category Lists}
/// A widget handling sorting and filtering of session data.
class ListDashboardSortingAndFilteringFeature extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// List containing all available lists data.
  final List<dynamic>? listsAll;

  /// List containing all filtered lists data.
  final List<dynamic>? listsFiltered;

  /// List containing the keywords used by the sessions.
  final List<String> keywordsAll;

  /// List containing the selected keywords.
  final List<String> keywordsSelected;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback parentCallbackFunctionToRefreshTheSessionsList;

  /// Global key used to identify the widget handling the filtering by keywords.
  final GlobalKey<ListDashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKey;

  const ListDashboardSortingAndFilteringFeature
  ({
    super.key,
    required this.dashboardContext,
    required this.listsAll,
    required this.listsFiltered,
    required this.keywordsAll,
    required this.keywordsSelected,
    required this.parentCallbackFunctionToRefreshTheSessionsList,
    required this.dashboardFilteringByKeywordsKey
  });

  @override
  State<ListDashboardSortingAndFilteringFeature> createState() => _ListDashboardSortingAndFilteringFeatureState();
}

class _ListDashboardSortingAndFilteringFeatureState extends State<ListDashboardSortingAndFilteringFeature> 
{  
  @override
  void initState() {
    super.initState();

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ListDashboardSortingAndFilteringFeature");
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
                  ListDashboardSortingByLabel
                  (
                    filteredListsToSort: widget.listsFiltered,
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
          listsAll: widget.listsAll, 
          listsFiltered: widget.listsFiltered, 
          keywordsAll: widget.keywordsAll,
          keywordsSelected: widget.keywordsSelected,
          dashboardCallbackFunctionToRefreshTheSessionsList: widget.parentCallbackFunctionToRefreshTheSessionsList
        ),  
      ],
    );
  }
}