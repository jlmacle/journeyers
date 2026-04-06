import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/widgets/utility/sessions_sorting_utils.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_deletion_by_bulk.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_filtering_feature.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_filtering_by_keywords.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_sorting_by_date_config.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_title.dart';


/// {@category Utility widgets}
/// A widget displaying a dashboard of session data.
/// Assumption concerning the session data structure:
/// \[{"title":"aTitle","keywords":\[kw,kw2\],"date":"March 20, 2026 5:51 AM","filePath":"C:\\Users\\username\\Documents\\a.ext"},
/// {"title":"aTitle2","keywords":\[kw,kw3\],"date":"March 20, 2026 4:36 AM","filePath":"C:\\Users\\username\\a2.ext"}\]
class SessionsDashboardPage extends StatefulWidget 
{
  /// The context for the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// The widget used for the preview.
  final Widget Function({required String pathToData})? previewWidget;

  /// A callback function called after all session files have been deleted, and used to pass from dashboard to new session process.
  final VoidCallback parentCallbackFunctionWhenAllSessionFilesAreDeleted;

  /// A global key linked to the DashboardFilteringByKeywords widget
  final GlobalKey<DashboardFilteringByKeywordsState>? dashboardFilteringByKeywordsKey;

  const SessionsDashboardPage
  ({
    super.key,
    required this.dashboardContext,
    required this.previewWidget,
    this.parentCallbackFunctionWhenAllSessionFilesAreDeleted = placeHolderVoidCallback,
    required this.dashboardFilteringByKeywordsKey
  });

  @override
  State<SessionsDashboardPage> createState() => SessionsDashboardPageState();
}

class SessionsDashboardPageState extends State<SessionsDashboardPage> 
{
  //**************** GLOBAL KEYS ****************//
  GlobalKey<DashboardFilteringByKeywordsState> dashboardFilteringByKeywordsKey = .new();

  // Method used to refresh the dashboard page
  void refreshDashboard()
  {
    setState(() {});
  }

  
  //**************** PREFERENCES and DATA RETRIEVAL related data and methods ****************/
  // Starting by loading data
  bool _isDataLoading = true;

  // All the sessions available
  List<dynamic>? _allSessions;

  // _filteredSessions is what is used by build()
  List<dynamic>? _filteredSessions;

  // Method used to retrieve the session data, to get the list of used keywords, 
  // and the list of all sessions available
  Future<void> getStoredSessionData() async 
  {
    // Retrieving data from file
    final retrievedSessionData = 
      await du.retrieveAllDashboardMetadata
                (typeOfContextData: widget.dashboardContext);
    
    // Getting the used keywords from the retrieved data
    _usedKeywords = await _getUsedKeywords(retrievedSessionData);

    // When getting the stored data, _allSessions = retrievedSessionData
    _allSessions = retrievedSessionData;

    // _filteredSessions is used in build, and is populated with the content of retrievedSessionData
    _filteredSessions!.clear();
    _filteredSessions!.addAll(retrievedSessionData);

    // Data is not sorted by date by default, and needs sorting
    await sortSessionByDateAddJm(list: _filteredSessions!, dateFormat: dateFormatForSorting, byAscendingDate: false);
    
    // Re-build to display the sessions
    setState(() {
      _isDataLoading = false;
    });
  }

  // Previous session data retrieval; _allSessions and _filteredSessions are initialized
  @override
  void initState() 
  {
    super.initState();
    _allSessions = [];
    _filteredSessions = [];
    // Circular indicator until data is retrieved
    getStoredSessionData();
  }

  //**************** SORTING AND FILTERING related data and methods ****************/

  // All the keywords available
  List<String> _usedKeywords = [];

  // All the selected keywords
  final List<String> _selectedKeywords = [];

