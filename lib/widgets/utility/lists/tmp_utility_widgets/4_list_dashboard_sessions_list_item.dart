import 'package:flutter/material.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/typedefs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/lists/models/text_lists_storage_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/list_dashboard_const_strings.dart';


/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget handling a session data.
class ListOfListsItem extends StatefulWidget 
{
  /// The session metadata.
  final Map<String, dynamic> listData;

  /// The index within the list.
  final int index;

  /// Boolean to indicate if the checkbox is checked.
  final bool isChecked;

  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// A callback function called when the checkbox is checked/unchecked.
  final ValueChanged<bool?> onCheckboxChangedCallbackFunction;

  /// A callback function called when the title is updated.
  final VoidCallback onEditTitleCallbackFunction;

  // A callback function called when editing the session data.
  final VoidCallback onEditPressedCallbackFunction;

  /// A callback function called when session data is edited.
  final FunctionDTOCAForm2StringsAndBool onEditSessionDataCallbackFunction;

  /// A callback function called when the keywords are updated.
  final FunctionSetStringMapStringDynamicAndString onKeywordsUpdatedCallbackFunction;

  /// A callback function called when the delete icon is interacted with.
  final VoidCallback onDeleteCallbackFunction;

  const ListOfListsItem({
    super.key,
    required this.listData,
    required this.index,
    required this.isChecked,
    required this.dashboardContext,
    required this.onCheckboxChangedCallbackFunction,
    required this.onEditTitleCallbackFunction,
    required this.onEditPressedCallbackFunction,
    required this.onEditSessionDataCallbackFunction,
    required this.onKeywordsUpdatedCallbackFunction,
    required this.onDeleteCallbackFunction,
  });

  @override
  State<ListOfListsItem> createState() => _ListOfListsItemState();
}

class _ListOfListsItemState extends State<ListOfListsItem> 
{
  TextEditingController kwsEditController = .new();

  // To clean
  Future<void> onKeywordsUpdated({required String? listKey, required Map<String, dynamic> listData}) async
  {
    // Splitting string into list, trimming whitespaces, and removing empty entries
    final Set<String> updatedKeywords = kwsEditController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    if (sessionDataDebug) pu.printd("Session Data: ElevatedButton: onPressed: updatedKeywords: $updatedKeywords");
    // Calling the parent callback for state 
    await widget.onKeywordsUpdatedCallbackFunction(listKey: listKey, updatedKeywords: updatedKeywords, listData: listData);

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

 
  @override void dispose() 
  {
    kwsEditController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) 
  {
    // Gets the title
    final String sessionTitle = widget.listData[itemTextKey];
    // Modifies the title according to context (ca or gps)
    final String displayTitle = (widget.dashboardContext == DashboardUtils.gpsContext)
        ? "$sessionTitle$gpsTitleSuffix"
        : sessionTitle;

    // Sorting keywords for display
    final Set<String> sortedKeywords = 
    Set<String>.from(widget.listData[itemKeywordsKey])
    ..toList().sort((a, b) 
    {
        int comparison = a.toLowerCase().compareTo(b.toLowerCase());
        return comparison == 0 ? b.compareTo(a) : comparison;
    });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox used for bulk deletion
                Checkbox(
                  key: ValueKey('checkbox-${widget.index}'),
                  value: widget.isChecked,
                  onChanged: widget.onCheckboxChangedCallbackFunction,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          // For the edition of the title
                          GestureDetector(
                            onTap: widget.onEditTitleCallbackFunction,
                            child: Text(
                              displayTitle,
                              key: ValueKey('session-title-${widget.index}'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          
                        ],
                      ),
                      const SizedBox(height: 4),
                      // For the edition of the keywords
                      GestureDetector(
                        onTap: () => _showKeywordsEditSheet
                        (
                          context: context,
                          dashboardContext: widget.dashboardContext,                          
                          currentKeywords: widget.listData[itemKeywordsKey],
                          listKey: widget.listData[itemKey],
                          kwsEditController: kwsEditController,
                          onKeywordsUpdatedCallbackFunction: widget.onKeywordsUpdatedCallbackFunction,
                          onKeywordsUpdated: onKeywordsUpdated,
                          listData: widget.listData
                          ),
                        child: Text(
                          "Keywords: ${sortedKeywords.join(', ')}",
                          key: ValueKey('session-keywords-${widget.index}'),
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 4,
                  children: [                    
                    // To edit the keywords
                    IconButton(
                      icon: const Icon(Icons.style_rounded),
                      onPressed:  () => _showKeywordsEditSheet
                      (
                        context: context,
                        dashboardContext: widget.dashboardContext,
                        currentKeywords: widget.listData[itemKeywordsKey],
                        listKey: widget.listData[itemKey],
                        kwsEditController: kwsEditController,
                        onKeywordsUpdatedCallbackFunction: widget.onKeywordsUpdatedCallbackFunction,
                        onKeywordsUpdated: onKeywordsUpdated,
                        listData: widget.listData
                      ),
                      tooltip: keywordsTooltipLabel,
                    ),
                  ],
                ),
                // To delete session metadata and file
                IconButton(
                  key: ValueKey('session-delete-${widget.index}'),
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: widget.onDeleteCallbackFunction,
                  tooltip: deleteTooltipLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showKeywordsEditSheet
({
  required BuildContext context, required String dashboardContext, 
  required List<dynamic> currentKeywords, required String? listKey, 
  required TextEditingController kwsEditController,
  required FunctionSetStringMapStringDynamicAndString onKeywordsUpdatedCallbackFunction,
  required FunctionStringAndMapStringDynamic onKeywordsUpdated,
  required Map<String, dynamic> listData


}) {
  // Converting list to a comma-separated string for editing
  kwsEditController.text = currentKeywords.join(', '); 
  
  showModalBottomSheet
  (
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    isScrollControlled: true,
    builder: (context) => Padding
    (
      padding: EdgeInsets.only
      (
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column
      (
        mainAxisSize: MainAxisSize.min,
        children: 
        [
          TextField
          (
            controller: kwsEditController,
            autofocus: true,
            decoration: const InputDecoration
            (
              labelText: keywordsTextFieldLabel, 
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Please enter your keywords.',
            ),
            onSubmitted: (_) async => onKeywordsUpdated(listKey: listKey, listData: listData)
          ),       
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async =>  onKeywordsUpdated(listKey: listKey, listData: listData),
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );

}

