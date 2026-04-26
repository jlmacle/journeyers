import 'dart:collection';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/_context_analysis_form_text_field_misc_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_custom_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_ca_form.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_custom_checkbox_with_text_field.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_custom_segmented_button_with_text_field.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/dev/utility_classes_import.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart' as tfu_proj; 
import 'package:journeyers/widgets/custom/text/custom_heading.dart';


/// {@category Context analysis}
/// Form used in the context analysis.
class CAForm extends StatefulWidget 
{
  /// The DTO object related to the form.
  final DTOCAForm dtoCAForm;

  /// Callback function used to refresh the page from the context form to the dashboard.
  final VoidCallback parentCallbackFunctionToRefreshTheCAPage;
  /// Callback function used to switch the focusability of the bottom bar items.
  final ValueChanged<bool> parentCallbackFunctionToSetFocusabilityOfBottomBarItems;

  const CAForm.fromDTO
  ({
    super.key,
    required this.dtoCAForm,
    required this.parentCallbackFunctionToRefreshTheCAPage,
    required this.parentCallbackFunctionToSetFocusabilityOfBottomBarItems
  });

  @override
  State<CAForm> createState() => CAFormState();
}

class CAFormState extends State<CAForm> 
{

  // ─── ACCESSIBILITY related data ───────────────────────────────────────
  // Data related to the folding/unfolding of the expansion tiles
  bool _isIndividualAreaPerspectiveExpanded = false;
  bool _isGroupAreaPerspectiveExpanded = false;

  // ─── SESSION METADATA ───────────────────────────────────────
  // Placeholder data for what is entered in addition to the form data
  String _fileName = "";
  Set<String> _keywords = {};
  String _analysisTitle = "";  

  // Method used to update a DTOCheckboxWithTextField text 
  Future<void> _onDTOCheckboxWithTextFieldTextUpdate(DTOCheckboxWithTextField data, String text) async 
  => data.text = text;

  // Method used to update a DTOSegmentedButtonWithTextField text 
  Future<void> _onDTOSegmentedButtonWithTextFieldTextUpdate(DTOSegmentedButtonWithTextField data, String text) async 
  => data.text = text;
  
  // ─── Methods related to updating DTO and item/heading styling ──────────────────────────────────────────────────
  // Method used to update the DTO, and the item and heading styling (balance issue)
  Future<void> _onBalanceItemChecked(DTOCheckboxWithTextField data, bool? value) async
  {
    data.checked = value!;
    balanceIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfCheckboxChecked();
  }

  // Method used to update the DTO, and the item and heading styling (workplace issue)
  Future<void> _onWorkplaceItemChecked(DTOCheckboxWithTextField data, bool? value) async
  {
    data.checked = value!;
    workplaceIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfCheckboxChecked();
  }

  // Method used to update the DTO, and the item and heading styling (legacy issue)
  Future<void> _onLegacyItemChecked(DTOCheckboxWithTextField data, bool? value) async 
  {
    data.checked = value!;
    legacyIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfCheckboxChecked();
  }

  // Method used to update the DTO (segmented buttons)
  Future<void> _onSegmentedButtonSelection(DTOSegmentedButtonWithTextField data, Set<String>? values) async
   => data.selection = values ?? {};

  // Method used to update the DTO, and the item styling (another issue)
  Future<void> _onAnotherIssueFilledStr(String value) async 
  {
    widget.dtoCAForm.indivAnotherIssueStr = value;
    anotherIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfTextFieldUsed(value);
  }

  // Method used to update the DTO ( group problems to solve)
  Future<void> _onGroupProblemsToSolveFilledStr(String value) async 
  {
    widget.dtoCAForm.groupProblemsToSolveStr = value;
  }
  
