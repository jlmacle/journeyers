import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/dev/placeholder_functions.dart';
import 'package:journeyers/core/utils/files/files_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_preview_widget.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';


//**************** UTILITY CLASSES ****************/
final DashboardUtils _du = DashboardUtils();
final FileUtils _fu = FileUtils();
final UserPreferencesUtils _upu = UserPreferencesUtils();

/// {@category Pages}
/// {@category Context analysis}
/// The page displaying a dashboard of the past context analyses.
class ContextAnalysesDashboardPage extends StatefulWidget 
{
  /// A callback function called after all session files have been deleted, and used to pass from dashboard to context analysis form.
  final VoidCallback parentCallbackFunctionToRefreshTheContextAnalysisPage;

  const ContextAnalysesDashboardPage
  ({
    super.key,
    this.parentCallbackFunctionToRefreshTheContextAnalysisPage = placeHolderVoidCallback,
  });

  @override
  State<ContextAnalysesDashboardPage> createState() => _ContextAnalysesDashboardPageState();
}

class _ContextAnalysesDashboardPageState extends State<ContextAnalysesDashboardPage> 
{

  //**************** PREFERENCES related data and methods ****************/
  bool _isDataLoading = true;

  // Method used to retrieve the session data, to get the list of used keywords, 
  // and the list of all sessions available
  Future<void> _sessionDataRetrieval() async 
  {
    final data = await _du.retrieveAllDashboardSessionData
      (typeOfContextData: DashboardUtils.contextAnalysesContext);
      
    _usedKeywords = await _getUsedKeywords(data);
    _allSessions = data;
    await _sortSessionsByDate();
    setState(() {
      _isDataLoading = false;
    });
  }

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

  //**************** SORTING AND FILTERING related data and methods ****************/
  bool _isAscendingTitle = true; 
  bool _isAscendingDate = false; 

  List<dynamic>? _allSessions;
  List<dynamic>? _filteredSessions;

  List<String>? _usedKeywords;
  final List<String> _selectedKeywords = [];

