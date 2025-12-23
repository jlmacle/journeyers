import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
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
  late bool? _isStartMessageAlreadyAcknowledged;  
  bool isContextAnalysisSessionDataSaved = false;

  // to help reset the start message status
  bool _resetStartMessage = true;
  
  _getPreferences() async
  {
    _isStartMessageAlreadyAcknowledged = await isStartMessageAcknowledged();
    setState(() {_preferencesLoading = false;});
    printd("_isStartMessageAlreadyAcknowledged: $_isStartMessageAlreadyAcknowledged");
    if ((_isStartMessageAlreadyAcknowledged == false) && context.mounted)
    {
      showDialog
      (
      context: context,
      builder: 
        (BuildContext context) 
        {
          return AlertDialog
          (
            contentPadding: EdgeInsets.only(top:25),
            content: Focus
            (
              child:
              TextButton
              (
                onPressed:() 
                {
                  saveStartMessageAcknowledgement();  
                  Navigator.pop(context);
                },
                child:
                  RichText
                  (
                    text: TextSpan
                    (
                      text: 'This is your first context analysis.\n'
                            'The dashboard will be displayed after data from the context analysis has been saved.\n'
                            'Please click to acknowledge.\n\n',
                      style: dialogStyle,
                    ),
                  )
                ),
            ),
            actions: 
            [
              TextButton
              (
                onPressed: () 
                {
                  saveStartMessageAcknowledgement();  
                  Navigator.pop(context);
                },
                child: Text('Acknowledged', style: dialogStyleAcknowledged)
              ),
            ],
          );
        }
      );
    }
  }

  void resetStartMessage() async
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDialogStartMessageAcknowledged', false);
  }


  @override
  void initState() 
  { 
    super.initState();
    _getPreferences();     
  }

  @override
  Widget build(BuildContext context) 
  { 

    return Scaffold
    (
      body: 
      Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: 
        [
        if (_resetStartMessage)
          ElevatedButton(onPressed: resetStartMessage, child: Text('Reset the start message acknowledgement data', style: feedbackMessageStyle,)),
        if (_preferencesLoading)
          Center(child: CircularProgressIndicator())
        else
          ...
          [            
            ContextAnalysisNewSessionPage(),            
            
            if (isContextAnalysisSessionDataSaved)
            ...
            [
              Divider(),
              ContextAnalysisDashboardPage()
            ],
          ]
        ],
      ),
    );
  }
}