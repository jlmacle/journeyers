import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/type_defs.dart";
import "package:journeyers/widgets/utility/lists/database/participants_lists_db.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/type_defs2.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/participants_dashboard_const_strings.dart";
import "package:journeyers/widgets/utility/lists/database/participants_lists_db_externalized_strings.dart";

// todo: code to clean
/// {@category Utils - Project-specific}
/// {@category Lists}
/// A widget handling a single participants list data on the participants lists dashboard.
class ParticipantsListsItem extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// The session metadata.
  final Map<String, dynamic> listMetadata;

  /// The index within the list.
  final int listIndex;

  /// Boolean to indicate if the checkbox is checked.
  final bool isChecked;  

  /// A callback function called when the checkbox is checked/unchecked.
  final ValueChanged<bool?> onCheckboxChangedCallbackFunction;

  /// A callback function called when session data is retrieved before edition.
  final OnRetrievedSessionDataBeforeEditionCallbackFunctionType onRetrievedSessionDataBeforeEditionCallbackFunction;

  /// A callback function called when the keywords are updated.
  final OnParticipantListsItemSetStringUpdatedCallbackFunctionType onKeywordsUpdatedCallbackFunction;

  /// A callback function called when the participants are updated.
  final OnParticipantListsItemSetStringUpdatedCallbackFunctionType onParticipantsUpdatedCallbackFunction;

  /// A callback function called when the list is updated.
  final OnListNameUpdatedCallbackFunctionType  onListNameUpdatedCallbackFunction;
 

  /// A callback function called when the participants list is loaded.
  final ValueChanged<List<String>> onParticipantsLoadedCallbackFunction;

  /// A callback function called when the delete icon is interacted with.
  final VoidCallback onDeleteCallbackFunction;

  const ParticipantsListsItem({
    super.key,
    required this.listMetadata,
    required this.listIndex,
    required this.isChecked,
    required this.dashboardContext,
    required this.onCheckboxChangedCallbackFunction,
    required this.onRetrievedSessionDataBeforeEditionCallbackFunction,
    required this.onKeywordsUpdatedCallbackFunction,
    required this.onListNameUpdatedCallbackFunction,
    required this.onParticipantsUpdatedCallbackFunction,
    required this.onParticipantsLoadedCallbackFunction,
    required this.onDeleteCallbackFunction,
  });

  @override
  State<ParticipantsListsItem> createState() => _ParticipantsListsItemState();
}

class _ParticipantsListsItemState extends State<ParticipantsListsItem> 
{
  final _listsDB = ParticipantsListsDB();
  List<String> _participantsCurrent = [];
  String _listNameCurrent = "";
  final TextEditingController _listNameEditTfec = .new();
  final TextEditingController _participantsEditTfec = .new();
  final TextEditingController _kwsEditTfec = .new();
  

