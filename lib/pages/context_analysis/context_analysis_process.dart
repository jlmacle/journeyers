import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:gap/gap.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/1_context_analysis_title_declaration.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/2_context_analysis_keywords_declaration.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3_context_analysis_form.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart";
import "package:journeyers/utils/generic/dashboard/dashboard_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/generic/text_fields/text_field_utils.dart";
import "package:journeyers/utils/project_specific/global_keys/global_keys.dart";
import "package:journeyers/widgets/custom/text/custom_heading.dart";
import "package:journeyers/widgets/utility/process/session_file_name_on_desktop_platforms.dart";
import "package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart";

/// {@category Context analysis}
/// The process for the context analyses.

// Scrolling down the questions while tab navigating is an issue if the bottom bar items are not excluded from focus.
// When an expansion tile is expanded, the bottom bar items are excluded from focus.
// If the user reaches the "save data" button, the bottom bar items are restored as accessible to focus. 
// If the user tab navigates from the "save data" button toward the analysis title with a "shift+tab", the bottom bar items are excluded again from focus.
class CAProcess extends StatefulWidget 
{
  /// A boolean used to state if an edition is in progress.
  final bool isSessionDataBeingEdited;

  /// The title value at edition time.
  final String titleWhenEdition;

  /// The keywords value at edition time.
  final Set<String> keywordsWhenEdition;

  /// A DTOCAForm instance used at edition time.
  final DTOCAForm? dtoCAFormWhenEdition;

  /// The file name value (without extension) at edition time.
  final String fileNameWithoutExtensionWhenEdition;

  /// The file path at edition time.
  final String filePathWhenEdition;

  /// A callback function called to refresh the context analysis page after the process.
  final VoidCallback caPageCallbackFunctionToRefreshThePage;

  /// An "expansion tile folded/unfolded"-related callback function for the parent widget, to enhance the tab navigation.
  final ValueChanged<bool> caPageCallbackFunctionToSetFocusabilityOfBottomBarItems;

  const CAProcess({
    super.key,
    this.isSessionDataBeingEdited = false,
    this.titleWhenEdition = "",
    this.keywordsWhenEdition = const {},
    this.dtoCAFormWhenEdition,
    this.fileNameWithoutExtensionWhenEdition = "",
    this.filePathWhenEdition = "",
    required this.caPageCallbackFunctionToRefreshThePage,
    required this.caPageCallbackFunctionToSetFocusabilityOfBottomBarItems
    });

  @override
  State<CAProcess> createState() => CAProcessState();
}

class CAProcessState extends State<CAProcess> 
{
  // ─── DTO related data ───────────────────────────────────────
  // The DTO for the CA form
  DTOCAForm? _dtoCAForm;
  // Boolean to wait on the data loading
  bool _dtoAssetLoading = true;

  // Method used to load the DTO"s data using a json file
  Future<void> _loadDTO({required String dtoAssetPathToJson}) async 
  {
    // Loading from DTO
    if (dtoAssetPathToJson == "") 
    {
      // widget.dtoWhenEdition is nullable
      _dtoCAForm = widget.dtoCAFormWhenEdition ?? DTOCAForm();
      // To switch from circular indicator to process widgets
      setState(() {_dtoAssetLoading = false;});      
    }
    // Loading from Json
    else
    {
      // Getting a data map from a Json file (Todo: to keep or to clean)
      final jsonMap = await DTOCAForm.jsonDataMapFromAsset(dtoAssetPathToJson);
      setState(
        () 
        { 
          // Loading the DTO data from the data map
          _dtoCAForm = DTOCAForm.fromJson(jsonMap);
          // To switch from circular indicator to process widgets
          _dtoAssetLoading = false;
        }
      );
    }
    
  }

  // ─── TEXT FIELD related data, methods and text editing controllers ───────────────────────────────────────
  // Used in CAForm.
  // SESSION TITLE
  String analysisTitle = "";
  void _analysisTitleUpdate(String titleValue)
  {
    analysisTitle = titleValue;
    if (sessionDataDebug) pu.printd("Session Data: CAProcess: _analysisTitleUpdate: analysisTitle: $analysisTitle");
  }


  // KEYWORDS
  // Used in CAForm.
  Set<String> analysisKeywords = {};
  void _analysisKeywordsUpdate(Set<String> kws)
  {    
    analysisKeywords = kws;
    if (sessionDataDebug) pu.printd("Session Data: CAProcess: _analysisKeywordsUpdate: analysisKeywords: $analysisKeywords");
  }
  
  // FILE NAME
  // Used in CAForm.
  String analysisFileName = "";
  final String _fileExtension = TextFieldUtils.extensionCSV;

  void _analysisFileNameUpdate(String value)
  {   
    analysisFileName = value;
    if (sessionDataDebug) pu.printd("Session Data: CAProcess: _analysisFileNameUpdate: analysisFileName: $analysisFileName");
  }
  
  
  // Method used to print the form data to CSV
  Future<void> _saveDataAndMetadata() async
  {
    await formKeyCA.currentState?.saveDataAndMetadata();
  }

  // ─── FOCUS NODE related data and methods ───────────────────────────────────────
  // Focus nodes and data related to reaching nodes
  final FocusNode _saveDataButtonFocusNode = .new();
  bool _movingThroughButton = false;

  @override
  void dispose()
  {
    _saveDataButtonFocusNode.dispose();
    super.dispose();
  }
 
  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  bool _isApplicationFolderPathLoading = true;

  // method used to get the set preferences
  void _getApplicationFolderPath() async
  { 
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // necessary to have access to the newly set preference
    
    // Updating _isApplicationFolderPathLoading and re-build
    setState(() 
    {
      _isApplicationFolderPathLoading = false; 
    });
  }

  
  // ─── SCROLLCONTROLLER related data ───────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollbarThickness = 0;

