import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/participants_dashboard_const_strings.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/2a_participants_dashboard_sorting_by_label.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/2c_participants_dashboard_filtering_by_keywords.dart";

/// {@category Utils - Project-specific}
/// {@category Lists}
/// A widget handling sorting and filtering of lists on the participants lists dashboard.
class ParticipantsListsDashboardSortingAndFilteringFeature extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// List containing all available lists data.
  final List<dynamic>? participantsListsAll;

  /// List containing all filtered lists data.
  final List<dynamic>? participantsListsFiltered;

  /// List containing the keywords used by the sessions.
  final List<String> keywordsAll;

  /// List containing the selected keywords.
  final List<String> keywordsSelected;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheParticipantsLists;

  /// Global key used to identify the widget handling the filtering by keywords.
  final GlobalKey<ParticipantsListsDashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKey;

  const ParticipantsListsDashboardSortingAndFilteringFeature
  ({
    super.key,
    required this.dashboardContext,
    required this.participantsListsAll,
    required this.participantsListsFiltered,
    required this.keywordsAll,
    required this.keywordsSelected,
    required this.dashboardCallbackFunctionToRefreshTheParticipantsLists,
    required this.dashboardFilteringByKeywordsKey
  });

  @override
  State<ParticipantsListsDashboardSortingAndFilteringFeature> createState() => _ParticipantsListsDashboardSortingAndFilteringFeatureState();
}

class _ParticipantsListsDashboardSortingAndFilteringFeatureState extends State<ParticipantsListsDashboardSortingAndFilteringFeature> 
{  
  @override
  void initState() {
    super.initState();

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ParticipantsListsDashboardSortingAndFilteringFeature");
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
                  ParticipantsListsDashboardSortingByLabel
                  (
                    participantsListsFilteredToSort: widget.participantsListsFiltered,
                    featureCallbackFunctionToRefreshTheParticipantsLists: widget.dashboardCallbackFunctionToRefreshTheParticipantsLists
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
        ParticipantsListsDashboardFilteringByKeywords
        (
          key: widget.dashboardFilteringByKeywordsKey,
          participantsListsAll: widget.participantsListsAll, 
          participantsListsFiltered: widget.participantsListsFiltered, 
          keywordsAll: widget.keywordsAll,
          keywordsSelected: widget.keywordsSelected,
          featureCallbackFunctionToRefreshTheParticipantsLists: widget.dashboardCallbackFunctionToRefreshTheParticipantsLists
        ),  
      ],
    );
  }
}