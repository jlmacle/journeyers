import 'package:flutter/material.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analyses_dashboard_page.dart';

// Utility class
PrintUtils pu = PrintUtils();
UserPreferencesUtils up = UserPreferencesUtils();

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

  const ContextAnalysisPage({
    super.key,
    this.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability = placeHolderFunctionBool
    });

  @override
  State<ContextAnalysisPage> createState() => ContextAnalysisPageState();
}

class ContextAnalysisPageState extends State<ContextAnalysisPage> 
{
  bool _preferencesLoading = true;
  late bool? _isStartMessageAlreadyAcknowledged;
  late bool _wasContextAnalysisSessionDataSaved;

  // to help reset the start message status
  final bool _resetStartMessage = false;

  FocusNode contextAnalysisFormPageFocusNode = FocusNode();

  getPreferences() async 
  {
    // up.resetWasSessionDataSaved();

    pu.printd("\nEntering getPreferences");
    _isStartMessageAlreadyAcknowledged = await up.isStartMessageAcknowledged();
    _wasContextAnalysisSessionDataSaved = await up.wasSessionDataSaved();

    setState(() {_preferencesLoading = false;});
    pu.printd("_isStartMessageAlreadyAcknowledged: $_isStartMessageAlreadyAcknowledged");
    pu.printd("_wasContextAnalysisSessionDataSaved: $_wasContextAnalysisSessionDataSaved");

    if ((_isStartMessageAlreadyAcknowledged == false) && context.mounted) 
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
                  up.saveStartMessageAcknowledgement();
                  Navigator.pop(context);
                },
                child: 
                RichText
                (
                  text: 
                  TextSpan
                  (
                    text:
                        'This is your first context analysis.\n'
                        'The dashboard will be displayed after data from the context analysis has been saved.\n'
                        'Please click to acknowledge.\n\n',
                    style: dialogStyle,
                  ),
                ),
              ),
            ),
            actions: 
            [
              TextButton
              (
                onPressed: () 
                {
                  up.saveStartMessageAcknowledgement();
                  Navigator.pop(context);
                },
                child: Text('Acknowledged', style: dialogAcknowledgedStyle),
              ),
            ],
          );
        },
      );
    }
  }

  void resetStartMessage() async 
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDialogStartMessageAcknowledged', false);
  }

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

  @override
  void initState() 
  {
    super.initState();
    getPreferences();
  }

  @override
  void dispose() 
  {
    contextAnalysisFormPageFocusNode.dispose();
    super.dispose();
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
          if (_resetStartMessage)
            ElevatedButton
            (
              onPressed: resetStartMessage,
              child: 
              Text
              (
                'Reset the start message acknowledgement data',
                style: feedbackMessageStyle,
              ),
            ),
          if (_preferencesLoading)
            Center(child: CircularProgressIndicator())
          else ...
          [
            if (_wasContextAnalysisSessionDataSaved) ...[
              Padding(
                padding: EdgeInsets.all(elevatedButtonPadding),
                child: ElevatedButton
                (
                  onPressed: () { setState(() { _wasContextAnalysisSessionDataSaved = false;});},
                  child: Text("Please click to start\na new context analysis", textAlign:TextAlign.center ,style: elevatedButtonTextStyle),
                ),
              ),
              Divider(thickness: 3),
              Expanded
              (
                child: ContextAnalysesDashboardPage(parentWidgetCallbackFunctionForContextAnalysisPageRefresh: onAllSessionFilesDeleted)
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
                  child: ContextAnalysisFormPage(parentWidgetCallbackFunctionForContextAnalysisPageRefresh: onDataSaved, parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability: widget.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