  @override
  void didUpdateWidget(covariant CAProcess oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("CAProcess: didUpdateWidget");
  }
  
  @override
  void initState() {
    super.initState();

    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("CAProcess");
    
    // Retrieving the application folder
    _getApplicationFolderPath(); 

    // Todo: code to clean
    _loadDTO(dtoAssetPathToJson: "");
    //_loadDTO(dtoAssetPathToJson: "assets/caFormPreLoading/context_analysis_form_data_for_preloading.json");      
    analysisKeywords = widget.keywordsWhenEdition.toSet();
    if (editDebug) pu.printd("Editing: CAProcess: initState: analysisKeywords: $analysisKeywords");    
    
    // Listeners to know when some elements receive focus
    _saveDataButtonFocusNode.addListener(
      (){
        if (accessibilityDebug) pu.printd("Accessibility: Button used to save data reached");
        // restoring focus capability to the bottom items
        widget.caPageCallbackFunctionToSetFocusabilityOfBottomBarItems(true);
        // data helping to know if the user tab navigates back up
        _movingThroughButton = true;
      }
    );    
  }


  @override
  Widget build(BuildContext context) 
  {
    // TODO: to modify for tablets
    if (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)
    {_scrollbarThickness = 15;}

    return 
    _dtoAssetLoading
    // Circular indicator if asset is loading
    ? const CircularProgressIndicator()
    // else loading process widgets
    :
    Scrollbar
    (
      thumbVisibility: true, // to keep the scrollbar visible
      thickness: _scrollbarThickness,
      controller: _scrollController,
      child: 
      SingleChildScrollView
      (
        key: const Key("context-analysis-process-scrollview"),
        controller: _scrollController,
        child: 
        Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: 
          [
            // ─── Process widgets ───────────────────────────────────────
            const Center
            (
              child: 
              CustomHeading
              (
                headingText: "Context analysis",
                headingLevel: 1,
              ),
            ),

            // Text field for the analysis title
            CATitleDeclaration
            (
              key: const Key("ca-process-catitledeclaration-widget"),
              analysisTitleAutofocused: widget.isSessionDataBeingEdited,
              analysisTitleWhenEdition: widget.titleWhenEdition,
              onAnalysisTitleUpdatedProcessCallbackFunction: (value) => _analysisTitleUpdate(value)
            ),
            
            // Keywords
            CAKeywordsDeclaration
            (
              key: const Key("ca-process-cakeywordsdeclaration-widget"),
              keywordsWhenEdition: widget.keywordsWhenEdition,
              onKeywordsUpdatedProcessCallbackFunction: (values)=>_analysisKeywordsUpdate(values)
            ),
            
            const Gap(preAndPostLevel2DividerGap),
            const Divider(thickness: betweenLevel2DividerThickness),
            const Gap(preAndPostLevel2DividerGap),

            // CA Form 
            CAForm.fromDTO
            (
              key: formKeyCA,
              dtoCAForm: _dtoCAForm!,
              parentCallbackFunctionToRefreshTheCAPage: widget.caPageCallbackFunctionToRefreshThePage,
              parentCallbackFunctionToSetFocusabilityOfBottomBarItems: widget.caPageCallbackFunctionToSetFocusabilityOfBottomBarItems
            ),                        

            // ─── DATA SAVING ───────────────────────────────────────          
            Center
            (
              child: 
              Column
              (
                children: 
                [
                  // Button to start the data saving process
                  Focus(
                    // to detect a shift-tab navigation toward the questions
                    onKeyEvent: (FocusNode node, KeyEvent event)
                    {
                      if(event.logicalKey == LogicalKeyboardKey.tab
                          && HardwareKeyboard.instance.isShiftPressed)
                      {
                        if (accessibilityDebug) pu.printd("Accessibility: Shift-tab detected");
                        widget.caPageCallbackFunctionToSetFocusabilityOfBottomBarItems(false);
                        if (accessibilityDebug) pu.printd("Accessibility: _areBottomNavigationItemsFocusable: false");
                        return KeyEventResult.ignored;
                      }
                      else
                      {
                        widget.caPageCallbackFunctionToSetFocusabilityOfBottomBarItems(true);
                        if (accessibilityDebug) pu.printd("Accessibility: _areBottomNavigationItemsFocusable: true");
                      } 

                      return KeyEventResult.ignored;
                    },
                    child: 
                    _isApplicationFolderPathLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (Platform.isAndroid || Platform.isIOS) // Unified logic for mobile
                        // Defining file name and saving file for mobile platforms 
                        ? SessionFileNameOnMobilePlatforms
                        (
                          key: const Key("process-sessionfilenameonmobileplatforms-widget"),
                          isBlacklistingToBeOverridenTemporarily: widget.isSessionDataBeingEdited,
                          isExistentFileNamePreLoaded: widget.isSessionDataBeingEdited,
                          fileNameWithoutExtensionWhenEdition: widget.fileNameWithoutExtensionWhenEdition,
                          fileExtension: _fileExtension, 
                          onFileNameSubmittedProcessCallbackFunction: (value) => _analysisFileNameUpdate(value.trim()),
                          parentCallbackFunctionToSaveDataAndMetadata: _saveDataAndMetadata,
                          versatileParameter: widget.filePathWhenEdition,
                          textFieldContext: DashboardUtils.caContext,                         
                        )
                        // Saving file for desktop platforms
                        : SessionFileNameOnDesktopPlatforms(parentCallbackFunctionToSaveDataAndMetadata: _saveDataAndMetadata)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
