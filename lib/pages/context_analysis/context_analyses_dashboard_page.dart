import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/files/files_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';
import 'package:journeyers/widgets/utility/context_analysis_preview_widget.dart';

/// {@category Pages}
/// {@category Context analysis}
/// The page displaying a dashboard of the past context analyses.
class ContextAnalysesDashboardPage extends StatefulWidget 
{

  /// A callback function called after all session files have been deleted, and used to pass from dashboard to context analysis form.
  final VoidCallback parentWidgetCallbackFunctionForContextAnalysisPageRefresh;

  /// A placeholder void callback function 
  static void placeHolderVoidCallback() {}

  const ContextAnalysesDashboardPage
  ({
    super.key,
    this.parentWidgetCallbackFunctionForContextAnalysisPageRefresh = placeHolderVoidCallback,
  });

  @override
  State<ContextAnalysesDashboardPage> createState() => _ContextAnalysesDashboardPageState();
}

class _ContextAnalysesDashboardPageState extends State<ContextAnalysesDashboardPage> 
{
  //**************** UTILITY CLASSES ****************/
  final DashboardUtils _du = DashboardUtils();
  final FileUtils _fu = FileUtils();
  final UserPreferencesUtils _upu = UserPreferencesUtils();

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
    _sortSessionsByDate();
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
  bool _isAscending = false; 

  List<dynamic>? _allSessions;
  List<dynamic>? _filteredSessions;

  List<String>? _usedKeywords;
  final List<String> _selectedKeywords = [];

