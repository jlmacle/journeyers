import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_expansion_tile.dart';

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

  // Utility classes
  DashboardUtils du = DashboardUtils();
  PrintUtils pu = PrintUtils();

  void _sessionDataRetrieval() async 
  {
    listOfSessionData = await du.retrieveAllDashboardSessionData(typeOfContextData: DashboardUtils.contextAnalysesContext);
    setState(() {
      _isDataLoading = false;
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
        : Column
        (
            mainAxisAlignment: MainAxisAlignment.start,
            children: 
            [
                ListView.builder
                (
                  shrinkWrap: true,
                  itemCount: listOfSessionData?.length,
                  itemBuilder: (content, index) 
                  {
                    Map<String, dynamic>? sessionDataAsMap = listOfSessionData?[index];
                    return 
                    CustomExpansionTile
                    (
                      // TODO: code to complete
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
                ),
            ],
          );
  }
}