  // To clean
  Future<void> _onKeywordsUpdated({required String? listKey, required Map<String, dynamic> listData}) async
  {
    // Splitting string into list, trimming whitespaces, and removing empty entries
    final Set<String> updatedKeywords = _kwsEditTfec.text
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    if (sessionDataDebug) pu.printd("Session Data: ElevatedButton: onPressed: updatedKeywords: $updatedKeywords");
    // Calling the parent callback for state 
    await widget.onKeywordsUpdatedCallbackFunction(listKey: listKey, updatedItems: updatedKeywords, listData: listData);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // To clean
  Future<void> _onListNameUpdated({required String? listKey, required Map<String, dynamic> listData}) async
  {
    if (listDebug) pu.printd("List Debug: ParticipantsListsItem: _onListNameUpdated");

    // Calling the parent callback for state 
    await widget.onListNameUpdatedCallbackFunction(listKey: listKey!, listData: listData);

    if (!mounted) return;
    Navigator.of(context).pop();
  }


  // To clean
  Future<void> _onParticipantsUpdated({required String? listKey, required Map<String, dynamic> listData}) async
  {
    // Splitting string into list, trimming whitespaces, and removing empty entries
    final Set<String> updatedParticipants = _participantsEditTfec.text
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    // Updating _currentParticipants for list loading
    _participantsCurrent = updatedParticipants.toList();

    if (sessionDataDebug) pu.printd("Session Data: ElevatedButton: onPressed: updatedParticipants: $updatedParticipants");
    // Calling the parent callback for state 
    await widget.onParticipantsUpdatedCallbackFunction(listKey: listKey, updatedItems: updatedParticipants, listData: listData);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

 @override
  void initState() {
    super.initState();
    
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ParticipantsListsItem");

    List<Map<String, dynamic>> subItemsDataList =
    ((widget.listMetadata[subItemsDataListKey]) as List)
        .cast<Map<String, dynamic>>();
    Map<String, String> namesKeysMap = _listsDB.getNamesKeys(subItemsDataList);
    _participantsCurrent =  namesKeysMap.keys.toList();

  }
 
  @override void dispose() 
  {
    _kwsEditTfec.dispose();
    _listNameEditTfec.dispose();
    _participantsEditTfec.dispose();
    super.dispose();
  }

  // Method used to get the participants" list
  List<String> _getParticipants(Map<String, dynamic> listData)
  {

    List<String> participants = [];

    // Retrieving the text for each sub-item
    var subItemsDataList = listData[subItemsDataListKey];

    for (var subItemDataIndex = 0; subItemDataIndex < subItemsDataList.length; subItemDataIndex++)
    {
      Map<String, dynamic> subItemsData = subItemsDataList[subItemDataIndex]
                                        .values.first as Map<String, dynamic>;
      var name = subItemsData[itemTextKey];
      participants.add(name);
    }    

    return participants;
  }
  
  @override
  Widget build(BuildContext context) 
  {
    // Gets the title
    final String displayTitle = widget.listMetadata[itemTextKey];

    // Sorting keywords for display
    final List<String> sortedKeywords = 
    List<String>.from(widget.listMetadata[itemKeywordsKey])..sort();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox used for bulk deletion
                Checkbox(
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
                          // For the edition of the list label
                          GestureDetector(
                            onTap: () => _showListNameEditSheet
                                (
                                  context: context,
                                  dashboardContext: widget.dashboardContext,                          
                                  currentListName: displayTitle,
                                  listKey: widget.listMetadata[itemKey],
                                  listNameEditTec: _participantsEditTfec,
                                  onParticipantsUpdatedCallbackFunction: widget.onParticipantsUpdatedCallbackFunction,
                                  onListNameUpdated: _onListNameUpdated,
                                  listData: widget.listMetadata
                                ),
                            child: Text(
                              displayTitle,
                              // todo: to clean
                              key: Key("session-title-${widget.listIndex}"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          
                        ],
                      ),
                      const SizedBox(height: 4),
                      // For the edition of the participants
                      GestureDetector
                      (
                        onTap:  
                          () => _showParticipantsEditSheet
                                (
                                  context: context,
                                  dashboardContext: widget.dashboardContext,                          
                                  currentParticipants: _participantsCurrent,
                                  listKey: widget.listMetadata[itemKey],
                                  participantsTec: _participantsEditTfec,
                                  onParticipantsUpdatedCallbackFunction: widget.onParticipantsUpdatedCallbackFunction,
                                  onParticipantsUpdated: _onParticipantsUpdated,
                                  listData: widget.listMetadata
                                ),
                        child: Wrap
                        (
                          spacing: 8.0,
                          children: 
                          (
                            _getParticipants(widget.listMetadata)
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
                            (participant) 
                            {
                              return                  
                              Container(
                                key: Key("session-participants-container-${widget.listIndex}-${participant}"),
                                decoration: BoxDecoration
                                (
                                  color: Colors.transparent,  
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: black), 
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Text
                                (
                                  participant,                                      
                                ),
                              );
                            }
                          ).toList(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // For the edition of the keywords
                      GestureDetector(
                        onTap: () => _showKeywordsEditSheet
                        (
                          context: context,
                          dashboardContext: widget.dashboardContext,                          
                          currentKeywords: widget.listMetadata[itemKeywordsKey],
                          listKey: widget.listMetadata[itemKey],
                          kwsEditController: _kwsEditTfec,
                          onKeywordsUpdatedCallbackFunction: widget.onKeywordsUpdatedCallbackFunction,
                          onKeywordsUpdated: _onKeywordsUpdated,
                          listData: widget.listMetadata
                          ),
                        child: Text(
                          "Keywords: ${sortedKeywords.join(", ")}",
                          key: Key("session-keywords-${widget.listIndex}"),
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
                // Left icon — pinned to row start
                IconButton(
                  icon: const Icon(Icons.style_rounded),
                  onPressed: () => _showKeywordsEditSheet(
                    context: context,
                    dashboardContext: widget.dashboardContext,
                    currentKeywords: widget.listMetadata[itemKeywordsKey],
                    listKey: widget.listMetadata[itemKey],
                    kwsEditController: _kwsEditTfec,
                    onKeywordsUpdatedCallbackFunction: widget.onKeywordsUpdatedCallbackFunction,
                    onKeywordsUpdated: _onKeywordsUpdated,
                    listData: widget.listMetadata,
                  ),
                  tooltip: keywordsTooltipLabel,
                ),

                // Center content — wraps if needed
                Wrap(
                  children: [
                    ElevatedButton(
                      child: const Text(loadingButtonLabel),
                      onPressed: () 
                      {
                        if (listDebug) pu.printd("List debug: Participants Lists: Lists display: List: Click to load: _currentParticipants: $_participantsCurrent");
                        widget.onParticipantsLoadedCallbackFunction(_participantsCurrent);
                        // To close the lists display
                        Navigator.pop(context);
                        // To close the list loading/creation menu
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                // Right icon — pinned to row end
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: widget.onDeleteCallbackFunction,
                  tooltip: listsDeleteTooltipLabel,
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
  required OnParticipantListsItemSetStringUpdatedCallbackFunctionType onKeywordsUpdatedCallbackFunction,
  required FunctionStringAndMapStringDynamic onKeywordsUpdated,
  required Map<String, dynamic> listData


}) {
  // Converting list to a comma-separated string for editing
  kwsEditController.text = (currentKeywords..sort()).join(", "); 
  
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
            key: const Key("kwsGroupsDashboardEditField"),
            controller: kwsEditController,
            autofocus: true,
            decoration: const InputDecoration
            (
              labelText: keywordsTextFieldLabel, 
              labelStyle: TextStyle(color: Colors.black),
              hintText: "Please enter keywords.",
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

void _showParticipantsEditSheet({
  required BuildContext context,
  required String dashboardContext,
  required List<dynamic> currentParticipants,
  required String? listKey,
  required TextEditingController participantsTec,
  required OnParticipantListsItemSetStringUpdatedCallbackFunctionType onParticipantsUpdatedCallbackFunction,
  required FunctionStringAndMapStringDynamic onParticipantsUpdated,
  required Map<String, dynamic> listData,
}) {
  participantsTec.text = currentParticipants.join(", ");

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    isScrollControlled: true,
    builder: (context) {
      String? errorText; 
      // StatefulBuilder gives a local setState scoped to this sheet
      return StatefulBuilder(
        builder: (context, setState) {          

          Future<void> onConfirm() async {
            final participants = participantsTec.text.trim();

            if (participants.isEmpty) {
              setState(() {
                errorText = emptyParticipantsListError;
              });
              return;
            }

            setState(() {
              // Clearing error on valid input
              errorText = null; 
            });

            await onParticipantsUpdated(listKey: listKey, listData: listData);
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key("participantsGroupsDashboardEditField"),
                  controller: participantsTec,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: participantsTextFieldLabel,
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: "Please enter the participants.",
                    errorText: errorText,
                  ),
                  onSubmitted: (_) async => await onConfirm(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async => await onConfirm(),
                  child: const Text(saveButtonLabel, style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showListNameEditSheet({
  required BuildContext context,
  required String dashboardContext,
  required String currentListName,
  required String? listKey,
  required TextEditingController listNameEditTec,
  required OnParticipantListsItemSetStringUpdatedCallbackFunctionType onParticipantsUpdatedCallbackFunction,
  required FunctionStringAndMapStringDynamic onListNameUpdated,
  required Map<String, dynamic> listData,
}) {
  listNameEditTec.text = currentListName;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    isScrollControlled: true,
    builder: (context) {
      String? errorText; 
      // StatefulBuilder gives a local setState scoped to this sheet
      return StatefulBuilder(
        builder: (context, setState) {          

          Future<void> onConfirm() async {
            final updatedListName = listNameEditTec.text.trim();

            if (updatedListName.isEmpty) {
              setState(() {
                errorText = emptyLabelEditError;
              });
              return;
            }

            setState(() {
              // Clearing error on valid input
              errorText = null; 
            });

            // Updating the list label
            listData[itemTextKey] = updatedListName;

            await onListNameUpdated(listKey: listKey, listData: listData);
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key("listLabelGroupsDashboardEditField"),
                  controller: listNameEditTec,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: participantsTextFieldLabel,
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: "Please enter the new list name.",
                    errorText: errorText,
                  ),
                  onSubmitted: (_) async => await onConfirm(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async => await onConfirm(),
                  child: const Text(saveButtonLabel, style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}