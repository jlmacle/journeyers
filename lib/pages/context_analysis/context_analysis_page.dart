import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analyses_dashboard_page.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_page.dart';

//**************** UTILITY CLASSES ****************/
PrintUtils pu = PrintUtils();
UserPreferencesUtils upu = UserPreferencesUtils();

/// {@category Pages}
/// {@category Context analysis}
/// The root page for the context analyses.
/// The context analysis page embeds a ContextAnalysesDashboardPage and/or a ContextAnalysisFormPage.
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
  //**************** PREFERENCES related data and methods ****************//
  bool _preferencesLoading = true;
  bool? _isInformationModalAlreadyAcknowledged;
  bool? _wasContextAnalysisSessionDataSaved;

  getPreferences() async 
  {
    pu.printd("\nEntering getPreferences");
    _isInformationModalAlreadyAcknowledged = await upu.isInformationModalAcknowledged();
    _wasContextAnalysisSessionDataSaved = await upu.wasSessionDataSaved();




    setState(() {_preferencesLoading = false;});
    pu.printd("_isInformationModalAlreadyAcknowledged: $_isInformationModalAlreadyAcknowledged");
    pu.printd("_wasContextAnalysisSessionDataSaved: $_wasContextAnalysisSessionDataSaved");

    if ((_isInformationModalAlreadyAcknowledged == false) && mounted) 
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
                Padding
                (
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text
                  (
                    key: const Key('information_modal'),
                    AppLocalizations.of(context)?.start_msg ?? 'Issue with the application start message',
                    textAlign: TextAlign.center,                                          
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
          // Circular progress indicator while preferences are loading
          if (_preferencesLoading)
            Center(child: CircularProgressIndicator())
          // When preferences are loaded
          else ...
          [
            // Checking if context analysis session data has been stored
            if (_wasContextAnalysisSessionDataSaved!) ...
            [
              // If so, a screen-wide rectangle, with an invite to start a new context analysis
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
              // and the session data dashboard in the remaining space
              Expanded
              (
                child: ContextAnalysesDashboardPage(key: const Key('analyses_dashboard'), parentWidgetCallbackFunctionForContextAnalysisPageRefresh: onAllSessionFilesDeleted)
              ),
            ]
            else
            // if no context analysis session data has been stored, a context analysis form is displayed
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
