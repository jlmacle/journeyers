import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/database/text_lists_storage_externalized_strings.dart";

/// {@category Utility widgets}
/// {@category Lists}
/// A widget handling the filtering by keywords of lists.
class ParticipantsDashboardFilteringByKeywords extends StatefulWidget 
{
  /// List containing all available lists data.
  final List<dynamic>? listsAll;

  /// List containing all filtered lists data.
  final List<dynamic>? listsFiltered;

  /// List containing the keywords used by the lists.
  final List<String> keywordsAll;

  /// List containing the selected keywords.
  final List<String> keywordsSelected;

  /// Callback function used to refresh the sessions displayed.
  final VoidCallback dashboardCallbackFunctionToRefreshTheSessionsList;

  const ParticipantsDashboardFilteringByKeywords
  ({
    super.key,
    required this.listsAll,
    required this.listsFiltered,
    required this.keywordsAll,
    required this.keywordsSelected,
    required this.dashboardCallbackFunctionToRefreshTheSessionsList,
  });

  @override
  State<ParticipantsDashboardFilteringByKeywords> createState() => ParticipantsDashboardFilteringByKeywordsState();
}

class ParticipantsDashboardFilteringByKeywordsState extends State<ParticipantsDashboardFilteringByKeywords> 
{  
  // Used in ParticipantsDashboard.
  // Method used to filter the lists by keywords.
  Future<void> keywordsApplyFiltering() async
  {
    if (widget.keywordsSelected.isEmpty) 
    {
      // Working with the list while keeping the same reference
      widget.listsFiltered!.clear();
      widget.listsFiltered!.addAll(widget.listsAll!);
    } 
    else 
    {
      List <dynamic> sortingResults =
      widget.listsAll!.where
      ( 
        (session) 
        {
          final sessionKeywords = session[itemKeywordsKey].cast<String>();
          return widget.keywordsSelected.every((k) => sessionKeywords.contains(k));
        }
      ).toList();
      
      // Working with the list while keeping the same reference
      widget.listsFiltered!.clear();
      widget.listsFiltered!.addAll(sortingResults);
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

  // Used in ParticipantsDashboard.
  // Method used to refresh the keywords list after deletion of session data.
  Future<void> keywordsRefreshAfterSessionDeletion() async
  {
    // if no lists left, nothing to do
    if (widget.listsAll == null) return;
    
    // Re-building the keywords" list from the remaining lists data
    Set<String> remainingKws = {};
    for (var currentListData in widget.listsAll!) 
    {
      List<dynamic> kws = currentListData[itemKeywordsKey];
      remainingKws.addAll(kws.cast<String>());
    }
    
    // Refreshing the used keywords" list, the selection of keywords, 
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
            
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ParticipantsDashboardFilteringByKeywords");
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