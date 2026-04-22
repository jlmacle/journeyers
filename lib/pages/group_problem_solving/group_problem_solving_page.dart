import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/widgets/utility/dashboard_page.dart';


/// {@category Pages}
/// {@category Group problem-solving}
/// The root page for the group problem-solving sessions.
/// The group problem-solving page embeds a DashboardPage widget and/or a GPSProcess widget.
class GPSPage extends StatefulWidget 
{
  const GPSPage
  ({
    super.key
  });

  @override
  State<GPSPage> createState() => GPSPageState();
}

class GPSPageState extends State<GPSPage> 
{
  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  bool _preferencesLoading = true;
  bool? _wasGPSSessionDataSaved;

  getPreferences() async 
  {
    if (preferencesDebug) pu.printd("Preferences: getPreferences()");
    _wasGPSSessionDataSaved = await upu.wasSessionDataSaved(context: DashboardUtils.gpsContext);

    setState(() {_preferencesLoading = false;});
    if (preferencesDebug) pu.printd("Preferences: _wasGPSSessionDataSaved: $_wasGPSSessionDataSaved");
  }

  // ─── METHODS USED TO REFRESH VIEWS ───────────────────────────────────────

  // Method used to refresh the page from group problem-solving process page to dashboard, 
  // after process data has been saved
  void onDataSaved() 
  {
    setState(() {
      _wasGPSSessionDataSaved = true;
    });
  }

  // Method used to refresh the page from dashboard to group problem-solving process page, 
  // after all session files have been deleted
  void onAllSessionFilesDeleted() 
  {
    if (sessionDataDebug) pu.printd("Session Data: GPS page: onAllSessionFilesDeleted");

    setState(() {
      _wasGPSSessionDataSaved = false;
    });
  }
    // ─── FOCUS NODE related data and methods ───────────────────────────────────────
  FocusNode gpsPageFocusNode = .new();

  @override
  void dispose() 
  {
    gpsPageFocusNode.dispose();
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
            if (_wasGPSSessionDataSaved!) ...
            [
              // If so, a screen-wide rectangle, with an invite to start a new group problem-solving
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
                      key: const Key('group-problem-solving-new-session-button'),
                      onPressed: () { setState(() { _wasGPSSessionDataSaved = false;});},
                      style: ElevatedButton.styleFrom
                      (
                        backgroundColor: white,
                        padding: const EdgeInsets.only(top: 10, bottom: 16),
                        shape: const RoundedRectangleBorder
                        (
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text("Please click to start\na new group problem-solving session", textAlign:TextAlign.center ,style: elevatedButtonTextStyle),  
                    ),
                  ),
              ),
              // and the session data dashboard in the remaining space
              Expanded
              (
                child: 
                DashboardPage
                (
                  key: const Key('group-problem-solving-dashboard'),
                  dashboardContext: DashboardUtils.gpsContext,
                  dashboardFilteringByKeywordsKey: dashboardFilteringByKeywordsKeyGPS,
                  parentCallbackFunctionWhenAllSessionFilesAreDeleted: onAllSessionFilesDeleted                  
                )
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
                  focusNode: gpsPageFocusNode,
                  child: GPSProcess(key: gpsPageKey, parentCallbackFunctionToRefreshTheGPSPage: onDataSaved),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