  // Method used to store the form data to CSV, and the session metadata in a file
  Future<void> saveDataAndMetadata() async 
  { 
    // Updating analysis title, keywords, and file name
    _analysisTitle = caProcessKey.currentState!.analysisTitle.trim() == "" 
                      ? "Untitled" : caProcessKey.currentState!.analysisTitle.trim();
    _keywords = caProcessKey.currentState!.keywords;
    _fileName = caProcessKey.currentState!.fileName;

    // Building the data structure
    final LinkedHashMap<String, Object> enteredData = await widget.dtoCAForm.dataStructureBuilding();

    // TODO:  logic to move to the DTO
    // Transforming the data into a CSV-friendly form
    List<List<String>> preCSVDataIndividualPerspective = await widget.dtoCAForm.dataToPreCSV(perspectiveData: enteredData["individualPerspective"] as LinkedHashMap<String, Object>);
    List<List<String>> preCSVDataGroupPerspective = await widget.dtoCAForm.dataToPreCSV(perspectiveData: enteredData["groupPerspective"] as LinkedHashMap<String, Object>);

    if (csvBuildingDebug) pu.printd("CSV Building: preCSVDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building: $preCSVDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");
    if (csvBuildingDebug) pu.printd("CSV Building: preCSVDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building: $preCSVDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");

    List<List<String>> csvDataIndividualPerspective = await widget.dtoCAForm.preCSVToCSVData(preCSVData: preCSVDataIndividualPerspective);
    List<List<String>> csvDataGroupPerspective = await widget.dtoCAForm.preCSVToCSVData(preCSVData: preCSVDataGroupPerspective);
    // Printing to CSV
    String? pathToCSVFile = 
      await widget.dtoCAForm.printToCSV(csvDataIndividualPerspective: csvDataIndividualPerspective, 
                          csvDataGroupPerspective: csvDataGroupPerspective,
                          fileName: _fileName);
    // Updating the file names list: after printToCSV
    if(Platform.isAndroid || Platform.isIOS) 
    {
      await du.getStoredFileNamesOnMobile();
      if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames: (after retrieval) ${du.currentListOfStoredFileNames}");
      if (sessionDataDebug) pu.printd("Session Data: pathToCSVFile: $pathToCSVFile");
    }
    
    // Saving the dashboard metadata if filePath not null
    if (pathToCSVFile != null)
    { 
      // Date
      var now = DateTime.now();
      //.add_jm() to add this hour:minutes format: 5:08 PM
      var formatter = DateFormat('MMMM dd, yyyy').add_jm();
      var formattedDate = formatter.format(now);   
      await du.saveDashboardMetadata
      (typeOfDashboardContext: DashboardUtils.caContext, title: _analysisTitle, 
      keywords: _keywords.toList(), formattedDate: formattedDate, pathToFile: pathToCSVFile);
      await upu.saveWasSessionDataSaved(wasDataSaved: true, context: DashboardUtils.caContext);
    }
    
    // Page refreshing for dashboard display
    widget.parentCallbackFunctionToRefreshTheCAPage();
  }

  
  @override
  Widget build(BuildContext context) {
    return Column
    (
      children: 
      [
        // ─── EXPANSION TILE DIPLAYING THE INDIVIDUAL PERSPECTIVE: beginning ───────────────────────────────────────
        Semantics
        (
          toggled: false, // seems necessary (as of 26/01/11) to have 'button' voiced on Android
          button: true, // with tooltip, useful for NVDA
          // tooltip: "Zone to click to expand data", // both label and tooltip were voiced with Narrator
          label: "Zone to click to expand data", // for Orca
          expanded: _isIndividualAreaPerspectiveExpanded, // useful for NVDA, not voiced by Narrator at the time of coding (26/01/11)
          child:
          ExpansionTile
          ( 
            tilePadding: const EdgeInsets.only(top:0),
            expandedCrossAxisAlignment: CrossAxisAlignment.center,
            internalAddSemanticForOnTap: true, 
            onExpansionChanged: (value) 
            {
              setState(() {_isIndividualAreaPerspectiveExpanded = value;});
              widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems(!(_isIndividualAreaPerspectiveExpanded || _isGroupAreaPerspectiveExpanded));
              },
            // on Windows, for Narrator: was necessary (as of 26/01/11) to have 'button' voiced after the title was voiced
            maintainState: true, // to keep the state of the children widget
            title:             
            CustomHeading
            (
              headingText: qf.level2TitleIndividual,
              headingLevel: 2,
            ),
            children: <Widget>
            [
              /**** ➡️ Sub-point  ****/
              // Balance issue questions
              CustomHeading
              (
                key: balanceIssueHeadingKey,
                headingText: qf.level3TitleBalanceIssue,
                headingLevel: 3,
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: qf.level3TitleBalanceIssueItem1,
                // Initializing the checkbox value with the DTO's value
                checkboxStartValue:  widget.dtoCAForm.indivBalanceStudiesHousehold.checked,
                // Initializing the text field value with the DTO's value
                textFieldStartValue: widget.dtoCAForm.indivBalanceStudiesHousehold.text,
                textFieldHint: pleaseDescribeTextHouseholdHint,
                // Updating DTO and UI (heading and item styling)
                onCheckboxValueChanged: (v) async => await _onBalanceItemChecked(widget.dtoCAForm.indivBalanceStudiesHousehold, v),
                // Updating DTO
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldTextUpdate(widget.dtoCAForm.indivBalanceStudiesHousehold, v),
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: qf.level3TitleBalanceIssueItem2,
                checkboxStartValue: widget.dtoCAForm.indivBalanceAccessingIncomeHousehold.checked,
                textFieldStartValue: widget.dtoCAForm.indivBalanceAccessingIncomeHousehold.text,
                textFieldHint: pleaseDescribeTextHouseholdHint,
                onCheckboxValueChanged: (v) async => await _onBalanceItemChecked(widget.dtoCAForm.indivBalanceAccessingIncomeHousehold, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldTextUpdate(widget.dtoCAForm.indivBalanceAccessingIncomeHousehold, v),
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: qf.level3TitleBalanceIssueItem3,
                checkboxStartValue: widget.dtoCAForm.indivBalanceEarningIncomeHousehold.checked,
                textFieldStartValue: widget.dtoCAForm.indivBalanceEarningIncomeHousehold.text,
                textFieldHint: pleaseDescribeTextHouseholdHint,
                onCheckboxValueChanged: (v) async => await _onBalanceItemChecked(widget.dtoCAForm.indivBalanceEarningIncomeHousehold, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldTextUpdate(widget.dtoCAForm.indivBalanceEarningIncomeHousehold, v),
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: qf.level3TitleBalanceIssueItem4,
                checkboxStartValue: widget.dtoCAForm.indivBalanceHelpingOthersHouseholds.checked,
                textFieldStartValue: widget.dtoCAForm.indivBalanceHelpingOthersHouseholds.text,
                textFieldHint: pleaseDescribeTextHouseholdHint,
                onCheckboxValueChanged: (v) async => await _onBalanceItemChecked(widget.dtoCAForm.indivBalanceHelpingOthersHouseholds, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldTextUpdate(widget.dtoCAForm.indivBalanceHelpingOthersHouseholds, v),
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Workplace issue questions
              CustomHeading
              (
                key: workplaceIssueHeadingKey,
                headingText: qf.level3TitleWorkplaceIssue,
                headingLevel: 3,
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: qf.level3TitleWorkplaceIssueItem1,
                checkboxStartValue: widget.dtoCAForm.indivAtWorkMoreAppreciated.checked,
                textFieldStartValue: widget.dtoCAForm.indivAtWorkMoreAppreciated.text,
                textFieldHint: pleaseDescribeTextWorkplaceHint,
                onCheckboxValueChanged: (v) async  => await _onWorkplaceItemChecked(widget.dtoCAForm.indivAtWorkMoreAppreciated, v),
                onTextFieldValueSubmittedCallbackFunction:  (v) async => await _onDTOCheckboxWithTextFieldTextUpdate(widget.dtoCAForm.indivAtWorkMoreAppreciated , v),
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: qf.level3TitleWorkplaceIssueItem2,
                checkboxStartValue: widget.dtoCAForm.indivAtWorkRemainingAppreciated.checked,
                textFieldStartValue: widget.dtoCAForm.indivAtWorkRemainingAppreciated.text,
                textFieldHint: pleaseDescribeTextWorkplaceHint,
                onCheckboxValueChanged: (v) async => await _onWorkplaceItemChecked(widget.dtoCAForm.indivAtWorkRemainingAppreciated, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldTextUpdate(widget.dtoCAForm.indivAtWorkRemainingAppreciated, v),
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Legacy issue question
              CustomHeading
              (
                key: legacyIssueHeadingKey,
                headingText: qf.level3TitleLegacyIssue,
                headingLevel: 3,
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: qf.level3TitleLegacyIssueItem1,
                checkboxStartValue: widget.dtoCAForm.indivBetterLegacies.checked,
                textFieldStartValue: widget.dtoCAForm.indivBetterLegacies.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                onCheckboxValueChanged: (v) async => await _onLegacyItemChecked(widget.dtoCAForm.indivBetterLegacies, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldTextUpdate(widget.dtoCAForm.indivBetterLegacies, v),
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Another issue question
              CustomHeading
              (
                key: anotherIssueHeadingKey,
                headingText: qf.level3TitleAnotherIssue,
                headingLevel: 3,
                ),
              CATextFieldSanitizedAndPadded
              (
                stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldstringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
                textFieldStyle: analysisTextFieldStyle,
                textFieldStartValue:widget.dtoCAForm.indivAnotherIssueStr,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                textFieldHintStyle: analysisTextFieldHintStyle,
                errorMessageStyle: analysisTextFieldErrorMessageStyle,
                textFieldMaxLength: CAFormTextFieldMiscConstants.chars1Page,
                textFieldCounter: TextFieldUtils.absentCounter,
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onAnotherIssueFilledStr(v), 
              ),
            ]
          ),
        ),
        // ─── EXPANSION TILE DIPLAYING THE INDIVIDUAL PERSPECTIVE: end ───────────────────────────────────────

        const Gap(preAndPostLevel2DividerGap),
        const Divider(thickness: betweenLevel2DividerThickness),
        const Gap(preAndPostLevel2DividerGap),


        // ─── BEGINNING OF THE TEAM-RELATED ANALYSIS ───────────────────────────────────────
        // ─── EXPANSION TILE DIPLAYING THE GROUP PERSPECTIVE : beginning ───────────────────────────────────────
        Semantics
        ( 
          toggled: false, // seems necessary (as of 26/01/11) to have 'button' voiced on Android
          button: true, // with tooltip, useful for NVDA
          // tooltip: "Zone to click to expand data", // both label and tooltip were voiced with Narrator
          label: "Zone to click to expand data", // for Orca
          expanded: _isGroupAreaPerspectiveExpanded, // useful for NVDA, not voiced by Narrator at the time of coding (26/01/11)
          child:
          ExpansionTile
          ( 
            expandedCrossAxisAlignment: CrossAxisAlignment.center,
            expandedAlignment: Alignment.center,
            internalAddSemanticForOnTap: true, 
            onExpansionChanged: (value) 
            {setState(() 
            {
              _isGroupAreaPerspectiveExpanded = value;
              widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems(!(_isIndividualAreaPerspectiveExpanded || _isGroupAreaPerspectiveExpanded));
            });
            },
            // on Windows, for Narrator: was necessary (as of 26/01/11) to have 'button' voiced after the title was voiced
            maintainState: true, // to keep the state of the children widget
            title:              
            CustomHeading
            (
              headingText: qf.level2TitleGroup,
              headingLevel: 2,
            ),
            children: <Widget>
            [
              /**** ➡️ Sub-point  ****/
              // Question about the group problems
              CustomHeading
              (
                headingText: qf.level3TitleGroupsProblematics,
                headingLevel: 3,
              ),
              CATextFieldSanitizedAndPadded
              (
                textFieldStartValue: widget.dtoCAForm.groupProblemsToSolveStr,
                textFieldHint: pleaseDescribeTextGroupsHint,
                stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldstringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
                textFieldStyle: analysisTextFieldStyle,
                textFieldHintStyle: analysisTextFieldHintStyle,
                errorMessageStyle: analysisTextFieldErrorMessageStyle,
                textFieldMaxLength: CAFormTextFieldMiscConstants.chars1Page,
                textFieldCounter: TextFieldUtils.absentCounter,
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onGroupProblemsToSolveFilledStr(v),
              ),

              /**** ➡️ Sub-point  ****/
              // Question about the same problems
              CustomHeading
              (
                headingText: qf.level3TitleSameProblem,
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              CASegmentedButtonWithSanitizedAndPaddedTextField
              (
                segButtonTextOption1: 'Yes',
                segButtonTextOption2: 'No',
                segButtonTextOption3: "I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: widget.dtoCAForm.groupSameProblemsToSolve.selection,
                textFieldStartValue: widget.dtoCAForm.groupSameProblemsToSolve.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                parentSegmentedButtonValueCallBackFunction: (v) async => await _onSegmentedButtonSelection(widget.dtoCAForm.groupSameProblemsToSolve, v),
                parentTextFieldValueCallBackFunction: (v) async => await _onDTOSegmentedButtonWithTextFieldTextUpdate(widget.dtoCAForm.groupSameProblemsToSolve, v),
              ),

              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about harmony at home
              CustomHeading
              (
                headingText: qf.level3TitleHarmonyAtHome,
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              CASegmentedButtonWithSanitizedAndPaddedTextField
              (
                segButtonTextOption1: 'Yes',
                segButtonTextOption2: 'No',
                segButtonTextOption3: "I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: widget.dtoCAForm.groupHarmonyHome.selection,
                textFieldStartValue: widget.dtoCAForm.groupHarmonyHome.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                parentSegmentedButtonValueCallBackFunction: (v) async => await _onSegmentedButtonSelection(widget.dtoCAForm.groupHarmonyHome, v),
                parentTextFieldValueCallBackFunction: (v) async => await _onDTOSegmentedButtonWithTextFieldTextUpdate(widget.dtoCAForm.groupHarmonyHome, v),
              ),

              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about appreciability at work
              CustomHeading
              (
                headingText: qf.level3TitleAppreciabilityAtWork,
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              CASegmentedButtonWithSanitizedAndPaddedTextField
              (
                segButtonTextOption1: 'Yes',
                segButtonTextOption2: 'No',
                segButtonTextOption3: "I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: widget.dtoCAForm.groupAppreciabilityAtWork.selection,
                textFieldStartValue: widget.dtoCAForm.groupAppreciabilityAtWork.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                parentSegmentedButtonValueCallBackFunction: (v) async => await _onSegmentedButtonSelection(widget.dtoCAForm.groupAppreciabilityAtWork, v),
                parentTextFieldValueCallBackFunction: (v) async => await _onDTOSegmentedButtonWithTextFieldTextUpdate(widget.dtoCAForm.groupAppreciabilityAtWork, v),
              ),
              
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about the earning ability
              CustomHeading
              (
                headingText: qf.level3TitleIncomeEarningAbility,
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              CASegmentedButtonWithSanitizedAndPaddedTextField
              (
                segButtonTextOption1: 'Yes',
                segButtonTextOption2: 'No',
                segButtonTextOption3: "I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: widget.dtoCAForm.groupEarningAbility.selection,
                textFieldStartValue: widget.dtoCAForm.groupEarningAbility.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                parentSegmentedButtonValueCallBackFunction: (v) async => await _onSegmentedButtonSelection(widget.dtoCAForm.groupEarningAbility, v),
                parentTextFieldValueCallBackFunction: (v) async => await _onDTOSegmentedButtonWithTextFieldTextUpdate(widget.dtoCAForm.groupEarningAbility, v),
              ),
            ]
          ),
        ),
        // ─── EXPANSION TILE DIPLAYING THE GROUP PERSPECTIVE: end ───────────────────────────────────────

        const Gap(preAndPostLevel2DividerGap),
        const Divider(thickness: betweenLevel2DividerThickness),
        const Gap(preAndPostLevel2DividerGap),
     ],
    );
  }
}