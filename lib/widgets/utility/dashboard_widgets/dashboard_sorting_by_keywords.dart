import 'package:flutter/material.dart';

import 'package:journeyers/utils/project_specific/dashboard/dashboard_utils.dart';

/// {@category Utility widgets}
/// A widget handling the sorting by keywords of session data.
class DashboardSortingByKeywords extends StatefulWidget 
{
  /// List storing all available session data.
  final List<dynamic>? allSessions;

  /// List storing all filtered session data.
  final List<dynamic>? filteredSessions;

  /// List storing the keywords used in the session data.
  final List<String> usedKeywords;

  /// List storing the selected keywords.
  final List<String> selectedKeywords;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardSortingByKeywords
  ({
    super.key,
    required this.allSessions,
    required this.filteredSessions,
    required this.usedKeywords,
    required this.selectedKeywords,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
  });

  @override
  State<DashboardSortingByKeywords> createState() => DashboardSortingByKeywordsState();
}

class DashboardSortingByKeywordsState extends State<DashboardSortingByKeywords> 
{  
  // Method used to filter the session data by keywords
  Future<void> applyFilteringByKeywords() async
  {
    if (widget.selectedKeywords.isEmpty) 
    {
      // Working with the list while keeping the same reference
      widget.filteredSessions!.clear();
      widget.filteredSessions!.addAll(widget.allSessions!);
    } 
    else 
    {
      List <dynamic> sortingResults =
      widget.allSessions!.where
      ( 
        (session) 
        {
          final sessionKeywords = session[DashboardUtils.keyKeywords].cast<String>();
          return widget.selectedKeywords.every((k) => sessionKeywords.contains(k));
        }
      ).toList();
      
      // Working with the list while keeping the same reference
      widget.filteredSessions!.clear();
      widget.filteredSessions!.addAll(sortingResults);
    }

    // Refreshing the sessions list
    widget.dashboardCallbackFunctionToRefreshTheSessionsList();
  }

  // Method used to add/remove a keyword from the filtering criteria
  Future<void> _toggleKeywordSelection(String keyword) async
  {
     if (widget.selectedKeywords.contains(keyword)) 
    {
      widget.selectedKeywords.remove(keyword);
    } 
    else 
    {
      widget.selectedKeywords.add(keyword);
    }

    // Applying the filtering by keywords
    await applyFilteringByKeywords();
  }

  // Method used to refresh the keywords list after deletion of session data
  void refreshKeywordsAfterSessionDeletion() 
  {
    // if no sessions left, nothing to do
    if (widget.allSessions == null) return;
    
    // Re-building the keywords' list from the remaining session data
    List<String> remainingKws = [];
    for (var sessionData in widget.allSessions!) 
    {
      List<dynamic> kws = sessionData[DashboardUtils.keyKeywords];
      remainingKws.addAll(kws.cast<String>());
    }
    
    // Refreshing the used keywords' list, the selection of keywords, 
    // and the DashboardSortingByKeywords widget
    setState
    (
      () 
      {
        widget.usedKeywords.clear();
        widget.usedKeywords.addAll(remainingKws);
        // Removing selected filters if the keyword no longer exists
        widget.selectedKeywords.removeWhere((kw) => !remainingKws.contains(kw));
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return 
    Padding
        (
          padding: const EdgeInsets.only(left: 12.0, right:12, bottom: 12),
          child: Wrap
          (
            spacing: 8.0,
            children: 
            (
              widget.usedKeywords.toList()
              ..sort
              (
                (a, b) 
                {
                  // Different letters
                  int comparison = a.toLowerCase().compareTo(b.toLowerCase());  
                  // Same letter
                  if (comparison == 0) {return b.compareTo(a);}                                                
                  return comparison;
                }
              )
            ).map
            (
              (kw) 
              {
                return FilterChip
                (
                  label: Text(kw),
                  onSelected: (_) async => await _toggleKeywordSelection(kw),
                  selected: widget.selectedKeywords.contains(kw)
                );
              }
            ).toList(),
          ),
        );
  }
}