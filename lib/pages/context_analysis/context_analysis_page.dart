import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/widgets/utility/dashboard_page.dart';


/// {@category Pages}
/// {@category Context analysis}
/// The root page for the context analysis sessions.
/// The context analysis page embeds a DashboardPage and/or a CAFormPage.
class CAPage extends StatefulWidget 
{
  /// An "expansion tile expanded/folded"-related callback function for the parent widget, to enhance the tab navigation.
  final ValueChanged<bool> parentCallbackFunctionToSetFocusabilityOfBottomBarItems;

  const CAPage
  ({
    super.key,
    this.parentCallbackFunctionToSetFocusabilityOfBottomBarItems = placeHolderFunctionBool
  });

  @override
  State<CAPage> createState() => CAPageState();
}

class CAPageState extends State<CAPage> 
{  
  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  bool _preferencesLoading = true;
  bool? _isInformationModalAlreadyAcknowledged;
  bool? _wasCASessionDataSaved;

  getPreferences() async 
  {
    if (preferencesDebug) pu.printd("Preferences: getPreferences()");
    _isInformationModalAlreadyAcknowledged = await upu.isInformationModalAcknowledged();
    _wasCASessionDataSaved = await upu.wasSessionDataSaved(context: DashboardUtils.caContext);

    setState(() {_preferencesLoading = false;});
    if (preferencesDebug) pu.printd("Preferences: _isInformationModalAlreadyAcknowledged: $_isInformationModalAlreadyAcknowledged");
    if (preferencesDebug) pu.printd("Preferences: _wasCASessionDataSaved: $_wasCASessionDataSaved");

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
            contentPadding: const EdgeInsets.only(top: 25),
            content: 
            Focus
            (
              child: 
              TextButton
              (
                onPressed: () async
                {
                  await upu.saveInformationModalAcknowledgement(wasAcknowledged: true);
                  Navigator.pop(context);
                },
                child: 
                Padding
                (
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text
                  (
                    key: const Key('information-modal'),
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

  // ─── METHODS USED TO REFRESH VIEWS ───────────────────────────────────────

  // Method used to refresh the page from context form to dashboard, 
  // after form data has been saved
  void onDataSaved() 
  {
    setState(() {
      _wasCASessionDataSaved = true;
    });
  }

   // Method used to refresh the page from dashboard to context form, 
  // after all session files have been deleted
  void onAllSessionFilesDeleted() 
  {
    if (sessionDataDebug) pu.printd("Session Data: CA page: onAllSessionFilesDeleted");

    setState(() {
      _wasCASessionDataSaved = false;
    });
  }

   // Method used to refresh the page
  void onPageToRefresh()
  {
    setState(() {});
  }

  // ─── FOCUS NODE related data and methods ───────────────────────────────────────
  FocusNode caFormPageFocusNode = .new();

  @override
  void dispose() 
  {
    caFormPageFocusNode.dispose();
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
            const Center(child: CircularProgressIndicator())
          // When preferences are loaded
          else ...
          [
            // Checking if context analysis session data has been stored
            if (_wasCASessionDataSaved!) ...
            [
              // If so, a screen-wide rectangle, with an invite to start a new context analysis
              SizedBox
              (
                width: double.infinity,
                child: 
                  Container(
                    decoration: BoxDecoration(
                      // Logic: If all checked, color is white; otherwise, orangeShade900
                      border: Border.all(
                        color:  blueShade900, 
                        width: 5.0,
                      ),
                    ),
                    child: ElevatedButton
                    (                    
                      key: const Key('analyses-new-session-button'),
                      onPressed: () { setState(() { _wasCASessionDataSaved = false;});},
                      style: ElevatedButton.styleFrom
                      (
                        backgroundColor: white,
                        padding: const EdgeInsets.only(top: 10, bottom: 16),
                        shape: const RoundedRectangleBorder
                        (
                          borderRadius: BorderRadius.zero,
                        ),
                        
                      ),
                      child: const Text("Please click to start\na new context analysis", textAlign:TextAlign.center ,style: elevatedButtonTextStyle),  
                    ),
                  ),
              ),
              // and the session data dashboard in the remaining space
              Expanded
              (
                child: DashboardPage
                (
                  key: const Key('analyses-dashboard'), 
                  dashboardContext: DashboardUtils.caContext,
                  dashboardFilteringByKeywordsKey: dashboardFilteringByKeywordsKeyCA,
                  parentCallbackFunctionWhenAllSessionFilesAreDeleted: onAllSessionFilesDeleted,
                  
                )
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
                  focusNode: caFormPageFocusNode,
                  child: CAProcess(key: caProcessKey, parentCallbackFunctionToRefreshTheCAPage: onDataSaved, parentCallbackFunctionToSetFocusabilityOfBottomBarItems: widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