  // Method used to sort session data by date
  Future<void> _sortSessionsByDate() async
  {
    _allSessions?.sort((a, b) 
    {
      DateTime dateA = DateFormat('MMMM dd, yyyy').add_jm().parse(a[DashboardUtils.keyDate]);
      DateTime dateB = DateFormat('MMMM dd, yyyy').add_jm().parse(b[DashboardUtils.keyDate]);
      return _isAscendingDate ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    await _applyFilters();
  }
 
  // Method used to sort session data by title 
  Future<void> _sortSessionsByTitle() async
  {
    _allSessions?.sort((a, b) {
      String titleA = (a[DashboardUtils.keyTitle]).toString().toLowerCase();
      String titleB = (b[DashboardUtils.keyTitle]).toString().toLowerCase();
      
      return _isAscendingTitle 
          ? titleA.compareTo(titleB) 
          : titleB.compareTo(titleA);
    });
    await _applyFilters();
  }

  // Method used to filter the session data by keywords
  Future<void> _applyFilters() async
  {
    if (_selectedKeywords.isEmpty) 
    {
      _filteredSessions = _allSessions!;
    } else 
    {
      _filteredSessions = _allSessions!.where
      ( 
        (session) 
        {
          final sessionKeywords = session[DashboardUtils.keyKeywords].cast<String>();
          return _selectedKeywords.every((k) => sessionKeywords.contains(k));
        }
      ).toList();
    }
  }

  // Method used to add/remove the keyword from the filtering criteria
  Future<void> _toggleFilter(String keyword) async
  {
     if (_selectedKeywords.contains(keyword)) 
    {
      _selectedKeywords.remove(keyword);
    } 
    else 
    {
      _selectedKeywords.add(keyword);
    }
    await _applyFilters();
    setState(() {});
  }
 

  //**************** DELETION OF SESSION DATA ****************/

  final List<String> _selectedSessionsForDeletion = [];

  // Method used to refresh the keywords list after deletion of session data
  void _refreshKeywords() 
  {
    if (_allSessions == null) return;
    
    Set<String> kwSet = {};
    for (var sessionData in _allSessions!) 
    {
      List<dynamic> kws = sessionData[DashboardUtils.keyKeywords];
      kwSet.addAll(kws.cast<String>());
    }
    
    setState
    (
      () 
      {
      _usedKeywords = kwSet.toList();
      // Removing selected filters if the keyword no longer exists
      _selectedKeywords.removeWhere((kw) => !kwSet.contains(kw));
      }
    );
  }

  // Method used to delete a single session data
  Future<void> _deleteSelectedSession(String filePath) async
  {
    // Removing the file
    await _fu.deleteCsvFile(filePath);

    // Removing dashboard data
    await _du.deleteSessionData(typeOfContextData: DashboardUtils.contextAnalysesContext, filePathRelatedToDataToDelete: filePath);
    
    // Updating state data
    _allSessions?.removeWhere((session) => session[DashboardUtils.keyFilePath] == filePath);      
              
      // Removing from selection list
    _selectedSessionsForDeletion.removeWhere
    (
      (session) => _selectedSessionsForDeletion.contains(filePath)
    );

    // Updating the keyword list
    _refreshKeywords();
    
    // Refreshing the filtered list
    await _applyFilters();

    // Re-building
    setState(()
    {});

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected session deleted.")));

    // Refreshing and resetting "wasSessionDataSaved" if no session data left
    if (_allSessions != null  && _allSessions!.isEmpty) 
    {
      // resetting "wasSessionDataSaved" to false
      await _upu.resetWasSessionDataSavedStatus(context: DashboardUtils.contextAnalysesContext);
      // refreshing the page
      widget.parentCallbackFunctionToRefreshTheContextAnalysisPage();
    }
  }

  // Method used to delete several session data
  Future<void> _deleteSelectedSessions() async 
  {
    // Creating a fixed list to iterate over so clearing doesn't break the loop
    final filesToDelete = List<String>.from(_selectedSessionsForDeletion);

    for (String filePath in filesToDelete) 
    {
      // Removing the file
      await _fu.deleteCsvFile(filePath); 
      
      // Removing dashboard data
      await _du.deleteSessionData
      (
        typeOfContextData: DashboardUtils.contextAnalysesContext, 
        filePathRelatedToDataToDelete: filePath
      );
    }

    // Updating UI state after all physical operations are done
    _allSessions?.removeWhere
    (
      (session) => 
      filesToDelete.contains(session[DashboardUtils.keyFilePath])
    );

    _selectedSessionsForDeletion.clear();

    // Updating the keyword list
    _refreshKeywords();

    // Refreshing the filtered list
    await _applyFilters();
    setState((){});

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));

    // Refreshing and resetting "wasSessionDataSaved" if no session data left
    if (_allSessions != null  && _allSessions!.isEmpty) 
    {
      // resetting "wasSessionDataSaved" to false
      await _upu.resetWasSessionDataSavedStatus(context: DashboardUtils.contextAnalysesContext);
      // refreshing the page
      widget.parentCallbackFunctionToRefreshTheContextAnalysisPage();
    }
  }

  //**************** EDITION OF SESSION DATA ****************/
  final TextEditingController _titleController = TextEditingController();

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

    _refreshKeywords(); // Updates the keywords list
    await _applyFilters();    // Refreshes the filtered view
    
