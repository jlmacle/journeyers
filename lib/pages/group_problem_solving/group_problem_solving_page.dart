import 'package:flutter/material.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/widgets/utility/dashboard_page.dart';
import 'package:journeyers/widgets/utility/process_widgets/new_process_button.dart';


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

  _getPreferences() async 
  {
    if (runtimeDataDebug) pu.printd("Runtime Data: getPreferences()");
    _wasGPSSessionDataSaved = await rtdu.wasSessionDataSaved(context: DashboardUtils.gpsContext);

    setState(() {_preferencesLoading = false;});
    if (runtimeDataDebug) pu.printd("Runtime Data: _wasGPSSessionDataSaved: $_wasGPSSessionDataSaved");
  }

  // ─── METHODS USED TO REFRESH VIEWS ───────────────────────────────────────

  // Method used to refresh the page from group problem-solving process page to dashboard, 
  // after process data has been saved
  void _onDataSaved() 
  {
    setState(() {
      _wasGPSSessionDataSaved = true;
    });
  }

  // Used in DashboardDeletionByBulk.
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
  final FocusNode _gpsPageFocusNode = .new();

  @override
  void dispose() 
  {
    _gpsPageFocusNode.dispose();
    super.dispose();
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
              NewProcessButton
              ( 
                dashboardContext: DashboardUtils.gpsContext, 
                buttonText: "Please click to start\na new group problem-solving session.",
                onNewProcessButtonPressedCAPageCallbackFunction: () {setState(() { _wasGPSSessionDataSaved = false;});},
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
                  onAllSessionFilesDeletedContextPageCallbackFunction: onAllSessionFilesDeleted,
                  // The GPS data is read-only 
                  onEditSessionDataCallbackFunction: ({required bool sessionDataEdition, required DTOCAForm dtoForEdition, required String fileNameWithoutExtension, required String title, required Set<String> keywordsForEdition}) {},                 
                  
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
                  focusNode: _gpsPageFocusNode,
                  child: GPSProcess(key: gpsProcessKey, parentCallbackFunctionToRefreshTheGPSPage: _onDataSaved),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
