import 'package:flutter/material.dart';

import 'package:journeyers/utils/generic/dashboard/session_sorting_utils.dart';
import 'package:journeyers/utils/generic/date/date_formats_utils.dart';
import 'package:journeyers/widgets/utility/lists/list_dashboard_const_strings.dart';

/// {@category Utility widgets}
/// {@category Lists}
/// A widget handling the sorting by date of session data.
class ListDashboardSortingByDate extends StatefulWidget 
{
  /// List containing the sessions to sort.
  final List<dynamic>? sessionsToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const ListDashboardSortingByDate
  ({
    super.key,
    required this.sessionsToSort,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
  });

  @override
  State<ListDashboardSortingByDate> createState() => ListDashboardSortingByDateState();
}

class ListDashboardSortingByDateState extends State<ListDashboardSortingByDate> 
{
  bool _isAscendingDate = false;   

  // Method used to sort session data by date
  Future<void> _sortSessionsByDate() async
  {
    await sortSessionByDateAddJm(list: widget.sessionsToSort!, dateFormat: DateFormatsUtils.dateFormatMMMMddyyyy, byAscendingDate: _isAscendingDate);
    widget.dashboardCallbackFunctionToRefreshTheSessionsList();
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
        await _sortSessionsByDate();
      },
      icon: Icon
      (
        _isAscendingDate ? Icons.arrow_upward : Icons.arrow_downward,
        color: Colors.black,
      ),
      label: const Text
      (
        sortByDateLabel,
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }
}