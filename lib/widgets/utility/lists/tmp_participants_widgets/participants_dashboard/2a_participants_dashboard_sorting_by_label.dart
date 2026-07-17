import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dashboard/session_sorting_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/participants_dashboard_const_strings.dart";


/// {@category Utils - Project-specific}
/// {@category Lists}
/// A widget handling the sorting by title of session data.
class ParticipantsDashboardSortingByLabel extends StatefulWidget 
{
  /// List containing the filtered lists to sort.
  final List<dynamic>? filteredListsToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const ParticipantsDashboardSortingByLabel
  ({
    super.key,
    required this.filteredListsToSort,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList
  });

  @override
  State<ParticipantsDashboardSortingByLabel> createState() => _ParticipantsDashboardSortingByLabelState();
}

class _ParticipantsDashboardSortingByLabelState extends State<ParticipantsDashboardSortingByLabel> 
{
  // Random alphabetical order by default
  bool _isAscendingLabel = false;   

  // Method used to sort session data by title 
  Future<void> _sortListsByLabel() async
  {
    await sortListsByLabel(list: widget.filteredListsToSort!, byAscendingLabel: _isAscendingLabel);
  }

  @override
  void initState() {
    super.initState();
    
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ParticipantsDashboardSortingByLabel");
  }

  @override
  Widget build(BuildContext context) {
    return 
    TextButton.icon
    (
      onPressed: () async 
      {
        _isAscendingLabel = !_isAscendingLabel;
        // Updating the widget UI
        setState((){});
        
        // Sorting
        await _sortListsByLabel();        
        // Updating the sessions list UI
        widget.dashboardCallbackFunctionToRefreshTheSessionsList();
      },
      icon: const Icon
      (
        Icons.sort_by_alpha,
        color: Colors.black,
      ),
      label: Text
      (
        "$listsSortByLabel (${_isAscendingLabel ? "Z-A" : "A-Z"})",
        // TODO: style to externalize
        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }
}