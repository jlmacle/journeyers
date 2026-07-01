import 'dart:io';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dashboard/session_sorting_utils.dart';
import 'package:journeyers/utils/generic/date/date_formats_utils.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_helper_functions.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/1_dashboard_title.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2_dashboard_filtering_and_sorting_feature.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/2c_dashboard_filtering_by_keywords.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/3_dashboard_deletion_by_bulk.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/4_dashboard_sessions_list_item.dart';


/// {@category Utility widgets}
/// {@category Dashboard}
/// A widget displaying a dashboard of session data, with assumption concerning the session data structure:
/// \[{"title":"aTitle","keywords":\[kw,kw2\],"date":"March 20, 2026 4:51 PM","filePath":"path/a.ext"},
/// {"title":"aTitle2","keywords":\[kw,kw3\],"date":"March 20, 2026 4:36 PM","filePath":"path/a2.ext"}\].
/// For the context analyses, the extension is "CSV". 
/// For the group problem-solvings, the extension is "TXT".
class DashboardPage extends StatefulWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;

  /// A callback function called if all session data is deleted from the dashboard, and used to pass from the dashboard to a new session process.  
  final VoidCallback onAllSessionFilesDeletedContextPageCallbackFunction;

  /// A callback function called when session data is edited.
  final OnEditSessionDataCallbackFunctionType onEditSessionDataCallbackFunction;

  /// A global key linked to the DashboardFilteringByKeywords widget.
  final GlobalKey<DashboardFilteringByKeywordsState>? dashboardFilteringByKeywordsKey;

  const DashboardPage
  ({
    super.key,
    required this.dashboardContext,
    required this.onAllSessionFilesDeletedContextPageCallbackFunction,
    required this.onEditSessionDataCallbackFunction,
    required this.dashboardFilteringByKeywordsKey
  });

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> 
{
  // ─── GLOBAL KEYS ───────────────────────────────────────
  final GlobalKey<DashboardFilteringByKeywordsState> _dashboardFilteringByKeywordsKey = .new();

  // Method used to refresh the dashboard page
  void _refreshDashboard()
  {
    setState(() {});
  }

  // ─── PREFERENCES and DATA RETRIEVAL related data and methods ───────────────────────────────────────
  // Starting by loading data
  bool _isDataLoading = true;

  // All the sessions available
  List<dynamic>? _sessionsMetadataAll;

  // _sessionsMetadataFiltered is what is used by build()
  List<dynamic>? _sessionsMetadataFiltered;

  // Method used to retrieve the session data, to get the list of used keywords, 
  // and the list of all sessions available
  Future<void> _getStoredSessionData() async 
  {
    // Retrieving data from file
    final retrievedSessionMetadata = 
      await du.retrieveAllDashboardMetadata
                (typeOfDashboardContext: widget.dashboardContext);
    
    // Getting the used keywords from the retrieved data
    _keywordsAll = await _keywordsAllGet(retrievedSessionMetadata);

    // When getting the stored data, _sessionsMetadataAll = retrievedSessionMetadata
    _sessionsMetadataAll = retrievedSessionMetadata;

    // _sessionsMetadataFiltered is used in build, and is populated with the content of retrievedSessionMetadata
    _sessionsMetadataFiltered!.clear();
    _sessionsMetadataFiltered!.addAll(retrievedSessionMetadata);

    if (sessionDataDebug) pu.printd("Session Data: DashboardPage: initState: _sessionsMetadataAll: : $_sessionsMetadataAll");

    // Data is not sorted by date by default, and needs sorting
    await sortSessionByDateAddJm(list: _sessionsMetadataFiltered!, dateFormat: DateFormatsUtils.dateFormatMMMMddyyyy, byAscendingDate: false);
        
    // Re-build to display the sessions
    setState(() {
      _isDataLoading = false;
    });
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    pu.printdLine();
    pu.printd("DashboardPage: didUpdateWidget");
  }

  // Previous session data retrieval; _sessionsMetadataAll and _sessionsMetadataFiltered are initialized
  @override
  void initState() 
  {
    super.initState();
    
    pu.printdLine();
    pu.printd("DashboardPage");

    _sessionsMetadataAll = [];
    _sessionsMetadataFiltered = [];
    // Circular indicator until data is retrieved
    _getStoredSessionData();
  }

  // ─── SORTING AND FILTERING related data and methods ───────────────────────────────────────
  // All the keywords available
  List<String> _keywordsAll = [];

  // All the selected keywords
  final List<String> _keywordsSelected = [];

  // Method used to get the list of keywords present in a session data
  Future<List<String>> _keywordsAllGet(List<dynamic> listOfSessionData) async 
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
  void _keywordsRefreshAfterSessionDeletion() 
  {
    _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();
  }
    
  // Method used after keywords update
  Future<void> _keywordsUpdate({required Set<String> updatedKeywords, required String? filePath}) async
  {
    if (sessionDataDebug) pu.printd("Session Data: updateKeywords: updatedKeywords: $updatedKeywords");
    // To accomodate widget testing
    if (filePath != null)
    {
      await _sessionKeywordsUpdate(filePath, updatedKeywords); 
              
      await du.saveAllSessionsMetadata
      (
        typeOfDashboardContext: widget.dashboardContext, 
        sessionsMetadataAll: _sessionsMetadataAll!,
      );
    }    
  }

  // ─── DELETION OF SINGLE SESSION DATA related data and methods ───────────────────────────────────────
  final List<String> _sessionsMetadataSelectedForDeletion = [];  

  // Method used to delete a single session data from the session list action icons
  Future<void> _sessionSelectedDelete(String filePath) async
  {
    // Removing the stored file
    await fu.deleteFile(filePath);

    // Removing the related stored dashboard data
    await du.deleteSpecificSessionMetadata(typeOfDashboardContext: widget.dashboardContext, filePathRelatedToDataToDelete: filePath);
    
    // Updating the _sessionsMetadataAll list
    _sessionsMetadataAll?.removeWhere((session) => session[DashboardUtils.keyFilePath] == filePath); 

    // Updating the _sessionsMetadataFiltered list used by the UI
    _sessionsMetadataFiltered?.removeWhere((session) => session[DashboardUtils.keyFilePath] == filePath);     
              
    // Updating the sessions selected for bulk deletion
    _sessionsMetadataSelectedForDeletion.removeWhere
    (
      (session) => _sessionsMetadataSelectedForDeletion.contains(filePath)
    );

    // Updating the keywords list
    _dashboardFilteringByKeywordsKey.currentState?.keywordsRefreshAfterSessionDeletion();

    // Re-applying the relevant filters
    await _dashboardFilteringByKeywordsKey.currentState?.keywordsApplyFiltering();
    
    if (!mounted) return;
    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected session deleted.")));

    // Refreshing and resetWasSessionDataSavedStatus if no session data left
    if (_sessionsMetadataAll != null  && _sessionsMetadataAll!.isEmpty) 
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

    // Updating the file names list: _deleteSelectedSession
    if(Platform.isAndroid || Platform.isIOS)
    {
      await du.getStoredFileNamesOnMobile();
      if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
    }
    
     }

  // ─── EDITION OF SESSION DATA ───────────────────────────────────────
  final TextEditingController _titleTfec = .new();

  @override
  void dispose() {
    _titleTfec.dispose();
    super.dispose();
  }

  // Method used to update the session title
  Future<void> _sessionTitleUpdate(String filePath, String newTitle) async 
  {
    String? previousTitle;

    // Updating the local UI state
    setState(() {
      // Finding the session in the session data, and updating its title
      final sessionIndex = _sessionsMetadataAll?.indexWhere(
        (s) => s[DashboardUtils.keyFilePath] == filePath
      );

      if (sessionIndex != null && sessionIndex != -1) {
        previousTitle = _sessionsMetadataAll![sessionIndex][DashboardUtils.keyTitle];
        _sessionsMetadataAll![sessionIndex][DashboardUtils.keyTitle] = newTitle;
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
  Future<void> _sessionKeywordsUpdate(String filePath, Set<String> newKeywords) async 
  {
    Set<dynamic>? previousKeywords;

    final sessionIndex = _sessionsMetadataAll?.indexWhere(
        (s) => s[DashboardUtils.keyFilePath] == filePath
      );

    if (sessionIndex != null && sessionIndex != -1) {
      previousKeywords = Set.from(_sessionsMetadataAll![sessionIndex][DashboardUtils.keyKeywords]);
      // Updating the list with the new keywords
      _sessionsMetadataAll![sessionIndex][DashboardUtils.keyKeywords] = 
      newKeywords.toList()..sort
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

    _keywordsRefreshAfterSessionDeletion();
     // Updates the keywords list
    
    if ( ! previousKeywords!.toList().equals(newKeywords.toList()) )
    {
      setState((){ }); 
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Keywords updated successfully"))
      );
    }
    
  }

  // ─── METHODS USED TO REFRESH VIEWS ───────────────────────────────────────
  // Re-building of the widget
  void _updateState()
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
                  child: DashboardTitle(title: dashboardTitle)
                ),

                // DASHBOARD FILTERING FEATURES
                SliverToBoxAdapter 
                (
                  child: DashboardSortingAndFilteringFeature
                  (
                    dashboardContext: widget.dashboardContext, 
                    sessionsMetadataAll: _sessionsMetadataAll, sessionsMetadataFiltered: _sessionsMetadataFiltered,
                    keywordsAll: _keywordsAll, keywordsSelected: _keywordsSelected,
                    parentCallbackFunctionToRefreshTheSessionsList: _updateState,
                    dashboardFilteringByKeywordsKey: _dashboardFilteringByKeywordsKey
                  ),
                ),

                // BULK DELETION
                SliverToBoxAdapter(
                  child: DashboardDeletionByBulk
                  (
                    dashboardContext: widget.dashboardContext,
                    sessionsMetadataAll: _sessionsMetadataAll,
                    sessionsMetadataFiltered: _sessionsMetadataFiltered,
                    areSessionsForDeletion: _sessionsMetadataSelectedForDeletion.isNotEmpty,
                    sessionsMetadataSelectedForDeletion: _sessionsMetadataSelectedForDeletion,
                    dashboardCallbackFunctionToRefreshTheSessionsList: _refreshDashboard                    
                  )
                ),

                // Divider
                const SliverToBoxAdapter
                (
                  child: Divider()                       
                ), 
                
                // Session List
                SliverPadding
                (
                  padding: const EdgeInsets.only(bottom: 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = _sessionsMetadataFiltered![index];
                        final String filePath = session[DashboardUtils.keyFilePath];
                        
                        return SessionsListItem(
                          sessionMetadata: session,
                          sessionDataIndex: index,
                          dashboardContext: widget.dashboardContext,
                          isChecked: _sessionsMetadataSelectedForDeletion.contains(filePath),
                          onCheckboxChangedCallbackFunction: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _sessionsMetadataSelectedForDeletion.add(filePath);
                              } else {
                                _sessionsMetadataSelectedForDeletion.remove(filePath);
                              }
                            });
                          },
                          onEditTitleCallbackFunction: () => _titleShowEditSheet(
                            session[DashboardUtils.keyTitle],
                            filePath,
                          ),
                          onEditPressedCallbackFunction: 
                          () 
                          {
                            if (widget.dashboardContext == DashboardUtils.caContext)
                            {
                              editCASessionData(filePath, widget.onEditSessionDataCallbackFunction);
                            }
                            else if (widget.dashboardContext == DashboardUtils.gpsContext)
                            {
                              editGPSSessionData(filePath, widget.onEditSessionDataCallbackFunction);
                            }
                            else 
                            {
                              throw Exception("Unknown context: ${widget.dashboardContext}");
                            }

                           },
                          onEditSessionDataCallbackFunction: 
                          ({required bool isSessionDataBeingEdited, required DTOCAForm dtoCAFormWhenEdition, required String fileNameWithoutExtensionWhenEdition, required String titleWhenEdition, required keywordsWhenEdition}) 
                          { 
                            if (widget.dashboardContext == DashboardUtils.caContext)
                            {
                              widget.onEditSessionDataCallbackFunction(dtoCAFormWhenEdition: dtoCAFormWhenEdition, fileNameWithoutExtensionWhenEdition: fileNameWithoutExtensionWhenEdition, titleWhenEdition: titleWhenEdition, keywordsWhenEdition: keywordsWhenEdition, isSessionDataBeingEdited: isSessionDataBeingEdited);
                            }
                            else if (widget.dashboardContext == DashboardUtils.gpsContext)
                            {
                              editGPSSessionData(filePath, widget.onEditSessionDataCallbackFunction);
                            }
                            
                          },
                          onKeywordsUpdatedCallbackFunction: _keywordsUpdate,
                          onDeleteCallbackFunction: () async => await _sessionSelectedDelete(filePath),
                        );
                      },
                      childCount: _sessionsMetadataFiltered?.length ?? 0,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  
  void _titleShowEditSheet(String title, String filePath) 
  {
    _titleTfec.text = title; // Syncing current title to the field
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
              controller: _titleTfec,
              autofocus: true,
              decoration: const InputDecoration
              (
                labelText: 'Edit Title', 
                labelStyle: TextStyle(color: Colors.black)
              ),
              // Duplicated code to clean
              onSubmitted: (_) async 
              {
                // New title from the controller
                final String newTitle = _titleTfec.text;

                // Performing async work outside of setState
                // Updating session data
                await _sessionTitleUpdate(filePath, newTitle); 
                
                // Storing the updated session data
                await du.saveAllSessionsMetadata
                (
                  typeOfDashboardContext: widget.dashboardContext, 
                  sessionsMetadataAll: _sessionsMetadataAll!,
                );

                if (!context.mounted) return;
                // Closing the modal sheet
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton
            (
              onPressed: () async 
              {
                // New title from the controller
                final String newTitle = _titleTfec.text;

                // Performing async work outside of setState
                // Updating session data
                await _sessionTitleUpdate(filePath, newTitle); 
                
                // Storing the updated session data
                await du.saveAllSessionsMetadata
                (
                  typeOfDashboardContext: widget.dashboardContext, 
                  sessionsMetadataAll: _sessionsMetadataAll!,
                );

                if (!context.mounted) return;
                // Closing the modal sheet
                Navigator.pop(context);
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



}