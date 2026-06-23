
import 'package:flutter/material.dart';


import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/lists/list_dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/lists/models/text_lists_storage.dart';
import 'package:journeyers/widgets/utility/lists/models/text_lists_storage_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list.dart';
import 'package:journeyers/widgets/utility/lists/new_text_list_externalized_strings.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/1_list_dashboard_title.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/2_list_dashboard_filtering_and_sorting_feature.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/2c_list_dashboard_filtering_by_keywords.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/3_list_dashboard_deletion_by_bulk.dart';
import 'package:journeyers/widgets/utility/lists/tmp_utility_widgets/4_list_of_lists_item.dart';



class ListDashboard extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// A callback function called if all session data is deleted from the dashboard, and used to pass from the dashboard to a new session process.  
  final VoidCallback onAllSessionFilesDeletedContextPageCallbackFunction;

  /// A callback function called when session data is edited.
  final OnEditSessionDataCallbackFunctionType onEditSessionDataCallbackFunction;

  /// A callback function called when the participants list is loaded.
  final ValueChanged<List<String>> onParticipantsLoadedCallbackFunction;

  /// A global key linked to the DashboardFilteringByKeywords widget.
  final GlobalKey<ListDashboardFilteringByKeywordsState>? dashboardFilteringByKeywordsKey;

  const ListDashboard
  ({
    super.key,
    required this.dashboardContext,
    required this.onAllSessionFilesDeletedContextPageCallbackFunction,
    required this.onEditSessionDataCallbackFunction,
    required this.onParticipantsLoadedCallbackFunction,
    required this.dashboardFilteringByKeywordsKey
  });

  @override
  State<ListDashboard> createState() => ListDashboardState();
}

class ListDashboardState extends State<ListDashboard> 
{
  // The DB
  final _textListsDB = ListsDB();

  // ─── GLOBAL KEYS ───────────────────────────────────────
  final GlobalKey<ListDashboardFilteringByKeywordsState> _dashboardFilteringByKeywordsKey = .new();

  // Method used to refresh the dashboard page
  void _refreshDashboard()
  {
    setState(() {});
  }

  // ─── PREFERENCES and DATA RETRIEVAL related data and methods ───────────────────────────────────────
  // List data from the DB
  late List<dynamic> _listData;
  
  // Starting by loading data
  bool _isDataLoading = true;

  // All the sessions available
  List<dynamic> _allListsData = [];

  // _filteredLists is what is used by build()
  List<dynamic> _filteredListsData = [];

  // Method used to retrieve the session data, to get the list of used keywords, 
  // and the list of all sessions available
  Future<void> _getStoredListsData() async 
  {
    // Retrieving data 
    _listData = await _textListsDB.loadDataStructure();

    // Getting the list labels
    final labels = await _textListsDB.getSortedLabels(dataStructure: _listData);
    if (listDebug) pu.printd("List debug: Participants Lists: Lists display: getStoredListsData: labels: $labels");

    // Building _allListsData
    // Reverse sorting to have the most recent label first
    for (var label in labels.reversed)
    {
      var listData = _textListsDB.loadListDataByListLabelSync(label: label, dataStructure: this._listData);
      _allListsData.add(listData);
    }

    if (listDebug) pu.printd("List debug: Participants Lists: Lists display: getStoredListsData: _allListsData: $_allListsData");
    
    // Getting the used keywords from the retrieved data
    _keywordsAll = await _getUsedKeywords(_allListsData);


    // _filteredLists is used in build
    _filteredListsData.clear();
    _filteredListsData.addAll(_allListsData);

    // Data is not sorted by date by default, and needs sorting
    // await sortSessionByDateAddJm(list: _filteredListsData, dateFormat: DateFormatsUtils.dateFormatMMMMddyyyy, byAscendingDate: false);
    
    // Re-build to display the lists data
    setState(() {
      _isDataLoading = false;
    });
  }

  // Previous data retrieval; _allLists and _filteredLists are initialized
  @override
  void initState() 
  {
    super.initState();
    _allListsData = [];
    _filteredListsData = [];
    // Circular indicator until data is retrieved
    _getStoredListsData();
  }

  // ─── SORTING AND FILTERING related data and methods ───────────────────────────────────────
  // All the keywords available
  List<String> _keywordsAll = [];

  // All the selected keywords
  final List<String> _keywordsSelected = [];

  // Method used to get the list of keywords present in a session data
  Future<List<String>> _getUsedKeywords(List<dynamic> listOfListData) async 
  {

    Set<String> kwSet = {};
    for (var listData in listOfListData) 
    {
      List<dynamic> kws = listData[itemKeywordsKey];
      kwSet.addAll(kws.cast<String>());
    }
    return kwSet.toList();
  }

  // Method used to refresh the keywords list after deletion of session data
  void _keywordsRefreshAfterSessionDeletion() 
  {
    _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();
  }

