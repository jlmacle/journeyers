import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/utils/generic/dashboard/session_sorting_utils.dart";
import "package:journeyers/utils/generic/date/date_formats_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling the sorting by date of session data.
class DashboardSortingByDate extends StatefulWidget 
{
  /// List containing the sessions to sort.
  final List<dynamic>? sessionsMetadataFilteredToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardSortingByDate
  ({
    super.key,
    required this.sessionsMetadataFilteredToSort,
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
    await sortSessionByDateAddJm
    (
      context: context,
      list: widget.sessionsMetadataFilteredToSort!, 
      dateFormat: DateFormatsUtils.dateFormatMMMMddyyyy, 
      byAscendingDate: _isAscendingDate
    );
    widget.dashboardCallbackFunctionToRefreshTheSessionsList();
  }

  @override
  void initState() {
    super.initState();
                                        
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("DashboardSortingByDate");
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
      label: Text
      (
        AppLocalizations.of(context)?.ca_dashboard_sort_by_date ?? "Issue with the 'Sort by Date' label",
        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }
}