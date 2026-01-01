
import 'package:flutter/material.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_expansion_tile.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

/// {@category Pages}
/// {@category Context analysis}
/// The page for the dashboard of the context analyses.
class ContextAnalysisDashboardPage extends StatefulWidget {
  const ContextAnalysisDashboardPage({super.key});

  @override
  State<ContextAnalysisDashboardPage> createState() => _ContextAnalysisDashboardPageState();
}

class _ContextAnalysisDashboardPageState extends State<ContextAnalysisDashboardPage> 
{
  bool _isDataLoading = true;
  Map<String,dynamic>? completeSessionData;
  List<dynamic>? listOfSessionData;

  // Utility classes
  DashboardUtils du = DashboardUtils();
  PrintUtils pu = PrintUtils();

  void  _sessionDataRetrieval() async
  {
    completeSessionData =  await du.retrieveAllDashboardSessionData(DashboardUtils.dataContextAnalyses); 
    setState(() {
      _isDataLoading = false;      
      listOfSessionData = completeSessionData?.values.first;
  
    });   
  }

  @override
  void initState() 
  { 
    super.initState();
    _sessionDataRetrieval();   
  }

  void onEditPressed(String? csvFilePath)
  {
    pu.printd("csvFilePath: $csvFilePath");

  }
   
  

  @override
  Widget build(BuildContext context) 
  {

    FocusNode contextAnalysisDashboardFocusNode = FocusNode();
    
    return 
        _isDataLoading
        ? Center(child: CircularProgressIndicator())
        : Expanded
        (
            child: Semantics
            (        
              headingLevel: 2,
              focusable: true,
              child: Focus
              (
                focusNode: contextAnalysisDashboardFocusNode,
                
                child: ListView.builder
                (
                  itemCount: listOfSessionData?.length,
                  itemBuilder : (content, index)
                  {
                    Map<String,dynamic>? sessionDataAsMap = listOfSessionData?[index];
                    return 
                    CustomExpansionTile
                    (
                      text: "(${sessionDataAsMap?[DashboardUtils.keyDate]}) ${sessionDataAsMap?[DashboardUtils.keyTitle]}",
                      expandedContentText:"", 
                      parentWidgetOnEditPressedCallBackFunction: (){onEditPressed(sessionDataAsMap?[DashboardUtils.keyFilePath]);}, 
                      parentWidgetOnDeletePressedCallBackFunction: (){}, 
                      parentWidgetOnSharePressedCallBackFunction: (){}
                      );
                  }
                )
              ),
            ),
        );
    
  }
}