  // Method used to sort session data by date
  void _sortSessionsByDate() 
  {
    _allSessions?.sort((a, b) 
    {
      DateTime dateA = DateFormat('MMMM dd, yyyy').add_jm().parse(a[DashboardUtils.keyDate]);
      DateTime dateB = DateFormat('MMMM dd, yyyy').add_jm().parse(b[DashboardUtils.keyDate]);
      return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    _applyFilters();
  }
 
  // Method used to sort session data by title 
  void _sortSessionsByTitle() {
    _allSessions?.sort((a, b) {
      String titleA = (a[DashboardUtils.keyTitle]).toString().toLowerCase();
      String titleB = (b[DashboardUtils.keyTitle]).toString().toLowerCase();
      
      return _isAscending 
          ? titleA.compareTo(titleB) 
          : titleB.compareTo(titleA);
    });
    _applyFilters();
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
  void _toggleFilter(String keyword) 
  {
    setState(() 
    {
      if (_selectedKeywords.contains(keyword)) 
      {
        _selectedKeywords.remove(keyword);
      } 
      else 
      {
        _selectedKeywords.add(keyword);
      }
      _applyFilters();
    });
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
    await _du.deleteSessionData(typeOfContextData: DashboardUtils.contextAnalysesContext, filePathToDelete: filePath);
    
    // Updating state data
    setState(() 
    {
      _allSessions?.removeWhere((session) => session[DashboardUtils.keyFilePath] == filePath);      
              
      // Removing from selection list
      _selectedSessionsForDeletion.removeWhere
      (
        (session) => _selectedSessionsForDeletion.contains(filePath)
      );

      // Updating the keyword list
      _refreshKeywords();
      
      // Refreshing the filtered list
      _applyFilters();

      // Displaying an informational message
      ScaffoldMessenger.of(context).showSnackBar
      (const SnackBar(content: Text("Selected session deleted.")));
    });

    // Refreshing and resetting "wasSessionDataSaved" if no session data left
    if (_allSessions != null  && _allSessions!.isEmpty) 
    {
      // resetting "wasSessionDataSaved" to false
      await _upu.resetWasSessionDataSavedStatus();
      // refreshing the page
      widget.parentWidgetCallbackFunctionForContextAnalysisPageRefresh();
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
        filePathToDelete: filePath
      );
    }

    // Updating UI state after all physical operations are done
    setState(() 
    {
      _allSessions?.removeWhere
      (
        (session) => 
        filesToDelete.contains(session[DashboardUtils.keyFilePath])
      );

      _selectedSessionsForDeletion.clear();

      // Updating the keyword list
      _refreshKeywords();

      // Refreshing the filtered list
      _applyFilters();
    });

    // Displaying an informational message
    ScaffoldMessenger.of(context).showSnackBar
    (const SnackBar(content: Text("Selected sessions deleted.")));

    // Refreshing and resetting "wasSessionDataSaved" if no session data left
    if (_allSessions != null  && _allSessions!.isEmpty) 
    {
      // resetting "wasSessionDataSaved" to false
      await _upu.resetWasSessionDataSavedStatus();
      // refreshing the page
      widget.parentWidgetCallbackFunctionForContextAnalysisPageRefresh();
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: CustomHeading(headingText: "Previous session data", headingLevel: 2),
                ),
                _buildFilterAndSortBar(),
                Expanded(
                  child: ListView.builder(
                    key: const Key('session_list'),
                    itemCount: _filteredSessions?.length ?? 0,
                    itemBuilder: (context, index) {
                      final session = _filteredSessions![index];
                      final String filePath = session[DashboardUtils.keyFilePath];
                      final bool isChecked = _selectedSessionsForDeletion.contains(filePath);

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
                                  Checkbox(
                                    key: ValueKey('checkbox_$index'),
                                    value: isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedSessionsForDeletion.add(filePath);
                                        } else {
                                          _selectedSessionsForDeletion.remove(filePath);
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Text(
                                              key: ValueKey('session_title_$index'),
                                              "${session[DashboardUtils.keyTitle]}",
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            Text(
                                              key: ValueKey('session_date_$index'),
                                              "(${session[DashboardUtils.keyDate]})",
                                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          key: ValueKey('session_keywords_$index'),
                                          "Keywords: ${session[DashboardUtils.keyKeywords].join(', ')}",
                                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              // Action Bar: Split between Left and Right
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left Side Actions: Preview, Edit, Keywords
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.find_in_page_rounded),
                                        onPressed: () => _showPreviewOverlay(context, filePath),
                                        tooltip: "Preview",
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_document),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit not yet implemented.')));
                                        },
                                        tooltip: "Edit Document",
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.style_rounded),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keywords edition not yet implemented.')));
                                        },
                                        tooltip: "Edit Keywords",
                                      ),
                                    ],
                                  ),
                                  // Right Side Actions: Share, Delete
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share not yet implemented.')));
                                        },
                                        tooltip: "Share",
                                      ),
                                      IconButton(
                                        key: ValueKey('session_delete_$index'),
                                        icon: const Icon(Icons.delete_rounded),
                                        onPressed: () async => await _deleteSelectedSession(filePath),
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
                    onPressed: () {
                      setState(() {
                        _isAscending = !_isAscending;
                        _sortSessionsByTitle();
                      });
                    },
                    icon: Icon
                    (
                      Icons.sort_by_alpha,
                      color: Colors.black,
                    ),
                    label: Text(
                      "Sort by Title (${_isAscending ? 'A-Z' : 'Z-A'})",
                      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                  ),
                  // Sorting by date
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAscending = !_isAscending;
                        _sortSessionsByDate();
                      });
                    },
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "Sort by Date",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                  ),
                ],
              ),
              // Filtering by keywords
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Filter by Keywords:", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Wrap(
            spacing: 8.0,
            children: _usedKeywords!.map((kw) {
              return FilterChip(
                label: Text(kw),
                onSelected: (_) => _toggleFilter(kw),
                selected: _selectedKeywords.contains(kw),
              );
            }).toList(),
          ),
        ),
        // Bulk Deletion Button added here
        if (_selectedSessionsForDeletion.isNotEmpty)
          TextButton.icon(
            key: const Key('bulk_delete_button'),
            onPressed: _deleteSelectedSessions,
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            label: Text(
              "Delete (${_selectedSessionsForDeletion.length})",
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        const Divider(),
      ],
    );
  }

  // Method used to display an overlay with a session data preview. 
  void _showPreviewOverlay(BuildContext context, String filePath) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Close Preview", // Accessibility label
    barrierColor: appBarWhite, //TODO: potential cleaning
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true, 
          title: const Text("Session Preview"),
          
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