  // Method used to get the list of keywords present in a session data
  Future<List<String>> _getUsedKeywords(List<dynamic> listOfSessionData) async 
  {
    Set<String> kwSet = {};
    for (var sessionData in listOfSessionData) 
    {
      List<dynamic> kws = sessionData[DashboardUtils.keyKeywords];
      kwSet.addAll(kws.cast<String>());
    }
    return kwSet.toList();
  }

  // Method used to refresh the keywords list after deletion of session data
  void refreshKeywordsAfterSessionDeletion() 
  {
    dashboardFilteringByKeywordsKey.currentState?.refreshKeywordsAfterSessionDeletion();
  }
    
  //**************** DELETION OF SINGLE SESSION DATA related data and methods ****************/

  List<String> _sessionsSelectedForDeletion = [];  

  // Method used to delete a single session data from the session list action icons
  Future<void> _deleteSelectedSession(String filePath) async
  {
    // Removing the stored file
    await fu.deleteCsvFile(filePath);

    // Removing the related stored dashboard data
    await du.deleteSpecificSessionMetadata(typeOfContextData: widget.dashboardContext, filePathRelatedToDataToDelete: filePath);
    
    // Updating the _allSessions list
    _allSessions?.removeWhere((session) => session[DashboardUtils.keyFilePath] == filePath); 

    // Updating the _filteredSessions list used by the UI
    _filteredSessions?.removeWhere((session) => session[DashboardUtils.keyFilePath] == filePath);     
              
    // Updating the sessions selected for bulk deletion
    _sessionsSelectedForDeletion.removeWhere
    (
      (session) => _sessionsSelectedForDeletion.contains(filePath)
    );

    // Updating the keywords list
    dashboardFilteringByKeywordsKey.currentState?.refreshKeywordsAfterSessionDeletion();

    // Re-applying the relevant filters
    await dashboardFilteringByKeywordsKey.currentState?.applyFilteringByKeywords();
    
    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected session deleted.")));

    // Refreshing and resetWasSessionDataSavedStatus if no session data left
    if (_allSessions != null  && _allSessions!.isEmpty) 
    {
      // resetWasSessionDataSavedStatus
      await upu.resetWasSessionDataSavedStatus(context: widget.dashboardContext);
      // refreshing the page
      widget.parentCallbackFunctionWhenAllSessionFilesAreDeleted();
    }
    else
    {
      // refreshing the page
      setState(() {});
    }
  }

  //**************** EDITION OF SESSION DATA ****************/
  final TextEditingController _titleController = .new();

