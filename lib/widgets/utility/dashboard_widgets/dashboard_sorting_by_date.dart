import 'package:flutter/material.dart';

import 'package:journeyers/utils/generic/dashboard/session_sorting_utils.dart';
import 'package:journeyers/utils/project_specific/dashboard/dashboard_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_sorting_by_date_config.dart';

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling the sorting by date of session data.
class DashboardSortingByDate extends StatefulWidget 
{
  /// List storing the sessions to sort.
  final List<dynamic>? sessionsToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardSortingByDate
  ({
    super.key,
    required this.sessionsToSort,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
  });

  @override
  State<DashboardSortingByDate> createState() => DashboardSortingByDateState();
}

class DashboardSortingByDateState extends State<DashboardSortingByDate> 
{
  bool _isAscendingDate = false;   

  // Method used to sort session data by date
  Future<void> _sortSessionsByDate() async
  {
    await sortSessionByDateAddJm(list: widget.sessionsToSort!, dateFormat: dateFormatForSorting, byAscendingDate: _isAscendingDate);
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
        _isAscendingDate ? Icons.arrow_downward : Icons.arrow_upward,
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