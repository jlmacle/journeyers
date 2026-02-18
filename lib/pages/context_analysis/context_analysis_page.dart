import 'package:flutter/material.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analyses_dashboard_page.dart';

//**************** UTILITY CLASSES ****************/
PrintUtils pu = PrintUtils();
UserPreferencesUtils upu = UserPreferencesUtils();

// TODO: appearance of the UI

/// {@category Pages}
/// {@category Context analysis}
/// The root page for the context analyses.
/// The context analysis page embeds a ContextAnalysisNewSessionPage and a ContextAnalysesDashboardPage.
class ContextAnalysisPage extends StatefulWidget 
{
  /// An "expansion tile expanded/folded"-related callback function for the parent widget, to enhance the tab navigation.
  final ValueChanged<bool> parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability;

  /// A placeholder void callback function with a bool parameter
  static void placeHolderFunctionBool(bool value) {}

  const ContextAnalysisPage
  ({
    super.key,
    this.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability = placeHolderFunctionBool
  });

  @override
  State<ContextAnalysisPage> createState() => ContextAnalysisPageState();
}

class ContextAnalysisPageState extends State<ContextAnalysisPage> 
{
  //**************** USEFUL FOR DEBUG ****************//
  // to help reset the acknowledgment modal status
  final bool _resetInformationModal = false;

  //**************** PREFERENCES related data and methods ****************//
  bool _preferencesLoading = true;
  late bool? _isInformationModalAlreadyAcknowledged;
  late bool? _wasContextAnalysisSessionDataSaved;

  getPreferences() async 
  {
    // up.resetWasSessionDataSaved();

    pu.printd("\nEntering getPreferences");
    _isInformationModalAlreadyAcknowledged = await upu.isInformationModalAcknowledged();
    _wasContextAnalysisSessionDataSaved = await upu.wasSessionDataSaved();

    setState(() {_preferencesLoading = false;});
    pu.printd("_isInformationModalAlreadyAcknowledged: $_isInformationModalAlreadyAcknowledged");
    pu.printd("_wasContextAnalysisSessionDataSaved: $_wasContextAnalysisSessionDataSaved");

    if ((_isInformationModalAlreadyAcknowledged == false) && context.mounted) 
    {
      showDialog
      (
        context: context,
        builder: (BuildContext context) 
        {
          return 
          AlertDialog
          (
            contentPadding: EdgeInsets.only(top: 25),
            content: 
            Focus
            (
              child: 
              TextButton
              (
                onPressed: () 
                {
                  upu.saveInformationModalAcknowledgement();
                  Navigator.pop(context);
                },
                child: 
                RichText
                (
                  key: const Key('information_modal'),
                  textAlign: TextAlign.center,
                  text: 
                  TextSpan
                  (                    
                    text:
                        'This is your first context analysis.\n'
                        'The dashboard will be displayed after data from the context analysis has been saved.\n'
                        'Please click to acknowledge.\n',
                    style: dialogStyle, 
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  //**************** METHODS USED TO SWITCH BETWEEN FORM VIEW AND DASHBOARD VIEW  ****************//

  // Method used to refresh the page from context form to dashboard, 
  // after form data has been saved
  void onDataSaved() 
  {
    setState(() {
      _wasContextAnalysisSessionDataSaved = true;
    });
  }

  // Method used to refresh the page from dashboard to context form, 
  // after all session files have been deleted
  void onAllSessionFilesDeleted() 
  {
    setState(() {
      _wasContextAnalysisSessionDataSaved = false;
    });
  }

  //**************** FOCUS NODE related data and methods ****************//
  FocusNode contextAnalysisFormPageFocusNode = FocusNode();

  @override
  void dispose() 
  {
    contextAnalysisFormPageFocusNode.dispose();
    super.dispose();
  } 

  @override
  void initState() 
  {
    super.initState();
    getPreferences();
  }  

  @override
  Widget build(BuildContext context) 
  {
    return 
    Scaffold
    (
      body: 
      Column
      (
        mainAxisAlignment: MainAxisAlignment.start,
        children: 
        [
          if (_resetInformationModal)
            ElevatedButton
            (
              onPressed: upu.resetInformationModalStatus,
              child: 
              Text
              (
                'Reset the acknowledgment modal acknowledgement data',
                style: feedbackMessageStyle,
              ),
            ),
          if (_preferencesLoading)
            Center(child: CircularProgressIndicator())
          else ...
          [
            if (_wasContextAnalysisSessionDataSaved!) ...
            [
              SizedBox
              (
                width: double.infinity,
                child: 
                  ElevatedButton
                  (                    
                    key: const Key('analyses_new_session_button'),
                    onPressed: () { setState(() { _wasContextAnalysisSessionDataSaved = false;});},
                    style: ElevatedButton.styleFrom
                    (
                      padding: EdgeInsets.only(top: 10, bottom: 16),
                      shape: RoundedRectangleBorder
                      (
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text("Please click to start\na new context analysis", textAlign:TextAlign.center ,style: elevatedButtonTextStyle),  
                  ),
              ),
              Divider(thickness: 3, height: 0),
              Expanded
              (
                child: ContextAnalysesDashboardPage(key: const Key('analyses_dashboard'), parentWidgetCallbackFunctionForContextAnalysisPageRefresh: onAllSessionFilesDeleted)
              ),
            ]
            else
            Expanded
            (
              child: 
              Padding
              (
                padding: const EdgeInsets.all(15.0),
                child: 
                Focus
                (
                  focusNode: contextAnalysisFormPageFocusNode,
                  child: ContextAnalysisFormPage(key: const Key('form'), parentWidgetCallbackFunctionForContextAnalysisPageRefresh: onDataSaved, parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability: widget.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
