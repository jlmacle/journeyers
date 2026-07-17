import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dashboard/session_sorting_utils.dart";
import "package:journeyers/utils/generic/date/date_formats_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/participants_dashboard_const_strings.dart";

/// {@category Utils - Project-specific}
/// {@category Lists}
/// A widget handling the sorting by date of session data.
class ParticipantsDashboardSortingByDate extends StatefulWidget 
{
  /// List containing the sessions to sort.
  final List<dynamic>? filteredListsToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const ParticipantsDashboardSortingByDate
  ({
    super.key,
    required this.filteredListsToSort,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
  });

  @override
  State<ParticipantsDashboardSortingByDate> createState() => ParticipantsDashboardSortingByDateState();
}

class ParticipantsDashboardSortingByDateState extends State<ParticipantsDashboardSortingByDate> 
{
  bool _isAscendingDate = false;   

  // Method used to sort session data by date
  Future<void> _sortListsByDate() async
  {
    await sortSessionByDateAddJm(list: widget.filteredListsToSort!, dateFormat: DateFormatsUtils.dateFormatMMMMddyyyy, byAscendingDate: _isAscendingDate);
    widget.dashboardCallbackFunctionToRefreshTheSessionsList();
  }

  @override
  void initState() {
    super.initState();
        
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ParticipantsDashboardSortingByDate");
  }

  @override
  Widget build(BuildContext context) {
    return 
    TextButton.icon
    (
      onPressed: () async
      {
        _isAscendingDate = !_isAscendingDate;   
        // Updating the widget     
        setState((){});
        // Sorting and updating the sessions list
        await _sortListsByDate();
      },
      icon: Icon
      (
        _isAscendingDate ? Icons.arrow_upward : Icons.arrow_downward,
        color: Colors.black,
      ),
      label: const Text
      (
        listsSortByDate,
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }
}