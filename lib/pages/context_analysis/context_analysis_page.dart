import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/l10n/app_localizations.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/widgets/utility/dashboard_page.dart';
import 'package:journeyers/widgets/utility/process_widgets/new_process_button.dart';


/// {@category Pages}
/// {@category Context analysis}
/// The root page for the context analysis sessions.
/// The context analysis page embeds a [DashboardPage] widget and/or a [CAProcess] widget.
class CAPage extends StatefulWidget 
{
  /// An "expansion tile folded/unfolded"-related callback function for the parent widget, to enhance the tab navigation.
  final ValueChanged<bool> homepageCallbackFunctionToSetFocusabilityOfBottomBarItems;

  const CAPage
  ({
    super.key,
    this.homepageCallbackFunctionToSetFocusabilityOfBottomBarItems = placeHolderFunctionBool
  });

  @override
  State<CAPage> createState() => CAPageState();
}

class CAPageState extends State<CAPage> 
{ 
  // ─── EDITION related data ───────────────────────────────────────
  // Values for the CA Form at edition time
  DTOCAForm? _dtoCAFormWhenEdition;
  // Value for the file name at edition time 
  String _fileNameWithoutExtensionWhenEdition = "";
  // Value for the title at edition time
  String _titleWhenEdition = "";
  // Values for the keywords at edition time
  Set<String> _keywordsWhenEdition = {};

  // if an edition is in progress
  bool _isSessionDataBeingEdited = false;

  // ─── RUNTIME DATA related data and methods ───────────────────────────────────────
  // if runtime data is being loaded
  bool _runtimeDataLoading = true;
  // if the modal was acknowledged at app first run 
  bool? _firstRunModalAcknowledged;
  // if context analysis data is stored 
  bool? _caSessionDataSaved;