    if ( ! previousKeywords!.equals(newKeywords) )
    {
      setState((){ }); 
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Keywords updated successfully"))
      );
    }
    
  }


  @override
  void initState() 
  {
    super.initState();
    _sessionDataRetrieval();
  }
 
 
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              // Using a CustomScrollView to coordinate the fade effect
              slivers: [
                // Static heading (Scrolls away normally)
                // TODO: the sliver code to clean eventually
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: CustomHeading(
                        headingText: "Previous session data", headingLevel: 2),
                  ),
                ),

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
                    background: _buildFilterAndSortBar(),
                  ),
                ),
                const SliverToBoxAdapter
                (
                  child: Divider()                       
                ), 
                // Session List
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 0),
                  sliver: SliverList(
                    key: const Key('session_list'),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = _filteredSessions![index];
                        final String filePath = session[DashboardUtils.keyFilePath];
                        final bool isChecked =
                            _selectedSessionsForDeletion.contains(filePath);

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
                                      key: ValueKey('checkbox_$index'),
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedSessionsForDeletion
                                                .add(filePath);
                                          } else {
                                            _selectedSessionsForDeletion
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
                                                  child: Text(
                                                    key: ValueKey(
                                                        'session_title_$index'),
                                                    "${session[DashboardUtils.keyTitle]}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  )),
                                              Text(
                                                key: ValueKey(
                                                    'session_date_$index'),
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
                                                  'session_keywords_$index'),
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
                                          icon: const Icon(Icons.share),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Share not yet implemented.')));
                                          },
                                          tooltip: "Share",
                                        ),
                                        IconButton(
                                          key: ValueKey(
                                              'session_delete_$index'),
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

  // Method used to add sorting by date, filtering with keyword, and bulk deletion.
  Widget _buildFilterAndSortBar() 
  {
    return Column
    (
      
      children: 
      [
        Padding
        (
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column
          (
            crossAxisAlignment: CrossAxisAlignment.center,
            children: 
            [
              // Sorting by date/title wrapped for small screens
              Wrap
              (
                spacing: 8.0,   // horizontal gap between buttons
                runSpacing: 4.0, // vertical gap between wrapped lines
                alignment: WrapAlignment.start,
                children: 
                [
                  // Sorting by title
                  TextButton.icon(
                    onPressed: () async 
                    {
                      _isAscendingTitle = !_isAscendingTitle;
                      await _sortSessionsByTitle();
                      setState((){});
                    },
                    icon: const Icon
                    (
                      Icons.sort_by_alpha,
                      color: Colors.black,
                    ),
                    label: Text
                    (
                      "Sort by Title (${_isAscendingTitle ? 'A-Z' : 'Z-A'})",
                      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                  ),
                  // Sorting by date
                  TextButton.icon
                  (
                    onPressed: () async
                    {
                      _isAscendingDate = !_isAscendingDate;
                      await _sortSessionsByDate();
                      setState((){});
                    },
                    icon: Icon
                    (
                      _isAscendingDate ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.black,
                    ),
                    label: const Text
                    (
                      "Sort by Date",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                  ),
                ],
              ),
              // Filtering by keywords
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text
                (
                  "Filter by Keywords:", 
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)
                ),
              ),
            ],
          ),
        ),
        Padding
        (
          padding: const EdgeInsets.only(left: 12.0, right:12, bottom: 12),
          child: Wrap
          (
            spacing: 8.0,
            children: (
                        _usedKeywords!.toList()
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
                            onSelected: (_) async => await _toggleFilter(kw),
                            selected: _selectedKeywords.contains(kw)
                          );
                        }
                      ).toList(),
          ),
        ),
        // Bulk Deletion Button added here
        if (_selectedSessionsForDeletion.isNotEmpty)
          TextButton.icon
          (
            key: const Key('bulk_delete_button'),
            onPressed: _deleteSelectedSessions,
            icon: const Icon
            (
              Icons.delete, color: Colors.red),
              label: Text
              (
                "Delete (${_selectedSessionsForDeletion.length})",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ),
      ],
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
                await _du.saveSessionData
                (
                  typeOfContextData: DashboardUtils.contextAnalysesContext, 
                  savedData: _allSessions!,
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
              
              await _du.saveSessionData
              (
                typeOfContextData: DashboardUtils.contextAnalysesContext, 
                savedData: _allSessions!,
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
  String title = "${session[DashboardUtils.keyTitle]}";

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Close Preview", // Accessibility label
    barrierColor: appBarWhite, 
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
            softWrap:true, title, style: analysisPreviewTitleStyle
          ),
          // Left side: Edit Button
          leading: IconButton(
            icon: const Icon(Icons.edit),
            color: appBarWhite,
            onPressed: () {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit not yet implemented.')));},
            tooltip: "Edit session",
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
              child: ContextAnalysisPreviewWidget(
                pathToCsvData: filePath,
              ),
            ),
          ),
        ),
      );
    },
  );
}
}