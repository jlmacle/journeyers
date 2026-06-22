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
/// The context analysis page embeds a DashboardPage widget and/or a CAProcess widget.
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
  // The DTOCAForm value at initState
  DTOCAForm? _dtoOnInitState;
  // Value for the file name at edition time (without extension)
  String _fileNameWithoutExtension = "";
  // Value for the title at edition time
  String _title = "";
  // Value for the keywords at edition time
  Set<String> _keywordsForEdition = {};
  // bool: edition in progress
  bool _sessionDataEdition = false;

  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  bool _preferencesLoading = true;
  bool? _wasFirstRunModalAcknowledged;
  bool? _wasCASessionDataSaved;

  // Method used to get stored run-time data
  getRuntimeData() async 
  {
    if (runtimeDataDebug) pu.printd("CAPAge: getRuntimeData()");

    _wasFirstRunModalAcknowledged = await rtdu.wasFirstRunModalAcknowledged();
    _wasCASessionDataSaved = await rtdu.wasSessionDataSaved(context: DashboardUtils.caContext);
    setState(() {_preferencesLoading = false;});

    if (runtimeDataDebug) pu.printd("RuntimeData: _wasFirstRunModalAcknowledged: $_wasFirstRunModalAcknowledged");
    if (runtimeDataDebug) pu.printd("RuntimeData: _wasCASessionDataSaved: $_wasCASessionDataSaved");

    // First-run modal at app installation time
    if ((_wasFirstRunModalAcknowledged == false) && mounted) 
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
                  await rtdu.saveFirstRunModalAcknowledgement(wasAcknowledged: true);
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

  // Method used to refresh the page from dashboard to context form, 
  // after all session files have been deleted
  void onAllSessionFilesDeleted() 
  {
    if (sessionDataDebug) pu.printd("Session Data: CA page: onAllSessionFilesDeleted");

    setState(() {
      _wasCASessionDataSaved = false;
    });
  }

  // ─── METHODS USED TO REFRESH VIEWS ───────────────────────────────────────

  // Method used to refresh the page from context form to dashboard, 
  // after form data has been saved
  void _onDataSaved() 
  {
    setState(() {
      _wasCASessionDataSaved = true;
    });
  }

  // Method used to edit a session data
  void _onEditSessionData({required bool sessionDataEdition, required DTOCAForm dtoForEdition, required String fileNameWithoutExtension, required String title, required Set<String> keywordsForEdition})
  {
    if (editDebug) pu.printd("Editing: CAPage: onEditSessionData");

    setState(() {
      // To have the CAProcess widget loaded with the edited values
      _wasCASessionDataSaved = false;

      // Loading the CA Process with edited values
      _sessionDataEdition = sessionDataEdition;
      _dtoOnInitState = dtoForEdition;      
      _title  = title;
      _keywordsForEdition = keywordsForEdition;
      _fileNameWithoutExtension = fileNameWithoutExtension;
    });
  }

   // Method used to refresh the page
  void _onPageToRefresh()
  {
    setState(() {});
  }

  // ─── FOCUS NODE related data and methods ───────────────────────────────────────
  final FocusNode _caFormPageFocusNode = .new();

  @override
  void dispose() 
  {
    _caFormPageFocusNode.dispose();
    super.dispose();
  } 

  @override
  void initState() 
  {
    super.initState();
    getRuntimeData();
  }  

  @override
  Widget build(BuildContext context) 
  {
    if (editDebug) pu.printd("Editing: CAPage: _keywordsForEdition: $_keywordsForEdition");
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
              NewProcessButton
              ( 
                dashboardContext: DashboardUtils.caContext, 
                buttonText: "Please click to start\na new context analysis.",
                onNewProcessButtonPressedCAPageCallbackFunction: () {setState(() { _wasCASessionDataSaved = false;});},
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
                  onEditSessionDataCallbackFunction: ({required dtoForEdition, required fileNameWithoutExtension, required title, required keywordsForEdition, required sessionDataEdition}) => _onEditSessionData(sessionDataEdition: true, dtoForEdition: dtoForEdition, fileNameWithoutExtension: fileNameWithoutExtension, title: title, keywordsForEdition: keywordsForEdition),
                )
              ),
            ]
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
                  focusNode: _caFormPageFocusNode,
                  child: CAProcess(key: caProcessKey, sessionDataEdition: _sessionDataEdition,  dtoOnInitState: _dtoOnInitState, fileNameForEdition: _fileNameWithoutExtension, titleForEdition: _title , keywordsForEdition:  _keywordsForEdition , caPageCallbackFunctionToRefreshThePage: _onDataSaved, parentCallbackFunctionToSetFocusabilityOfBottomBarItems: widget.homepageCallbackFunctionToSetFocusabilityOfBottomBarItems),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
