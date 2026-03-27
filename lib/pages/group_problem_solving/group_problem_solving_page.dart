import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/debug_constants.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_dashboard_page.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart';

//**************** UTILITY CLASSES ****************/
PrintUtils _pu = PrintUtils();
UserPreferencesUtils upu = UserPreferencesUtils();

/// {@category Pages}
/// {@category Group Problem Solving}
/// The root page for the group problem-solving sessions.
/// The group problem-solving page embeds a GroupProblemSolvingDashboardPage widget and/or a GroupProblemSolvingProcess widget.
class GroupProblemSolvingPage extends StatefulWidget 
{
  const GroupProblemSolvingPage
  ({
    super.key
  });

  @override
  State<GroupProblemSolvingPage> createState() => GroupProblemSolvingPageState();
}

class GroupProblemSolvingPageState extends State<GroupProblemSolvingPage> 
{
  GlobalKey<GroupProblemSolvingProcessState> groupProblemSolvingPageKey = GlobalKey(debugLabel:'groupProblemSolvingPage');

  //**************** PREFERENCES related data and methods ****************//
  bool _preferencesLoading = true;
  bool? _wasGroupProblemSolvingSessionDataSaved;

  getPreferences() async 
  {
    if (preferencesDebug) _pu.printd("Preferences: getPreferences()");
    _wasGroupProblemSolvingSessionDataSaved = await upu.wasGroupProblemSolvingSessionDataSaved();

    setState(() {_preferencesLoading = false;});
    if (preferencesDebug) _pu.printd("Preferences: _wasGroupProblemSolvingSessionDataSaved: $_wasGroupProblemSolvingSessionDataSaved");
  }

  //**************** METHODS USED TO SWITCH BETWEEN PROCESS VIEW AND DASHBOARD VIEW  ****************//

  // Method used to refresh the page from process page to dashboard, 
  // after process data has been saved
  void onDataSaved() 
  {
    setState(() {
      _wasGroupProblemSolvingSessionDataSaved = true;
    });
  }

  // Method used to refresh the page from dashboard to process page, 
  // after all session files have been deleted
  void onAllSessionFilesDeleted() 
  {
    setState(() {
      _wasGroupProblemSolvingSessionDataSaved = false;
    });
  }

  //**************** FOCUS NODE related data and methods ****************//
  FocusNode groupProblemSolvingPageFocusNode = FocusNode();

  @override
  void dispose() 
  {
    groupProblemSolvingPageFocusNode.dispose();
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
            // Checking if group problem-solving session data has been stored
            if (_wasGroupProblemSolvingSessionDataSaved!) ...
            [
              // If so, a screen-wide rectangle, with an invite to start a new group problem-solving
              SizedBox
              (
                width: double.infinity,
                child: 
                  ElevatedButton
                  (                    
                    key: const Key('problem_solving_new_session_button'),
                    onPressed: () { setState(() { _wasGroupProblemSolvingSessionDataSaved = false;});},
                    style: ElevatedButton.styleFrom
                    (
                      padding: const EdgeInsets.only(top: 10, bottom: 16),
                      shape: const RoundedRectangleBorder
                      (
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text("Please click to start\na new group problem-solving session", textAlign:TextAlign.center ,style: elevatedButtonTextStyle),  
                  ),
              ),
              const Divider(thickness: 3, height: 0),
              // and the session data dashboard in the remaining space
              Expanded
              (
                child: GroupProblemSolvingDashboardPage(key: const Key('problem_solving_dashboard'), parentCallbackFunctionToRefreshTheGroupProblemSolvingPage: onAllSessionFilesDeleted)
              ),
            ]
            else
            // if no group problem-solving session data has been stored, the group problem-solving process is displayed
            Expanded
            (
              child: 
              Padding
              (
                padding: const EdgeInsets.all(15.0),
                child: 
                Focus
                (
                  focusNode: groupProblemSolvingPageFocusNode,
                  child: GroupProblemSolvingProcess(key: groupProblemSolvingPageKey, parentCallbackFunctionToRefreshTheGroupProblemSolvingPage: onDataSaved),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