  // Method used to update the list keywords
  Future<void> _updateListsKeywords(String listKey, Set<String> updatedKeywords, Map<String, dynamic> listData) async 
  {
    // Updating listData with the new keywords
    listData[itemKeywordsKey] = updatedKeywords.toList();

    // Updating the storage
    await _textListsDB.updateListData(listKey, listData);

    // TODO: To clean/name modification
    _keywordsRefreshAfterSessionDeletion();

    // Updating the local UI state
    setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Keywords updated successfully"))
        );
    });
  }
    
  // Method used after keywords update
  Future<void> _updateKeywords({required Set<String> updatedItems, required String? listKey, required Map<String, dynamic> listData}) async
  {
    if (listDebug) pu.printd("List debug: updateKeywords: updatedKeywords: $updatedItems");
    // To accomodate widget testing
    if (listKey != null)
    {
      // Updating the DB
      await _updateListsKeywords(listKey, updatedItems, listData);            
    }    
  }

  // Method used to update the list participants
  Future<void> _updateListParticipants(String listKey, Set<String> updatedParticipants, Map<String, dynamic> listData) async 
  {

    // Updating listData with the new participants
    listData[subItemsDataListKey] = await _textListsDB.updateParticipants(updatedParticipants, listData);    

    // Updating the storage
    await _textListsDB.updateListData(listKey, listData);

    // TODO: To clean/name modification
    _keywordsRefreshAfterSessionDeletion();

    // Updating the local UI state
    setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Keywords updated successfully"))
        );
    });
  }

  // Method used after participants update
  Future<void> _updateParticipants({required Set<String> updatedItems, required String? listKey, required Map<String, dynamic> listData}) async
  {
    if (listDebug) pu.printd("List debug: Lists display: updateParticipants: updatedItems: $updatedItems");
    // To accomodate widget testing
    if (listKey != null)
    {
      // Updating the DB
      await _updateListParticipants(listKey, updatedItems, listData);            
    }    
  }

  
  // ─── DELETION OF SINGLE LIST related data and methods ───────────────────────────────────────
  final List<String> _keysOfListsSelectedForDeletion = [];  

  // Method used to delete a single session data from the session list action icons
  Future<void> _deleteSelectedSession(String listKey) async
  {
    // Updating the DB
    await _textListsDB.removeListData([listKey]);

    // Updating the _allListsData list
    _allListsData.removeWhere((listData) => listData[itemKey] == listKey); 

    // Updating the _filteredListsData list used by the UI
    _filteredListsData.removeWhere((listData) => listData[itemKey] == listKey);     
              
    // Updating the keys of the lists selected for bulk deletion
    _keysOfListsSelectedForDeletion.removeWhere
    (
      (_) => _keysOfListsSelectedForDeletion.contains(listKey)
    );

    // Updating the keywords list
    _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();

    // Re-applying the relevant filters
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsApplyFiltering();
    
    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected list deleted.")));

    // Refreshing and resetWasSessionDataSavedStatus if no session data left
    if (_allListsData.isEmpty) 
    {
      // resetWasSessionDataSavedStatus
      await rtdu.resetWasSessionDataSavedStatus(context: widget.dashboardContext);
      // refreshing the page
      widget.onAllSessionFilesDeletedContextPageCallbackFunction();
    }
    else
    {
      // refreshing the page
      setState(() {});
    }
    
     }

  // ─── EDITION OF SESSION DATA ───────────────────────────────────────
  final TextEditingController _titleController = .new();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Method used to update the session title
  Future<void> updateListLabel(String listKey, String newLabel, Map<String, dynamic> listData) async 
  {
    // Updating listData withe new label
    listData[itemTextKey] = newLabel;

    // Updating the storage
    await _textListsDB.updateListData(listKey, listData);

    // Updating the local UI state
    setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Label updated successfully"))
        );
    });
  }

    // ─── METHODS USED TO REFRESH VIEWS ───────────────────────────────────────
  // Re-building of the widget
  void _updateState()
  {
    setState(() {});
  }

