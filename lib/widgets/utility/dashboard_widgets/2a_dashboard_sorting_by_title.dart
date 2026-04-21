import 'package:flutter/material.dart';

import 'package:journeyers/utils/generic/dashboard/session_sorting_utils.dart';
import 'package:journeyers/widgets/utility/dashboard_const_strings.dart';

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling the sorting by title of session data.
class DashboardSortingByTitle extends StatefulWidget 
{
  /// List storing the sessions to sort.
  final List<dynamic>? filteredSessionsToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardSortingByTitle
  ({
    super.key,
    required this.filteredSessionsToSort,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList
  });

  @override
  State<DashboardSortingByTitle> createState() => _DashboardSortingByTitleState();
}

class _DashboardSortingByTitleState extends State<DashboardSortingByTitle> 
{
  bool _isAscendingTitle = true;   

  // Method used to sort session data by title 
  Future<void> _sortSessionsByTitle() async
  {
    await sortByTitle(list: widget.filteredSessionsToSort!, byAscendingTitle: _isAscendingTitle);
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
        "$sortByTitleLabel (${_isAscendingTitle ? 'A-Z' : 'Z-A'})",
        // TODO: style to externalize
        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }
}