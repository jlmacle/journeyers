import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_dismissable_rectangular_area.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_dashboard_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_new_session_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContextAnalysisPage extends StatefulWidget 
{
  const ContextAnalysisPage({super.key});

  @override
  State<ContextAnalysisPage> createState() => _ContextAnalysisPageState();
}

class _ContextAnalysisPageState extends State<ContextAnalysisPage>  
{ 
  bool _preferencesLoading = true;
  late bool? _isStartMessageAcknowledged;  
  bool isContextAnalysisSessionDataSaved = false;

  _getPreferences() async{
    _isStartMessageAcknowledged = await isStartMessageAcknowledged();
      setState(() {  
        _preferencesLoading = false;
      });
  }

  @override
  void initState() 
  { 
    super.initState();
    _getPreferences();     
  }

    void _hideMessageArea()
    {
      setState(() {
        saveStartMessageAcknowledgement();
        _isStartMessageAcknowledged = true;
      });
      
    }

  void resetAcknowledgement() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('startMessageAcknowledged', false);
  }

  @override
  Widget build(BuildContext context) 
  { 

    FocusNode dismissableMsgFocusNode = FocusNode();    

    return Scaffold
    (
      body: 
      Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: 
        [
        if (_preferencesLoading)
          Center(child: CircularProgressIndicator())
        else
          ...[
            ContextAnalysisNewSessionPage(),
            if (!(_isStartMessageAcknowledged!))
              Semantics
              (
                focusable: true,
                focused: true,
                child: Focus
                (
                  focusNode: dismissableMsgFocusNode,
                  child: 
                  CustomDismissableRectangularArea
                  (
                    buildContext:context, 
                    message1: 'This is your first context analysis.', 
                    message2: 'The dashboard will be displayed after data from the context analysis has been saved.',
                    messagesColor: paleCyan, // from app_themes
                    actionText:'Please click the message area to acknowledge.',
                    actionTextColor: paleCyan, // from app_themes,
                    areaBackgroundColor: navyBlue, // from app_themes
                    setStateCallBack: _hideMessageArea
                  )
                ),
              ),                
            if (isContextAnalysisSessionDataSaved)
            ...[
              Divider(),
              ContextAnalysisDashboardPage()
            ],
            // ElevatedButton(onPressed: resetAcknowledgement, child: Text('Reset acknowledgement'))
          ]
        // TextButton(
        //   onPressed: () {
        //     // This dumps the Semantics Tree's structure and properties to the console.
        //     debugDumpSemanticsTree(); 
        //   },
        //     child: const Text('Dump Semantics'),
        //   )
        ],
      ),
    );
  }
}