@override
  Widget build(BuildContext context) {
    return 
    Scaffold
    (
      appBar: AppBar
              (
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
      body: 
      SafeArea
      (
        child: 
      _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
            // Key used for automated testing, to scroll up the screen 
            key: const Key('list-of-lists-scrollview'),
              // Using a CustomScrollView to coordinate the fade effect
              slivers: [
                // Static heading (Scrolls away normally)
                // TODO: the sliver code to clean eventually
    
                // DASHBOARD TITLE
                const SliverToBoxAdapter(
                  child: ListDashboardTitle(title: listsDashboardTitle)
                ),
    
                // DASHBOARD FILTERING FEATURES
                SliverToBoxAdapter 
                (
                  child: ListDashboardSortingAndFilteringFeature
                  (
                    dashboardContext: widget.dashboardContext, 
                    listsAll: _allListsData, listsFiltered: _filteredListsData,
                    keywordsAll: _keywordsAll, keywordsSelected: _keywordsSelected,
                    parentCallbackFunctionToRefreshTheSessionsList: _updateState,
                    dashboardFilteringByKeywordsKey: _dashboardFilteringByKeywordsKey
                  ),
                ),
    
                // BULK DELETION
                SliverToBoxAdapter(
                  child: ListDashboardDeletionByBulk
                  (
                    dashboardContext: widget.dashboardContext,
                    listsAll: _allListsData,
                    listsFiltered: _filteredListsData,
                    areListsForDeletion: _keysOfListsSelectedForDeletion.isNotEmpty,
                    listsSelectedForDeletionKeys: _keysOfListsSelectedForDeletion,
                    dashboardCallbackFunctionToRefreshTheSessionsList: _refreshDashboard                    
                  )
                ),
    
                // Divider
                const SliverToBoxAdapter
                (
                  child: Divider()                       
                ), 
                
                if (_filteredListsData.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => NewTextList
                                              (
                                                listLabelHintText: listLabelHintText,
                                                listPlaceholder: listPlaceholder,
                                                invitationToEnterTextPlaceholder: invitationToEnterTextPlaceholder,
                                                themeData: Theme.of(context),
                                                onParticipantsLoadedCallbackFunction: widget.onParticipantsLoadedCallbackFunction,
                                              ),
                          ),
                        ),
                        label: const Text(newListButton, textAlign: TextAlign.center),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 90),
                        ),
                      ),
                    ),
                  )
                else
                // List of lists
                  SliverPadding
                  (
                  padding: const EdgeInsets.only(bottom: 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listData = _filteredListsData[index];
    
                        return ListOfListsItem(
                          listData: listData,
                          index: index,
                          dashboardContext: widget.dashboardContext,
                          isChecked: _keysOfListsSelectedForDeletion.contains(listData[itemKey]),
                          onCheckboxChangedCallbackFunction: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _keysOfListsSelectedForDeletion.add(listData[itemKey]);
                              } else {
                                _keysOfListsSelectedForDeletion.remove(listData[itemKey]);
                              }
                            });
                          },
                          onEditTitleCallbackFunction: () => _showTitleEditSheet(
                            listData[itemTextKey],
                            listData[itemKey],
                            index
                          ),
                          onEditPressedCallbackFunction: () {},
                          onEditSessionDataCallbackFunction: ({required DTOCAForm dtoWhenEdition, required String fileNameWhenEditionWithoutExtension, required String titleWhenEdition, required keywordsWhenEdition, required bool sessionDataBeingEdited}) {},
                          onKeywordsUpdatedCallbackFunction: _updateKeywords,
                          onParticipantsUpdatedCallbackFunction: _updateParticipants,
                          onDeleteCallbackFunction: () async => await _deleteSelectedSession(listData[itemKey]),
                          onParticipantsLoadedCallbackFunction: widget.onParticipantsLoadedCallbackFunction,
                        );
                      },
                      childCount: _filteredListsData.length,
                    ),
                  ),
                ),
              ],
            ),
          )
    );
  
  }

  
  void _showTitleEditSheet(String title, String listKey, int listIndex) 
  {
    _titleController.text = title; // Syncing current title to the field

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Rectangle shape
      isScrollControlled: true, // Allows sheet to push up with keyboard

      builder: (context) 
      {
        String? errorText; 
        // StatefulBuilder gives a local setState scoped to this sheet
        return StatefulBuilder(
          builder: (context, setState) {          

            Future<void> onConfirm() async {              
              final label = _titleController.text.trim();

              if (label.isEmpty) {
                setState(() {
                  errorText = emptyLabelEditError;
                });
                return;
              }

              setState(() {
                // Clearing error on valid input
                errorText = null; 
              });            
            }

          return Padding
          (
            padding: EdgeInsets.only
            (
              bottom: MediaQuery.of(context).viewInsets.bottom, // Keyboard padding
              left: 20, right: 20, top: 20,
            ),
            child: Column
            (
              mainAxisSize: MainAxisSize.min,
              children: 
              [
                TextField
                (
                  key: const ValueKey('listEditField'),
                  controller: _titleController,
                  autofocus: true,
                  decoration: InputDecoration
                  (
                    labelText: 'Edit Title', 
                    labelStyle: const TextStyle(color: Colors.black),
                    errorText: errorText,
                  ),
                  // Duplicated code to clean
                  onSubmitted: (_) async => await onConfirm(),
                ),
                const SizedBox(height: 10),
                ElevatedButton
                (
                  onPressed: () async => await onConfirm(),
                  child: const Text
                  (
                    "Save",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
        );
      },
  );
}}