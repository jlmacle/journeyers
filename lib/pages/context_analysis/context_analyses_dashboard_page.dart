import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_expansion_tile.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';

/// {@category Pages}
/// {@category Context analysis}
/// The page for the dashboard of the context analyses.
class ContextAnalysesDashboardPage extends StatefulWidget 
{
  const ContextAnalysesDashboardPage({super.key});

  @override
  State<ContextAnalysesDashboardPage> createState() =>  _ContextAnalysesDashboardPageState();
}

class _ContextAnalysesDashboardPageState extends State<ContextAnalysesDashboardPage> 
{
  FocusNode contextAnalysisDashboardFocusNode = FocusNode();

  bool _isDataLoading = true;
  Map<String, dynamic>? completeSessionData;
  List<dynamic>? listOfSessionData;
  List<dynamic>? _allSessions;
  List<dynamic>? _filteredSessions;
  List<String>? _usedKeywords;
  List<String> _selectedKeywords = [];

  // Utility classes
  DashboardUtils du = DashboardUtils();
  PrintUtils pu = PrintUtils();

  void _sessionDataRetrieval() async 
  {
    listOfSessionData = await du.retrieveAllDashboardSessionData(typeOfContextData: DashboardUtils.contextAnalysesContext);
    _usedKeywords= await usedKeywords(listOfSessionData!);
    _allSessions = listOfSessionData;
    _filteredSessions = listOfSessionData;
    print("_usedKeywords: $_usedKeywords");
    setState(() {
      _isDataLoading = false;
    });
  }

  Future<List<String>> usedKeywords(List<dynamic> listOfSessionData) async 
  {
    List<String> usedKeywords = [];
    Set<String> kwSet = {};
    for(var sessionData in listOfSessionData)
    {     
      List<dynamic> kws = sessionData[DashboardUtils.keyKeywords];   
      kwSet.addAll(kws.cast<String>());     
    }
    usedKeywords = kwSet.toList();

    return usedKeywords;
  }

  void _toggleFilter(String keyword)
  {
    setState(() {
      if (_selectedKeywords.contains(keyword)) {_selectedKeywords.remove(keyword);} 
      else {_selectedKeywords.add(keyword);}

      if (_selectedKeywords.isEmpty) 
        {_filteredSessions = _allSessions;} 
      else 
      {
        _filteredSessions = _allSessions!.where
        (
          (session) 
          {
            final sessionKeywords = session[DashboardUtils.keyKeywords].cast<String>(); // List<dynamic> before casting
            return _selectedKeywords.every( (k) => sessionKeywords.contains(k) );
          }
        ).toList();
      }
    });
  }

  @override
  void initState() 
  {
    super.initState();
    _sessionDataRetrieval();
  }

  @override
  void dispose() 
  {
    contextAnalysisDashboardFocusNode.dispose();
    super.dispose();
  }

  void onEditPressed(String? csvFilePath) 
  {
    pu.printd("csvFilePath: $csvFilePath");
  }

  @override
Widget build(BuildContext context) 
{
  return _isDataLoading
      ? Center(child: CircularProgressIndicator())
      : ListView.builder  
        (
          // Adding heading and keywords filtering to item count
          itemCount: _filteredSessions!= null ? _filteredSessions!.length + 2 : 2,
          itemBuilder: (content, index) 
          {
            // Heading as first item
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: CustomHeading(headingText: "Previous session data", headingLevel: 2),
              );
            }
            
            // Keywords as second item
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
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
              );
            }
            
            // session data after the first two indexes
            Map<String, dynamic>? sessionDataAsMap = _filteredSessions?[index - 2];
            return CustomExpansionTile(
              text: "${sessionDataAsMap?[DashboardUtils.keyTitle]} (${sessionDataAsMap?[DashboardUtils.keyDate]}) ",
              textStyle: customExpansionTileTextStyle,
              expandedContentText: "",
              parentWidgetOnEditPressedCallBackFunction: 
                () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit not yet implemented.')));},
              parentWidgetOnDeletePressedCallBackFunction: 
                () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete not yet implemented.')));},
              parentWidgetOnSharePressedCallBackFunction: 
                () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share not yet implemented.')));},
            );
          },
        );
  }
}