  // Method used to update the session title
  Future<void> updateSessionTitle(String filePath, String newTitle) async 
  {
    String? previousTitle;

    // Updating the local UI state
    setState(() {
      // Finding the session in the session data, and updating its title
      final sessionIndex = _allSessions?.indexWhere(
        (s) => s[DashboardUtils.keyFilePath] == filePath
      );

      if (sessionIndex != null && sessionIndex != -1) {
        previousTitle = _allSessions![sessionIndex][DashboardUtils.keyTitle];
        _allSessions![sessionIndex][DashboardUtils.keyTitle] = newTitle;
      }
      
      // Notifying success
      if (previousTitle!.trim() != newTitle.trim())
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title updated successfully"))
        );
      }
    });
  }

  // Method used to update the session keywords
  Future<void> updateSessionKeywords(String filePath, List<String> newKeywords) async 
  {
    List<dynamic>? previousKeywords;

    final sessionIndex = _allSessions?.indexWhere(
        (s) => s[DashboardUtils.keyFilePath] == filePath
      );

    if (sessionIndex != null && sessionIndex != -1) {
      previousKeywords = _allSessions![sessionIndex][DashboardUtils.keyKeywords];
      // Updating the list with the new keywords
      _allSessions![sessionIndex][DashboardUtils.keyKeywords] = 
      newKeywords..sort
                  (
                    (a, b) 
                    {
                      // Different letters
                      int comparison = a.toLowerCase().compareTo(b.toLowerCase());  
                      // Same letter
                      if (comparison == 0) {return b.compareTo(a);}                                                
                      return comparison;
                    }
                  );
    }

    refreshKeywordsAfterSessionDeletion();
     // Updates the keywords list
    
    if ( ! previousKeywords!.equals(newKeywords) )
    {
      setState((){ }); 
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Keywords updated successfully"))
      );
    }
    
  }

  //**************** METHODS USED TO REFRESH VIEWS  ****************//
  // Re-building of the widget
  void updateState()
  {
    setState(() {});
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
            // Key used for automated testing, to scroll up the screen 
            key: const Key('sessions-list-scrollview'),
              // Using a CustomScrollView to coordinate the fade effect
              slivers: [
                // Static heading (Scrolls away normally)
                // TODO: the sliver code to clean eventually

                // DASHBOARD TITLE
                const SliverToBoxAdapter(
                  child: DashboardTitle(title: "Previous session data")
                ),

                // DASHBOARD FILTERING FEATURES
                // Fading filtering, sorting and deletion area (TODO: cleanup: deletion)
                SliverAppBar(
                  // Size of the sort, filtering, deletion area
                  expandedHeight: 200,
                  collapsedHeight: 0,
                  toolbarHeight: 0,
                  pinned: false,
                  floating: false,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin, 
                    background: DashboardFilteringFeature
                    (
                      dashboardContext: widget.dashboardContext, 
                      allSessions: _allSessions, filteredSessions: _filteredSessions,
                      usedKeywords: _usedKeywords, selectedKeywords: _selectedKeywords,
                      parentCallbackFunctionToRefreshTheSessionsList: updateState,
                      dashboardFilteringByKeywordsKey: dashboardFilteringByKeywordsKey
                    ),
                  ),
                ),

                // BULK DELETION
                SliverToBoxAdapter(
                  child: DashboardDeletionByBulk
                  (
                    dashboardContext: widget.dashboardContext,
                    allSessions: _allSessions,
                    filteredSessions: _filteredSessions,
                    areSessionsForDeletion: _sessionsSelectedForDeletion.isNotEmpty,
                    sessionsSelectedForDeletion: _sessionsSelectedForDeletion,
                    dashboardCallbackFunctionToRefreshTheSessionsList: refreshDashboard                    
                  )
                ),

                const SliverToBoxAdapter
                (
                  child: Divider()                       
                ), 
                
                // Session List
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = _filteredSessions![index];
                        String sessionTitle = session[DashboardUtils.keyTitle];
                        final String filePath = session[DashboardUtils.keyFilePath];
                        final bool isChecked =
                            _sessionsSelectedForDeletion.contains(filePath);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      key: ValueKey('checkbox-$index'),
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _sessionsSelectedForDeletion
                                                .add(filePath);
                                          } else {
                                            _sessionsSelectedForDeletion
                                                .remove(filePath);
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8,
                                            children: [
                                              GestureDetector(
                                                  onTap: () => _showTitleEditSheet(
                                                      session[DashboardUtils
                                                          .keyTitle],
                                                      session[DashboardUtils
                                                          .keyFilePath]),
                                                  child: 
                                                  Text(
                                                    key: ValueKey('session-title-$index'),
                                                    (widget.dashboardContext == DashboardUtils.groupProblemSolvingsContext) ? "$sessionTitle (gps)" : sessionTitle,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  )),
                                              Text(
                                                key: ValueKey(
                                                    'session-date-$index'),
                                                "(${session[DashboardUtils.keyDate]})",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          GestureDetector(
                                            onTap: () => _showKeywordsEditSheet(
                                                session[DashboardUtils
                                                    .keyKeywords],
                                                session[DashboardUtils
                                                    .keyFilePath]),
                                            child: Text(
                                              key: ValueKey(
                                                  'session-keywords-$index'),
                                              "Keywords: ${(List.from(session[DashboardUtils.keyKeywords])..sort((a, b) {
                                                  int comparison = a
                                                      .toLowerCase()
                                                      .compareTo(
                                                          b.toLowerCase());
                                                  if (comparison == 0) {
                                                    return b.compareTo(a);
                                                  }
                                                  return comparison;
                                                })).join(', ')}",
                                              style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      spacing: 4,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.find_in_page_rounded),
                                          onPressed: () {
                                            _showPreviewOverlay(
                                                context, session, filePath);
                                          },
                                          tooltip: "Preview",
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_document),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Edit not yet implemented.')));
                                          },
                                          tooltip: "Edit Document",
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.style_rounded),
                                          onPressed: () =>
                                              _showKeywordsEditSheet(
                                                  session[DashboardUtils
                                                      .keyKeywords],
                                                  filePath),
                                          tooltip: "Edit Keywords",
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      spacing: 4,
                                      children: [                                        
                                        IconButton(
                                          key: ValueKey(
                                              'session-delete-$index'),
                                          icon:
                                              const Icon(Icons.delete_rounded),
                                          onPressed: () async =>
                                              await _deleteSelectedSession(
                                                  filePath),
                                          tooltip: "Delete",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _filteredSessions?.length ?? 0,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  
  void _showTitleEditSheet(String title, String filePath) 
  {
    _titleController.text = title; // Syncing current title to the field
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Rectangle shape
      isScrollControlled: true, // Allows sheet to push up with keyboard
      builder: (context) => Padding
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
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration
              (
                labelText: 'Edit Title', 
                labelStyle: TextStyle(color: Colors.black)
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton
            (
              onPressed: () async 
              {
                // New title from the controller
                final String newTitle = _titleController.text;

                // Performing async work outside of setState
                // Updating session data
                await updateSessionTitle(filePath, newTitle); 
                
                // Storing the updated session data
                await du.saveAllSessionsMetadata
                (
                  typeOfContextData: widget.dashboardContext, 
                  allSessionsMetadata: _allSessions!,
                );

                // Closing the modal sheet
                if (mounted) Navigator.pop(context);
              },
              child: const Text
              (
                "Save",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showKeywordsEditSheet(List<dynamic> currentKeywords, String filePath) 
  {
  // Converting list to a comma-separated string for editing
  _titleController.text = currentKeywords.join(', '); 
  
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
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration
            (
              labelText: 'Keywords Edition (please separate with commas)', 
              labelStyle: TextStyle(color: Colors.black),
              hintText: 'Please enter your keywords.',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              // Splitting string into list, trimming whitespaces, and removing empty entries
              final List<String> newKeywords = _titleController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              // Updating keywords
              await updateSessionKeywords(filePath, newKeywords); 
              
              await du.saveAllSessionsMetadata
              (
                typeOfContextData: widget.dashboardContext, 
                allSessionsMetadata: _allSessions!,
              );

              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}


// Method used to display an overlay with a session data preview. 
void _showPreviewOverlay(BuildContext context, Map<String,dynamic> session, String filePath) {
  String title = session[DashboardUtils.keyTitle];
  
  showGeneralDialog(
    context: context,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Scaffold(
        appBar:AppBar
        (
          centerTitle: true, 
          title: 
          Text
          (
            textAlign: TextAlign.center, maxLines:20, overflow: TextOverflow.visible, 
            softWrap:true, title, style: previewTitleStyle
          ),
          // Left side: Edit Button
          leadingWidth: 100,
          leading: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                color: appBarWhite,
                onPressed: () {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit not yet implemented.')));},
                tooltip: "Edit session",
              ),
              IconButton(
                icon: const Icon(Icons.share),
                color: appBarWhite,
                onPressed: () {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share not yet implemented.')));},
                tooltip: "Share session",
              ),
            ],
          ),
          
          // Right side: Close Button
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              color: appBarWhite,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: "Close preview",
            ),
          ],
        ),
        body: SafeArea(
          // SingleChildScrollView ensures the content is scrollable 
          // regardless of the widget's internal structure
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: widget.previewWidget!(
                pathToData: filePath,
              ),
            ),
          ),
        ),
      );
    },
  );
}
}