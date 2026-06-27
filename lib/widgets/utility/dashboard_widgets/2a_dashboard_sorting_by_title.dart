import 'package:flutter/material.dart';

import 'package:journeyers/utils/generic/dashboard/session_sorting_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_const_strings.dart';

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling the sorting by title of session data.
class DashboardSortingByTitle extends StatefulWidget 
{
  /// List containing the filtered sessions to sort.
  final List<dynamic>? sessionsMetadataFilteredToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardSortingByTitle
  ({
    super.key,
    required this.sessionsMetadataFilteredToSort,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList
  });

  @override
  State<DashboardSortingByTitle> createState() => _DashboardSortingByTitleState();
}

class _DashboardSortingByTitleState extends State<DashboardSortingByTitle> 
{
  // Random alphabetical order by default
  bool _isAscendingTitle = false;   

  // Method used to sort session data by title 
  Future<void> _sortSessionsByTitle() async
  {
    await sortDashboardSessionsByTitle(list: widget.sessionsMetadataFilteredToSort!, byAscendingTitle: _isAscendingTitle);
  }


  @override
  void initState() {
    super.initState();
                                    
    pu.printdLine();
    pu.printd("DashboardSortingByTitle");
  }

  @override
  Widget build(BuildContext context) {
    return 
    TextButton.icon
    (
      onPressed: () async 
      {
        _isAscendingTitle = !_isAscendingTitle;
        // Updating the widget UI
        setState((){});
        
        // Sorting
        await _sortSessionsByTitle();        
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
        "$sortByTitle (${_isAscendingTitle ? 'Z-A' : 'A-Z'})",
        // TODO: style to externalize
        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }
}