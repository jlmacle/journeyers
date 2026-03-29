import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gap/gap.dart';
import 'package:journeyers/widgets/utility/session_file_name_desktop_platforms.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/csv/csv_utils.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/dev/placeholder_functions.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/debug_constants.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/widgets/utility/session_file_name_mobile_platforms.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_title.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_keywords_declaration.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';

//**************** UTILITY CLASSES ****************//
CSVUtils cu = CSVUtils();
DashboardUtils du = DashboardUtils();
FormUtils fu = FormUtils();
PrintUtils pu = PrintUtils();
UserPreferencesUtils upu = UserPreferencesUtils();  

/// {@category Context analysis}
/// The process for the context analyses.

// Scrolling down the questions while tab navigating is an issue if the bottom bar items are not excluded from focus.
// When an expansion tile is expanded, the bottom bar items are excluded from focus.
// If the user reaches the "save data" button, the bottom bar items are restored as accessible to focus. 
// If the user tab navigates from the "save data" button toward the analysis title with a "shift+tab", the bottom bar items are excluded again from focus.
class ContextAnalysisProcess extends StatefulWidget 
{
  /// A callback function called after all session files have been deleted, and used to pass from dashboard to context analysis form.
  final VoidCallback parentCallbackFunctionToRefreshTheContextAnalysisPage;

  /// An "expansion tile expanded/folded"-related callback function for the parent widget, to enhance the tab navigation.
  final ValueChanged<bool> parentCallbackFunctionToSetFocusabilityOfBottomBarItems;

  const ContextAnalysisProcess({
    super.key,
    this.parentCallbackFunctionToRefreshTheContextAnalysisPage = placeHolderVoidCallback,
    this.parentCallbackFunctionToSetFocusabilityOfBottomBarItems = placeHolderFunctionBool
    });

  @override
  State<ContextAnalysisProcess> createState() => ContextAnalysisProcessState();
}

class ContextAnalysisProcessState extends State<ContextAnalysisProcess> 
{
  //**************** TEXT FIELD related data, methods and text editing controllers ****************//
  // SESSION TITLE
  String analysisTitle = "";
  void _analysisTitleUpdate(String titleValue)
  {
    analysisTitle = titleValue;
  }


  // KEYWORDS
  List<String> keywords = [];
  void keywordsUpdate(List<String> kws)
  {
    keywords = kws;
  }
  
  // FILE NAME
  String fileName = "";
  String fileExtension = ".csv";
  void analysisFileNameUpdate(String value)
  {
    fileName = value;
  }
  
  // Global key for the context form
  final GlobalKey<ContextAnalysisFormState> _contextFormKey = GlobalKey(debugLabel:'form');
  
  // Method used to print the form data to CSV
  Future<void> saveDataAndMetadata() async
  {
    await _contextFormKey.currentState?.saveDataAndMetadata();
  }

  //**************** FOCUS NODES related data and methods ****************//
  // Focus nodes and data related to reaching nodes
  final FocusNode _saveDataButtonFocusNode = FocusNode();
  bool movingThroughButton = false;

  @override
  void dispose()
  {
    _saveDataButtonFocusNode.dispose();
    super.dispose();
  }
 

  //**************** PREFERENCES related data and methods ****************/
  bool _isApplicationFolderPathLoading = true;

  // method used to get the set preferences
  void getApplicationFolderPathPref() async
  { 
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // necessary to have access to the newly set preference
    String? folderPathData = await upu.getApplicationFolderPath();
    if (Platform.isAndroid || Platform.isIOS)  
      {if (sessionDataDebug) pu.printd("Session Data: folderPathData: $folderPathData");}
    // Application folder path called from the Kotlin code    
    setState(() 
    {
      _isApplicationFolderPathLoading = false; 
    });
  }

  
  @override
  void initState() {
    super.initState();
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

  //**************** SCROLLCONTROLLER related data ****************//
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
        controller: scrollController,
        child: 
        Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: 
          [
            //*********** Form ***********//
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
            ContextAnalysisTitle(analysisTitleUpdatedCallbackFunction: _analysisTitleUpdate),
            
            // Keywords
            ContextAnalysisKeywordsDeclaration(keywordsUpdatedCallbackFunction: keywordsUpdate),
            
            const Gap(preAndPostLevel2DividerGap),
            const Divider(thickness: betweenLevel2DividerThickness),
            const Gap(preAndPostLevel2DividerGap),

            // Form 
            ContextAnalysisForm(
                        key: _contextFormKey,
                        contextAnalysisFormPageKey: widget.key as GlobalKey<ContextAnalysisProcessState>,
                        parentCallbackFunctionToRefreshTheContextAnalysisPage: widget.parentCallbackFunctionToRefreshTheContextAnalysisPage,
                        parentCallbackFunctionToSetFocusabilityOfBottomBarItems: widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems
                        ),                        
                        
            //********** Data saving ************//
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
