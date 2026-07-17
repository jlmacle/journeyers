
import "package:flutter/material.dart";


import "package:journeyers/debug_constants.dart";
import "package:journeyers/utils/generic/dev/type_defs.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/participants_dashboard_const_strings.dart";
import "package:journeyers/widgets/utility/lists/database/text_lists_storage.dart";
import "package:journeyers/widgets/utility/lists/database/text_lists_storage_externalized_strings.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/new_participants_list/new_participants_list.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/new_participants_list/new_participants_list_externalized_strings.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/1_participants_dashboard_title.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/2_participants_dashboard_filtering_and_sorting_feature.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/2c_participants_dashboard_filtering_by_keywords.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/3_participants_dashboard_deletion_by_bulk.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/4_participants_lists_item.dart";



class ParticipantsDashboard extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// A callback function called if all session data is deleted from the dashboard, and used to pass from the dashboard to a new session process.  
  final VoidCallback onAllSessionFilesDeletedContextPageCallbackFunction;

  /// A callback function called when session data is retrieved before edition.
  final OnRetrievedSessionDataBeforeEditionCallbackFunctionType onRetrievedSessionDataBeforeEditionCallbackFunction;

  /// A callback function called when the participants list is loaded.
  final ValueChanged<List<String>> onParticipantsLoadedCallbackFunction;

  /// A global key linked to the DashboardFilteringByKeywords widget.
  final GlobalKey<ParticipantsDashboardFilteringByKeywordsState>? dashboardFilteringByKeywordsKey;

  const ParticipantsDashboard
  ({
    super.key,
    required this.dashboardContext,
    required this.onAllSessionFilesDeletedContextPageCallbackFunction,
    required this.onRetrievedSessionDataBeforeEditionCallbackFunction,
    required this.onParticipantsLoadedCallbackFunction,
    required this.dashboardFilteringByKeywordsKey
  });

  @override
  State<ParticipantsDashboard> createState() => ParticipantsDashboardState();
}

class ParticipantsDashboardState extends State<ParticipantsDashboard> 
{
  // The DB
  final _listsDB = ListsDB();

  // ─── GLOBAL KEYS ───────────────────────────────────────
  final GlobalKey<ParticipantsDashboardFilteringByKeywordsState> _dashboardFilteringByKeywordsKey = .new();

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
  List<dynamic> _listsDataAll = [];

  // _filteredLists is what is used by build()
  List<dynamic> _listsDataFiltered = [];

  // Method used to retrieve the session data, to get the list of used keywords, 
  // and the list of all sessions available
  Future<void> _getStoredListsData() async 
  {
    if (listDebug) pu.printd("List debug: ParticipantsDashboard: getStoredListsData");
    // Retrieving data 
    _listData = await _listsDB.loadDataStructure();
    if (listDebug) pu.printd("List debug: ParticipantsDashboard: _listData: _listData");
    // Getting the list labels
    final labels = await _listsDB.getSortedLabels(dataStructure: _listData);
    if (listDebug) pu.printd("List debug: ParticipantsDashboard: getStoredListsData: labels: $labels");

    // Building _allListsData
    // Reverse sorting to have the most recent label first
    for (var label in labels.reversed)
    {
      var listData = _listsDB.loadListDataByListLabelSync(label: label, dataStructure: _listData);
      _listsDataAll.add(listData);
    }

    if (listDebug) pu.printd("List debug: Participants Lists: Lists display: getStoredListsData: _allListsData: $_listsDataAll");
    
    // Getting the used keywords from the retrieved data
    _keywordsAll = await _keywordsGetAll(_listsDataAll);


    // _filteredLists is used in build
    _listsDataFiltered.clear();
    _listsDataFiltered.addAll(_listsDataAll);

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
         
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("ParticipantsDashboard");

    _listsDataAll = [];
    _listsDataFiltered = [];
    // Circular indicator until data is retrieved
    _getStoredListsData();
  }

  // ─── SORTING AND FILTERING related data and methods ───────────────────────────────────────
  // All the keywords available
  List<String> _keywordsAll = [];

  // All the selected keywords
  final List<String> _keywordsSelected = [];

