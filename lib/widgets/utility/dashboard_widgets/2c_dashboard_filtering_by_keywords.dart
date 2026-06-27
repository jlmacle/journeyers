import 'package:flutter/material.dart';

import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling the filtering by keywords of session data.
class DashboardFilteringByKeywords extends StatefulWidget 
{
  /// List containing all available session metadata.
  final List<dynamic>? sessionsMetadataAll;

  /// List containing all filtered session metadata.
  final List<dynamic>? sessionsMetadataFiltered;

  /// List containing the keywords used by the sessions.
  final List<String> keywordsAll;

  /// List containing the selected keywords.
  final List<String> keywordsSelected;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const DashboardFilteringByKeywords
  ({
    super.key,
    required this.sessionsMetadataAll,
    required this.sessionsMetadataFiltered,
    required this.keywordsAll,
    required this.keywordsSelected,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
  });

  @override
  State<DashboardFilteringByKeywords> createState() => DashboardFilteringByKeywordsState();
}

class DashboardFilteringByKeywordsState extends State<DashboardFilteringByKeywords> 
{  
  // Used in DashboardPage.
  // Method used to filter the session data by keywords.
  Future<void> keywordsApplyFiltering() async
  {
    if (widget.keywordsSelected.isEmpty) 
    {
      // Working with the list while keeping the same reference
      widget.sessionsMetadataFiltered!.clear();
      widget.sessionsMetadataFiltered!.addAll(widget.sessionsMetadataAll!);
    } 
    else 
    {
      List <dynamic> sortingResults =
      widget.sessionsMetadataAll!.where
      ( 
        (session) 
        {
          final sessionKeywords = session[DashboardUtils.keyKeywords].cast<String>();
          return widget.keywordsSelected.every((k) => sessionKeywords.contains(k));
        }
      ).toList();
      
      // Working with the list while keeping the same reference
      widget.sessionsMetadataFiltered!.clear();
      widget.sessionsMetadataFiltered!.addAll(sortingResults);
    }

    // Refreshing the sessions list
    widget.dashboardCallbackFunctionToRefreshTheSessionsList();
  }

  // Method used to add/remove a keyword from the filtering criteria
  Future<void> _keywordToggleSelection(String keyword) async
  {
     if (widget.keywordsSelected.contains(keyword)) 
    {
      widget.keywordsSelected.remove(keyword);
    } 
    else 
    {
      widget.keywordsSelected.add(keyword);
    }

    // Applying the filtering by keywords
    await keywordsApplyFiltering();
  }

  // Used in DashboardPage.
  // Method used to refresh the keywords list after deletion of session data.
  void keywordsRefreshAfterSessionDeletion() 
  {
    // if no sessions left, nothing to do
    if (widget.sessionsMetadataAll == null) return;
    
    // Re-building the keywords' list from the remaining session data
    Set<String> remainingKws = {};
    for (var sessionData in widget.sessionsMetadataAll!) 
    {
      List<dynamic> kws = sessionData[DashboardUtils.keyKeywords];
      remainingKws.addAll(kws.cast<String>());
    }
    
    // Refreshing the used keywords' list, the selection of keywords, 
    // and the DashboardFilteringByKeywords widget
    setState
    (
      () 
      {
        widget.keywordsAll.clear();
        widget.keywordsAll.addAll(remainingKws);
        // Removing selected filters if the keyword no longer exists
        widget.keywordsSelected.removeWhere((kw) => !remainingKws.contains(kw));
      }
    );
  }

  @override
  void initState() {
    super.initState();
                                            
    pu.printdLine();
    pu.printd("DashboardFilteringByKeywords");
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
              widget.keywordsAll.toList()
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
                  onSelected: (_) async => await _keywordToggleSelection(kw),
                  selected: widget.keywordsSelected.contains(kw)
                );
              }
            ).toList(),
          ),
        );
  }
}