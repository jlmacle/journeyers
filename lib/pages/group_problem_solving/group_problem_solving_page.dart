import "package:flutter/material.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/dto_gps_form.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart";
import "package:journeyers/utils/generic/dashboard/dashboard_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/project_specific/global_keys/global_keys.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_page.dart";
import "package:journeyers/widgets/utility/process/new_process_button.dart";


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
  // ─── EDITION related data ───────────────────────────────────────
  // Value for the title at edition time
  String _titleWhenEdition = "";
  // Values for the keywords at edition time
  Set<String> _keywordsWhenEdition = {};
  // Values for the GPS Form at edition time
  DTOGPSForm? _dtoGPSFormWhenEdition;
  // Value for the file name (without extension) at edition time 
  String _fileNameWithoutExtensionWhenEdition = "";
  // Value for the file path at edition time
  String _filePathWhenEdition = "";

  // if an edition is in progress
  bool _isSessionDataBeingEdited = false;

  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  bool _runtimeDataLoading = true;
  bool? _gpsSessionDataSaved;

  _getRuntimeData() async 
  {
    if (runtimeDataDebug) pu.printd("Runtime Data: _getRuntimeData()");
    _gpsSessionDataSaved = await rtdu.wasSessionDataSaved(context: DashboardUtils.gpsContext);

    setState(() {_runtimeDataLoading = false;});
    if (runtimeDataDebug) pu.printd("Runtime Data: _gpsSessionDataSaved: $_gpsSessionDataSaved");
  }

  // ─── METHODS USED TO REFRESH VIEWS ───────────────────────────────────────

  // Method used to refresh the page from group problem-solving process page to dashboard, 
  // after process data has been saved
  void _gpsOnSessionDataSaved() 
  {
    setState(() {
      _gpsSessionDataSaved = true;
    });
  }

  // Used in DashboardDeletionByBulk.
  // Method used to refresh the page from dashboard to group problem-solving process page, 
  // after all session files have been deleted
  void gpsOnAllSessionsDataDeleted() 
  {
    if (sessionDataDebug) pu.printd("Session Data: GPS page: onAllSessionFilesDeleted");

    setState(() {
      _gpsSessionDataSaved = false;
    });
  }

  // ─── METHODS USED TO EDIT SESSION DATA ───────────────────────────────────────

  // Method used to edit a session data
  void _onEditSessionData
  ({
    required String dashboardContext,
    required bool isSessionDataBeingEdited, 
    required String titleWhenEdition, 
    required Set<String> keywordsWhenEdition,
    required DTOGPSForm? dtoGPSFormWhenEdition, 
    required String fileNameWithoutExtensionWhenEdition,
    required String filePathWhenEdition
  })
  {
    if (editDebug) pu.printd("Editing: GPSPage: onEditSessionData");

    setState(() {
      // To have the GPSProcess widget loaded with the values to edit
      _gpsSessionDataSaved = false;

      // Loading the GPSProcess with the values to edit
      _isSessionDataBeingEdited = isSessionDataBeingEdited;
      _titleWhenEdition  = titleWhenEdition;
      _keywordsWhenEdition = keywordsWhenEdition;
      _dtoGPSFormWhenEdition = dtoGPSFormWhenEdition;
      _fileNameWithoutExtensionWhenEdition = fileNameWithoutExtensionWhenEdition;
      _filePathWhenEdition = filePathWhenEdition;

      if (editDebug) pu.printd("Editing: GPSPage: _onEditSessionData: titleWhenEdition: $titleWhenEdition");
      if (editDebug) pu.printd("Editing: GPSPage: _onEditSessionData: keywordsWhenEdition: $keywordsWhenEdition");
      if (editDebug) pu.printd("Editing: GPSPage: _onEditSessionData: dtoGPSFormWhenEdition");
      dtoGPSFormWhenEdition!.printToConsole();
      if (editDebug) pu.printd("Editing: GPSPage: _onEditSessionData: fileNameWithoutExtensionWhenEdition: $fileNameWithoutExtensionWhenEdition");
      if (editDebug) pu.printd("Editing: GPSPage: _onEditSessionData: filePathWhenEdition: $filePathWhenEdition");
    });
  }
  
  // ─── FOCUS NODE related data and methods ───────────────────────────────────────
  final FocusNode _gpsProcessFocusNode = .new();

  @override
  void dispose() 
  {
    _gpsProcessFocusNode.dispose();
    super.dispose();
  } 

  @override
  void didUpdateWidget(covariant GPSPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSPage: didUpdateWidget");
  }

  @override
  void initState() 
  {
    super.initState();

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("GPSPage");
    
    _getRuntimeData();
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
          if (_runtimeDataLoading)
            const Center(child: CircularProgressIndicator())
          // When preferences are loaded
          else ...
          [
            // Checking if group problem-solving session data has been stored
            if (_gpsSessionDataSaved!) ...
            [
              // If so, a screen-wide rectangle, with an invite to start a new group problem-solving
              NewProcessButton
              ( 
                dashboardContext: DashboardUtils.gpsContext, 
                buttonText: "Please click to start\na new group problem-solving session.",
                onNewProcessButtonPressedCAPageCallbackFunction: 
                () 
                {
                  // Reset of edition-related data
                  _titleWhenEdition = "";
                  _keywordsWhenEdition = {};
                  _dtoGPSFormWhenEdition = DTOGPSForm();
                  _fileNameWithoutExtensionWhenEdition = "";
                  setState(() { _gpsSessionDataSaved = false;});
                  },
              ),
              
              // and the session data dashboard in the remaining space
              Expanded
              (
                child: 
                DashboardPage
                (
                  dashboardContext: DashboardUtils.gpsContext,
                  dashboardFilteringByKeywordsKey: dashboardFilteringByKeywordsKeyGPS,
                  onAllSessionFilesDeletedContextPageCallbackFunction: gpsOnAllSessionsDataDeleted,
                  // Code to clean
                  onRetrievedSessionDataBeforeEditionCallbackFunction: 
                  ({
                    required String dashboardContext,
                    required bool isSessionDataBeingEdited, 
                    required String titleWhenEdition, 
                    required Set<String> keywordsWhenEdition,
                    required Object dtoWhenEdition, 
                    required String fileNameWithoutExtensionWhenEdition,
                    required String filePathWhenEdition
                  }) 
                    => _onEditSessionData
                    (
                      dashboardContext: DashboardUtils.caContext,
                      isSessionDataBeingEdited: true, 
                      titleWhenEdition: titleWhenEdition, 
                      keywordsWhenEdition: keywordsWhenEdition,
                      dtoGPSFormWhenEdition: dtoWhenEdition as DTOGPSForm, 
                      fileNameWithoutExtensionWhenEdition: fileNameWithoutExtensionWhenEdition,
                      filePathWhenEdition: filePathWhenEdition
                    )                  
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
                  focusNode: _gpsProcessFocusNode,
                  child: GPSProcess
                  (
                    key: gpsProcessKey,
                    isSessionDataBeingEdited: _isSessionDataBeingEdited, 
                    titleWhenEdition: _titleWhenEdition, 
                    keywordsWhenEdition:  _keywordsWhenEdition, 
                    dtoGPSFormWhenEdition: _dtoGPSFormWhenEdition, 
                    fileNameWithoutExtensionWhenEdition: _fileNameWithoutExtensionWhenEdition, 
                    filePathWhenEdition: _filePathWhenEdition,
                    parentCallbackFunctionToRefreshTheGPSPage: _gpsOnSessionDataSaved
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