  // Method used to get the list of keywords present in a session data
  Future<List<String>> _keywordsGetAll(List<dynamic> listOfListData) async 
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
  Future<void> _keywordsRefreshAfterSessionDeletion() async
  {
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();
  }

  // Method used to update the list keywords in the database
  Future<void> _updateKeywordsInDB(String listKey, Set<String> updatedKeywords, Map<String, dynamic> listData) async 
  {
    // Updating listData with the new keywords
    listData[itemKeywordsKey] = updatedKeywords.toList();

    // Updating the storage
    await _listsDB.updateListData(listKey, listData);

    // TODO: To clean/name modification
    await _keywordsRefreshAfterSessionDeletion();

    // Updating the local UI state
    setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Keywords updated successfully"))
        );
    });
  }
    
  // Method used after keywords update
  Future<void> _updateListKeywords({required Set<String> updatedItems, required String? listKey, required Map<String, dynamic> listData}) async
  {
    if (listDebug) pu.printd("List debug: updateKeywords: updatedKeywords: $updatedItems");
    // To accomodate widget testing
    if (listKey != null)
    {
      // Updating the DB
      await _updateKeywordsInDB(listKey, updatedItems, listData);            
    }    
  }

  // Method used to update the list participants
  Future<void> _updateParticipantsInDB(String listKey, Set<String> updatedParticipants, Map<String, dynamic> listData) async 
  {

    // Updating listData with the new participants
    listData[subItemsDataListKey] = await _listsDB.updateParticipants(updatedParticipants, listData);    

    // Updating the storage
    await _listsDB.updateListData(listKey, listData);

    // TODO: To clean/name modification
    await _keywordsRefreshAfterSessionDeletion();

    // Updating the local UI state
    setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Keywords updated successfully"))
        );
    });
  }

  // TODO: To clean
  // Method used to update the list participants
  Future<void> _updateListNameInDB(String listKey, Map<String, dynamic> listData) async 
  {
    // Updating the storage
    await _listsDB.updateListData(listKey, listData);

    // TODO: To clean/name modification
    await _keywordsRefreshAfterSessionDeletion();

    // Updating the local UI state
    setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("List name updated successfully"))
        );
    });
  }

  // Method used to update the list name
  Future<void> _updateListName
  ({
    required String? listKey, 
    required Map<String, dynamic> listData
  }) async
  {
    if (listDebug) pu.printd("List debug: ParticipantsDashboard: _updateListName");
    // To accomodate widget testing
    if (listKey != null)
    {
      // Updating the DB
      await _updateListNameInDB(listKey, listData);            
    }    
  }

  // Method used after participants update
  Future<void> _updateParticipants({required Set<String> updatedItems, required String? listKey, required Map<String, dynamic> listData}) async
  {
    if (listDebug) pu.printd("List debug: Lists display: updateParticipants: updatedItems: $updatedItems");
    // To accomodate widget testing
    if (listKey != null)
    {
      // Updating the DB
      await _updateParticipantsInDB(listKey, updatedItems, listData);            
    }    
  }
  
  // ─── DELETION OF SINGLE LIST related data and methods ───────────────────────────────────────
  final List<String> _listsSelectedForDeletionKeys = [];  

  // Method used to delete a single session data from the session list action icons
  Future<void> _selectedSessionDelete(String listKey) async
  {
    // Updating the DB
    await _listsDB.removeListData([listKey]);

    // Updating the _allListsData list
    _listsDataAll.removeWhere((listData) => listData[itemKey] == listKey); 

    // Updating the _filteredListsData list used by the UI
    _listsDataFiltered.removeWhere((listData) => listData[itemKey] == listKey);     
              
    // Updating the keys of the lists selected for bulk deletion
    _listsSelectedForDeletionKeys.removeWhere
    (
      (_) => _listsSelectedForDeletionKeys.contains(listKey)
    );

    // Updating the keywords list
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();

    // Re-applying the relevant filters
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsApplyFiltering();
    
    if (!mounted) return;
    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected list deleted.")));

    // Refreshing and resetWasSessionDataSavedStatus if no session data left
    if (_listsDataAll.isEmpty) 
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
  final TextEditingController _titleTfec = .new();

  @override
  void dispose() {
    _titleTfec.dispose();
    super.dispose();
  }

  // ─── METHODS USED TO REFRESH VIEWS ───────────────────────────────────────
  // Re-building of the widget
  void _updateState()
  {
    setState(() {});
  }

@override
  Widget build(BuildContext context) {

    if (listDebug) pu.printd("List debug: ParticipantsDashboard: build: _isDataLoading: $_isDataLoading"); 
    if (listDebug) pu.printd("List debug: ParticipantsDashboard: build: _listsDataFiltered: $_listsDataFiltered"); 

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
              // Using a CustomScrollView to coordinate the fade effect
              slivers: [
                // Static heading (Scrolls away normally)
                // TODO: the sliver code to clean eventually
    
                // DASHBOARD TITLE
                const SliverToBoxAdapter(
                  child: ParticipantsDashboardTitle(title: listsDashboardTitle)
                ),
    
                // DASHBOARD FILTERING FEATURES
                SliverToBoxAdapter 
                (
                  child: ParticipantsDashboardSortingAndFilteringFeature
                  (
                    dashboardContext: widget.dashboardContext, 
                    listsAll: _listsDataAll, listsFiltered: _listsDataFiltered,
                    keywordsAll: _keywordsAll, keywordsSelected: _keywordsSelected,
                    parentCallbackFunctionToRefreshTheSessionsList: _updateState,
                    dashboardFilteringByKeywordsKey: _dashboardFilteringByKeywordsKey
                  ),
                ),
    
                // BULK DELETION
                SliverToBoxAdapter(
                  child: ParticipantsDashboardDeletionByBulk
                  (
                    dashboardContext: widget.dashboardContext,
                    listsAll: _listsDataAll,
                    listsFiltered: _listsDataFiltered,
                    areListsForDeletion: _listsSelectedForDeletionKeys.isNotEmpty,
                    listsSelectedForDeletionKeys: _listsSelectedForDeletionKeys,
                    dashboardCallbackFunctionToRefreshTheSessionsList: _refreshDashboard                    
                  )
                ),
    
                // Divider
                const SliverToBoxAdapter
                (
                  child: Divider()                       
                ), 
                
                if (_listsDataFiltered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => NewParticipantsList
                                              (
                                                labelHintText: listLabelHintText,
                                                placeholderList: listPlaceholder,
                                                placeholderInvitationToEnterText: invitationToEnterTextPlaceholder,
                                                themeData: Theme.of(context),
                                                onParticipantsLoadedCallbackFunction: widget.onParticipantsLoadedCallbackFunction,
                                              ),
                          ),
                        ),
                        label: const Text(newListButtonLabel, textAlign: TextAlign.center),
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
                        final listData = _listsDataFiltered[index];
    
                        return ParticipantsListsItem(
                          listMetadata: listData,
                          listIndex: index,
                          dashboardContext: widget.dashboardContext,
                          isChecked: _listsSelectedForDeletionKeys.contains(listData[itemKey]),
                          onCheckboxChangedCallbackFunction: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _listsSelectedForDeletionKeys.add(listData[itemKey]);
                              } else {
                                _listsSelectedForDeletionKeys.remove(listData[itemKey]);
                              }
                            });
                          },
                          onRetrievedSessionDataBeforeEditionCallbackFunction: 
                          ({
                            required String dashboardContext,
                            required bool isSessionDataBeingEdited, 
                            required String titleWhenEdition, 
                            required Set<String> keywordsWhenEdition,
                            required Object dtoWhenEdition, 
                            required String fileNameWithoutExtensionWhenEdition,
                            required String filePathWhenEdition
                          }) {},
                          onKeywordsUpdatedCallbackFunction: _updateListKeywords,
                          onListNameUpdatedCallbackFunction: _updateListName,
                          onParticipantsUpdatedCallbackFunction: _updateParticipants,
                          onDeleteCallbackFunction: () async => await _selectedSessionDelete(listData[itemKey]),
                          onParticipantsLoadedCallbackFunction: widget.onParticipantsLoadedCallbackFunction,
                        );
                      },
                      childCount: _listsDataFiltered.length,
                    ),
                  ),
                ),
              ],
            ),
          )
    );
  
  }

}