  // Method used to get stored run-time data
  getRuntimeData() async 
  {
    if (runtimeDataDebug) pu.printd("Runtime Data: CAPAge: getRuntimeData()");

    _firstRunModalAcknowledged = await rtdu.wasFirstRunModalAcknowledged();
    _caSessionDataSaved = await rtdu.wasSessionDataSaved(context: DashboardUtils.caContext);
    setState(() {_runtimeDataLoading = false;});

    if (runtimeDataDebug) pu.printd("Runtime Data: CAPAge: _firstRunModalAcknowledged: $_firstRunModalAcknowledged");
    if (runtimeDataDebug) pu.printd("Runtime Data: CAPAge: _caSessionDataSaved: $_caSessionDataSaved");

    // IF FIRST-RUN MODAL NOT ACKNOWLEDGED:
    // (Modal displayed at app installation time)
    if ((_firstRunModalAcknowledged == false) && mounted) 
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
                  // Run-time data: modal acknowledged stored
                  await rtdu.saveFirstRunModalAcknowledgement(wasAcknowledged: true);

                  if (!context.mounted) return;
                  // Closing dialog
                  Navigator.pop(context);
                },
                child: 
                Padding
                (
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text
                  (
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

  // Used in DashboardDeletionByBulk.
  // Method used to refresh the page from dashboard to context analysis process, 
  // after all session files have been deleted
  void onAllSessionFilesDeleted() 
  {
    if (sessionDataDebug) pu.printd("Session Data: CAPage: onAllSessionFilesDeleted");

    setState(() {
      // to reset the display to CAProcess only
      _caSessionDataSaved = false;
    });
  }

  // Method used to refresh the page from context analysis process to dashboard, 
  // after process data has been saved
  void _onDataSaved() 
  {
    setState(() {
      // To have the dashboard displayed
      _caSessionDataSaved = true;
    });
  }

  // ─── METHODS USED TO EDIT SESSION DATA ───────────────────────────────────────

  // Method used to edit a session data
  void _onEditSessionData
  ({
    required bool isSessionDataBeingEdited, 
    required DTOCAForm? dtoCAFormWhenEdition, 
    required String fileNameWithoutExtensionWhenEdition, 
    required String titleWhenEdition, 
    required Set<String> keywordsWhenEdition
  })
  {
    if (editDebug) pu.printd("Editing: CAPage: onEditSessionData");

    setState(() {
      // To have the CAProcess widget loaded with the edited values
      _caSessionDataSaved = false;

      // Loading the CA Process with edited values
      _isSessionDataBeingEdited = isSessionDataBeingEdited;
      _dtoCAFormWhenEdition = dtoCAFormWhenEdition;      
      _titleWhenEdition  = titleWhenEdition;
      _keywordsWhenEdition = keywordsWhenEdition;
      _fileNameWithoutExtensionWhenEdition = fileNameWithoutExtensionWhenEdition;
    });
  }

  // ─── FOCUS NODE related data and methods ───────────────────────────────────────
  final FocusNode _caProcessFocusNode = .new();

  @override
  void dispose() 
  {
    _caProcessFocusNode.dispose();
    super.dispose();
  } 

  @override
  void didUpdateWidget(covariant CAPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    pu.printdLine();
    pu.printd("CAPage: didUpdateWidget");
  }

  @override
  void initState() 
  {
    super.initState();
    
    pu.printdLine();
    pu.printd("CAPage");
    
    getRuntimeData();
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
          // RUNTIME DATA LOADING: Circular progress indicator while runtime data is loading
          if (_runtimeDataLoading)
            const Center(child: CircularProgressIndicator())

          // OR RUNTIME DATA LOADED
          else ...
          [
            // CA DATA STORED: Checking if context analysis session data has been stored
            if (_caSessionDataSaved!) ...
            [
              // If so, a screen-wide rectangle, with an invite to start a new context analysis
              NewProcessButton
              ( 
                dashboardContext: DashboardUtils.caContext, 
                buttonText: "Please click to start\na new context analysis.",
                onNewProcessButtonPressedCAPageCallbackFunction: () {setState(() { _caSessionDataSaved = false;});},
              ),

              // and the session data dashboard in the remaining space
              Expanded
              (
                child: DashboardPage
                (
                  key: const Key('analyses-dashboard'), 
                  dashboardContext: DashboardUtils.caContext,
                  dashboardFilteringByKeywordsKey: dashboardFilteringByKeywordsKeyCA,
                  onAllSessionFilesDeletedContextPageCallbackFunction: onAllSessionFilesDeleted,
                  onEditSessionDataCallbackFunction: ({required isSessionDataBeingEdited, required dtoWhenEdition, required fileNameWhenEditionWithoutExtension, required titleWhenEdition, required keywordsWhenEdition}) 
                    => _onEditSessionData(isSessionDataBeingEdited: true, dtoCAFormWhenEdition: dtoWhenEdition, fileNameWithoutExtensionWhenEdition: fileNameWhenEditionWithoutExtension, titleWhenEdition: titleWhenEdition, keywordsWhenEdition: keywordsWhenEdition)
                
                )
              ),
            ]

            // OR CA DATA NOT STORED
            else
            // if no context analysis data has been stored, the context analysis process is displayed
            Expanded
            (
              child: 
              Padding
              (
                padding: const EdgeInsets.all(15.0),
                child: 
                Focus
                (
                  focusNode: _caProcessFocusNode,
                  child: CAProcess(key: caProcessKey, isSessionDataBeingEdited: _isSessionDataBeingEdited,  dtoWhenEdition: _dtoCAFormWhenEdition, fileNameWhenEditionWithoutExtension: _fileNameWithoutExtensionWhenEdition, titleWhenEdition: _titleWhenEdition , keywordsWhenEdition:  _keywordsWhenEdition , caPageCallbackFunctionToRefreshThePage: _onDataSaved, parentCallbackFunctionToSetFocusabilityOfBottomBarItems: widget.homepageCallbackFunctionToSetFocusabilityOfBottomBarItems),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
