import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dashboard/session_sorting_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/participants_dashboard_const_strings.dart";


/// {@category Utils - Project-specific}
/// {@category Lists}
/// A widget handling the sorting of lists by label on the participants lists dashboard.
class ParticipantsListsDashboardSortingByLabel extends StatefulWidget 
{
  /// List containing the filtered lists to sort.
  final List<dynamic>? participantsListsFilteredToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback featureCallbackFunctionToRefreshTheParticipantsLists;

  const ParticipantsListsDashboardSortingByLabel
  ({
    super.key,
    required this.participantsListsFilteredToSort,
    required this.featureCallbackFunctionToRefreshTheParticipantsLists
  });

  @override
  State<ParticipantsListsDashboardSortingByLabel> createState() => _ParticipantsListsDashboardSortingByLabelState();
}

class _ParticipantsListsDashboardSortingByLabelState extends State<ParticipantsListsDashboardSortingByLabel> 
{
  // Random alphabetical order by default
  bool _isAscendingLabel = false;   

  // Method used to sort session data by title 
  Future<void> _sortListsByLabel() async
  {
    await sortListsByLabel(list: widget.participantsListsFilteredToSort!, byAscendingLabel: _isAscendingLabel);
  }

  @override
  void initState() {
    super.initState();
    
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ParticipantsListsDashboardSortingByLabel");
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
        widget.featureCallbackFunctionToRefreshTheParticipantsLists();
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