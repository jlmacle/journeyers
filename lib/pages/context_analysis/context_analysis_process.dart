import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/placeholder_functions.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_keywords_declaration.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_title.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_ca_form.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';
import 'package:journeyers/widgets/utility/session_file_name_desktop_platforms.dart';
import 'package:journeyers/widgets/utility/session_file_name_mobile_platforms.dart';

/// {@category Context analysis}
/// The process for the context analyses.

// Scrolling down the questions while tab navigating is an issue if the bottom bar items are not excluded from focus.
// When an expansion tile is expanded, the bottom bar items are excluded from focus.
// If the user reaches the "save data" button, the bottom bar items are restored as accessible to focus. 
// If the user tab navigates from the "save data" button toward the analysis title with a "shift+tab", the bottom bar items are excluded again from focus.
class CAProcess extends StatefulWidget 
{
  /// A callback function called after all session files have been deleted, and used to pass from dashboard to context analysis form.
  final VoidCallback parentCallbackFunctionToRefreshTheCAPage;

  /// An "expansion tile expanded/folded"-related callback function for the parent widget, to enhance the tab navigation.
  final ValueChanged<bool> parentCallbackFunctionToSetFocusabilityOfBottomBarItems;

  const CAProcess({
    super.key,
    this.parentCallbackFunctionToRefreshTheCAPage = placeHolderVoidCallback,
    this.parentCallbackFunctionToSetFocusabilityOfBottomBarItems = placeHolderFunctionBool
    });

  @override
  State<CAProcess> createState() => CAProcessState();
}

class CAProcessState extends State<CAProcess> 
{
  // ─── TEXT FIELD related data, methods and text editing controllers ───────────────────────────────────────
  // SESSION TITLE
  String analysisTitle = "";
  void _analysisTitleUpdate(String titleValue)
  {
    analysisTitle = titleValue;
  }


  // KEYWORDS
  Set<String> keywords = {};
  void keywordsUpdate(Set<String> kws)
  {
    keywords = kws;
  }
  
  // FILE NAME
  String fileName = "";
  String fileExtension = TextFieldUtils.extensionCSV;
  void analysisFileNameUpdate(String value)
  {
    fileName = value;
  }
  
  
  // Method used to print the form data to CSV
  Future<void> saveDataAndMetadata() async
  {
    await formKeyCA.currentState?.saveDataAndMetadata();
  }

  // ─── FOCUS NODE related data and methods ───────────────────────────────────────
  // Focus nodes and data related to reaching nodes
  final FocusNode _saveDataButtonFocusNode = .new();
  bool movingThroughButton = false;

  @override
  void dispose()
  {
    _saveDataButtonFocusNode.dispose();
    super.dispose();
  }
 
  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  bool _isApplicationFolderPathLoading = true;

  // method used to get the set preferences
  void getApplicationFolderPathPref() async
  { 
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // necessary to have access to the newly set preference
    
    // Updating _isApplicationFolderPathLoading and re-build
    setState(() 
    {
      _isApplicationFolderPathLoading = false; 
    });
  }

  
  @override
  void initState() {
    super.initState();
    // Retrieving the application folder
    getApplicationFolderPathPref(); 

    // Listeners to know when some elements receive focus
    _saveDataButtonFocusNode.addListener(
      (){
        if (accessibilityDebug) pu.printd("Accessibility: Button used to save data reached");
        // restoring focus capability to the bottom items
        widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems(true);
        // data helping to know if the user tab navigates back up
        movingThroughButton = true;
      }
    );    
  }

  // ─── SCROLLCONTROLLER related data ───────────────────────────────────────
  final ScrollController scrollController = ScrollController();
    double scrollbarThickness = 0;

  @override
  Widget build(BuildContext context) 
  {
    // TODO: to modify for tablets
    if (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)
    {scrollbarThickness = 15;}

    return 
    Scrollbar
    (
      thumbVisibility: true, // to keep the scrollbar visible
      thickness: scrollbarThickness,
      controller: scrollController,
      child: 
      SingleChildScrollView
      (
        key: const Key('context-analysis-process-scrollview'),
        controller: scrollController,
        child: 
        Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: 
          [
            // ─── FORM ───────────────────────────────────────
            const Center
            (
              child: 
              CustomHeading
              (
                headingText: 'Context analysis',
                headingLevel: 1,
              ),
            ),

            // Text field for the analysis title
            CATitle(analysisTitleUpdatedCallbackFunction: _analysisTitleUpdate),
            
            // Keywords
            CAKeywordsDeclaration(keywordsUpdatedCallbackFunction: keywordsUpdate),
            
            const Gap(preAndPostLevel2DividerGap),
            const Divider(thickness: betweenLevel2DividerThickness),
            const Gap(preAndPostLevel2DividerGap),

            // CA Form 
            CAForm.fromDTO
            (
              key: formKeyCA,
              dtoCAForm: DTOCaForm(),
              parentCallbackFunctionToRefreshTheCAPage: widget.parentCallbackFunctionToRefreshTheCAPage,
              parentCallbackFunctionToSetFocusabilityOfBottomBarItems: widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems
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
                        widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems(false);
                        if (accessibilityDebug) pu.printd("Accessibility: _areBottomNavigationItemsFocusable: false");
                        return KeyEventResult.ignored;
                      }
                      else
                      {
                        widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems(true);
                        if (accessibilityDebug) pu.printd("Accessibility: _areBottomNavigationItemsFocusable: true");
                      } 

                      return KeyEventResult.ignored;
                    },
                    child: 
                    _isApplicationFolderPathLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (Platform.isAndroid || Platform.isIOS) // Unified logic for mobile
                        // Defining file name and saving file for mobile platforms 
                        ? SessionFileNameMobilePlatforms(fileExtension: fileExtension, fileNameSubmittedCallbackFunction: analysisFileNameUpdate, parentCallbackFunctionToSaveDataAndMetadata: saveDataAndMetadata)
                        // Saving file for desktop platforms
                        : SessionFileNameDesktopPlatforms(parentCallbackFunctionToSaveDataAndMetadata: saveDataAndMetadata)
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
