import 'package:flutter/material.dart';

import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';

/// {@category Utility widgets}
/// A widget handling the sorting by title of session data.
class DashboardFilteringByTitle extends StatefulWidget 
{
  /// List storing the sessions to sort.
  final List<dynamic>? filteredSessionsToSort;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardFilteringByTitle
  ({
    super.key,
    required this.filteredSessionsToSort,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList
  });

  @override
  State<DashboardFilteringByTitle> createState() => _DashboardFilteringByTitleState();
}

class _DashboardFilteringByTitleState extends State<DashboardFilteringByTitle> 
{
  bool _isAscendingTitle = true;   

  // Method used to sort session data by title 
  Future<void> _sortSessionsByTitle() async
  {
    widget.filteredSessionsToSort?.sort((a, b) 
    {
      String titleA = (a[DashboardUtils.keyTitle]).toString().toLowerCase();
      String titleB = (b[DashboardUtils.keyTitle]).toString().toLowerCase();
      
      return _isAscendingTitle 
          ? titleA.compareTo(titleB) 
          : titleB.compareTo(titleA);
    });
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
        "Sort by Title (${_isAscendingTitle ? 'A-Z' : 'Z-A'})",
        // TODO: style to externalize
        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      ),
    );
  }
}