import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_const_strings_and_ints.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_questions.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_ca_form.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_custom_checkbox_with_text_field.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_custom_segmented_button_with_text_field.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart' as tfu_proj; 
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_checkbox_with_text_field.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_sanitized_and_padded_for_context_analysis.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_segmented_button_with_text_field.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';


/// {@category Context analysis}
/// Form used in the context analysis.
class CAForm extends StatefulWidget 
{
  /// The DTO object related to the form.
  final DTOCaForm dtoCAForm;

  /// Callback function used to refresh the page from the context form to the dashboard
  final VoidCallback parentCallbackFunctionToRefreshTheCAPage;
  /// Callback function used to switch the focusability of the bottom bar items
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
  final CAFormQuestions q = CAFormQuestions();

  // ─── ACCESSIBILITY related data ───────────────────────────────────────
  // Data related to the folding/unfolding of the expansion tiles
  bool _isIndividualAreaPerspectiveExpanded = false;
  bool _isGroupAreaPerspectiveExpanded = false;

  // ─── SESSION METADATA ───────────────────────────────────────
  // Placeholder data for what is entered in addition to the form data
  String _fileName = "";
  Set<String> _keywords = {};
  String _analysisTitle = "";  

  // ─── Methods related to updating DTO and item/heading styling ──────────────────────────────────────────────────
  // Method used to update the DTO, and the item and heading styling (balance issue)
  void _onBalanceItemChecked(DTOCheckboxWithTextField data, bool? value) {
    data.checked = value!;
    balanceIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfCheckboxChecked();
  }

  // Method used to update the DTO, and the item and heading styling (workplace issue)
  void _onWorkplaceItemChecked(DTOCheckboxWithTextField data, bool? value) {
    data.checked = value!;
    workplaceIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfCheckboxChecked();
  }

  // Method used to update the DTO, and the item and heading styling (legacy issue)
    void _onLegacyItemChecked(DTOCheckboxWithTextField data, bool? value) {
    data.checked = value!;
    legacyIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfCheckboxChecked();
  }

  // Method used to update the DTO, and the item styling (another issue)
  void _onAnotherIssueStr(String value) {
    widget.dtoCAForm.indivAnotherIssueStr = value;
    anotherIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfTextFieldUsed(value);
  }

  // Method used to update the DTO (segmented buttons)
  void _onSegmentedButtonSelection(DTOSegmentedButtonWithTextField data, Set<String>? values) =>
    data.selection = values ?? {};
  
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
    List<List<String>> preCSVDataIndividualPerspective = await csvu.dataToPreCSV(perspectiveData: enteredData["individualPerspective"] as LinkedHashMap<String, Object>);
    List<List<String>> preCSVDataGroupPerspective = await csvu.dataToPreCSV(perspectiveData: enteredData["groupPerspective"] as LinkedHashMap<String, Object>);

    if (csvBuildingDebug) pu.printd("CSV Building: preCSVDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building: $preCSVDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");
    if (csvBuildingDebug) pu.printd("CSV Building: preCSVDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building: $preCSVDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");

    List<List<String>> csvDataIndividualPerspective = await csvu.preCSVToCSVData(preCSVData: preCSVDataIndividualPerspective);
    List<List<String>> csvDataGroupPerspective = await csvu.preCSVToCSVData(preCSVData: preCSVDataGroupPerspective);
    // Printing to CSV
    String? pathToCSVFile = 
      await csvu.printToCSV(csvDataIndividualPerspective: csvDataIndividualPerspective, 
                          csvDataGroupPerspective: csvDataGroupPerspective,
                          fileName: _fileName);
    // Updating the file names list: after printToCSV
    await du.getStoredFileNamesOnMobile();
    if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames: (after retrieval) ${du.currentListOfStoredFileNames}");
    if (sessionDataDebug) pu.printd("Session Data: pathToCSVFile: $pathToCSVFile");

    // Saving the dashboard metadata if filePath not null
    if (pathToCSVFile != null)
    { 
      // Date
      var now = DateTime.now();
      //.add_jm() to add this hour:minutes format: 5:08 PM
      var formatter = DateFormat('MMMM dd, yyyy').add_jm();
      var formattedDate = formatter.format(now);   
      await du.saveDashboardMetadata
      (typeOfContextData: DashboardUtils.caContext, title: _analysisTitle, 
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
              headingText: q.level2TitleIndividual,
              headingLevel: 2,
            ),
            children: <Widget>
            [
              /**** ➡️ Sub-point  ****/
              // Balance issue questions
              CustomHeading
              (
                key: balanceIssueHeadingKey,
                headingText: q.level3TitleBalanceIssue,
                headingLevel: 3,
              ),
              CheckboxWithTextField
              (
                checkboxText: q.level3TitleBalanceIssueItem1,
                // Initializing the checkbox value with the DTO's value
                checkboxIsChecked: widget.dtoCAForm.indivStudiesBalance.checked,
                // Initializing the text field value with the DTO's value
                textFieldStartValue: widget.dtoCAForm.indivStudiesBalance.text,
                textFieldHint: pleaseDescribeTextHouseholdHint,
                // Updating DTO and UI (heading and item styling)
                onCheckboxValueChanged: (v) => _onBalanceItemChecked(widget.dtoCAForm.indivStudiesBalance, v),
                // Updating DTO
                onTextFieldValueSubmittedCallbackFunction: (v) {widget.dtoCAForm.indivStudiesBalance.text = v;},
              ),
              CheckboxWithTextField
              (
                checkboxText: q.level3TitleBalanceIssueItem2,
                checkboxIsChecked: widget.dtoCAForm.indivAccessingIncomeBalance.checked,
                textFieldStartValue: widget.dtoCAForm.indivAccessingIncomeBalance.text,
                textFieldHint: pleaseDescribeTextHouseholdHint,
                onCheckboxValueChanged: (v) => _onBalanceItemChecked(widget.dtoCAForm.indivAccessingIncomeBalance, v),
                onTextFieldValueSubmittedCallbackFunction: (v) {widget.dtoCAForm.indivAccessingIncomeBalance.text = v;},
              ),
              CheckboxWithTextField
              (
                checkboxText: q.level3TitleBalanceIssueItem3,
                checkboxIsChecked: widget.dtoCAForm.indivEarningIncomeBalance.checked,
                textFieldStartValue: widget.dtoCAForm.indivEarningIncomeBalance.text,
                textFieldHint: pleaseDescribeTextHouseholdHint,
                onCheckboxValueChanged: (v) => _onBalanceItemChecked(widget.dtoCAForm.indivEarningIncomeBalance, v),
                onTextFieldValueSubmittedCallbackFunction: (v) {widget.dtoCAForm.indivEarningIncomeBalance.text = v;},
              ),
              CheckboxWithTextField
              (
                checkboxText: q.level3TitleBalanceIssueItem4,
                checkboxIsChecked: widget.dtoCAForm.indivHelpingOthersBalance.checked,
                textFieldStartValue: widget.dtoCAForm.indivHelpingOthersBalance.text,
                textFieldHint: pleaseDescribeTextHouseholdHint,
                onCheckboxValueChanged: (v) => _onBalanceItemChecked(widget.dtoCAForm.indivHelpingOthersBalance, v),
                onTextFieldValueSubmittedCallbackFunction: (v) {widget.dtoCAForm.indivHelpingOthersBalance.text = v;},
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Workplace issue questions
              CustomHeading
              (
                key: workplaceIssueHeadingKey,
                headingText: q.level3TitleWorkplaceIssue,
                headingLevel: 3,
              ),
              CheckboxWithTextField
              (
                checkboxText: q.level3TitleWorkplaceIssueItem1,
                checkboxIsChecked: widget.dtoCAForm.indivMoreAppreciatedAtWork.checked,
                textFieldStartValue: widget.dtoCAForm.indivMoreAppreciatedAtWork.text,
                textFieldHint: pleaseDescribeTextWorkplaceHint,
                onCheckboxValueChanged: (v) => _onWorkplaceItemChecked(widget.dtoCAForm.indivMoreAppreciatedAtWork, v),
                onTextFieldValueSubmittedCallbackFunction: (v) {widget.dtoCAForm.indivMoreAppreciatedAtWork.text = v;},
              ),
              CheckboxWithTextField
              (
                checkboxText: q.level3TitleWorkplaceIssueItem2,
                checkboxIsChecked: widget.dtoCAForm.indivRemainingAppreciatedAtWork.checked,
                textFieldStartValue: widget.dtoCAForm.indivRemainingAppreciatedAtWork.text,
                textFieldHint: pleaseDescribeTextWorkplaceHint,
                onCheckboxValueChanged: (v) => _onWorkplaceItemChecked(widget.dtoCAForm.indivRemainingAppreciatedAtWork, v),
                onTextFieldValueSubmittedCallbackFunction: (v) {widget.dtoCAForm.indivRemainingAppreciatedAtWork.text = v;},
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Legacy issue question
              CustomHeading
              (
                key: legacyIssueHeadingKey,
                headingText: q.level3TitleLegacyIssue,
                headingLevel: 3,
              ),
              CheckboxWithTextField
              (
                checkboxText: q.level3TitleLegacyIssueItem1,
                checkboxIsChecked: widget.dtoCAForm.indivBetterLegacies.checked,
                textFieldStartValue: widget.dtoCAForm.indivBetterLegacies.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                onCheckboxValueChanged: (v) => _onLegacyItemChecked(widget.dtoCAForm.indivBetterLegacies, v),
                onTextFieldValueSubmittedCallbackFunction: (v) {widget.dtoCAForm.indivBetterLegacies.text = v;},
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Another issue question
              CustomHeading
              (
                key: anotherIssueHeadingKey,
                headingText: q.level3TitleAnotherIssue,
                headingLevel: 3,
                ),
              TextFieldSanitizedAndPaddedForCA
              (
                stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldUtils.stringSanitizerBundlesErrorsMappingForCA,
                textFieldStyle: analysisTextFieldStyle,
                textFieldStartValue:widget.dtoCAForm.indivAnotherIssueStr,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                textFieldHintStyle: analysisTextFieldHintStyle,
                errorMessageStyle: analysisTextFieldErrorMessageStyle,
                textFieldMaxLength: chars1Page,
                textFieldCounter: TextFieldUtils.absentCounter,
                onTextFieldValueSubmittedCallbackFunction: _onAnotherIssueStr, 
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
              headingText: q.level2TitleGroup,
              headingLevel: 2,
            ),
            children: <Widget>
            [
              /**** ➡️ Sub-point  ****/
              // Question about the group problems
              CustomHeading
              (
                headingText: q.level3TitleGroupsProblematics,
                headingLevel: 3,
              ),
              TextFieldSanitizedAndPaddedForCA
              (
                textFieldStartValue: widget.dtoCAForm.groupProblemsStr,
                textFieldHint: pleaseDescribeTextGroupsHint,
                stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldUtils.stringSanitizerBundlesErrorsMappingForCA,
                textFieldStyle: analysisTextFieldStyle,
                textFieldHintStyle: analysisTextFieldHintStyle,
                errorMessageStyle: analysisTextFieldErrorMessageStyle,
                textFieldMaxLength: chars1Page,
                textFieldCounter: TextFieldUtils.absentCounter,
                onTextFieldValueSubmittedCallbackFunction: (v) {widget.dtoCAForm.groupProblemsStr = v;},
              ),

              /**** ➡️ Sub-point  ****/
              // Question about the same problems
              CustomHeading
              (
                headingText: q.level3TitleSameProblem,
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              SegmentedButtonWithTextField
              (
                segButtonTextOption1: 'Yes',
                segButtonTextOption2: 'No',
                segButtonTextOption3: "I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: widget.dtoCAForm.groupSameProblems.selection,
                textFieldStartValue: widget.dtoCAForm.groupSameProblems.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                parentSegmentedButtonValueCallBackFunction: (v) => _onSegmentedButtonSelection(widget.dtoCAForm.groupSameProblems, v),
                parentTextFieldValueCallBackFunction: (v) {widget.dtoCAForm.groupSameProblems.text = v;},
              ),

              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about harmony at home
              CustomHeading
              (
                headingText: q.level3TitleHarmonyAtHome,
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              SegmentedButtonWithTextField
              (
                segButtonTextOption1: 'Yes',
                segButtonTextOption2: 'No',
                segButtonTextOption3: "I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: widget.dtoCAForm.groupHarmonyHome.selection,
                textFieldStartValue: widget.dtoCAForm.groupHarmonyHome.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                parentSegmentedButtonValueCallBackFunction: (v) => _onSegmentedButtonSelection(widget.dtoCAForm.groupHarmonyHome, v),
                parentTextFieldValueCallBackFunction: (v) {widget.dtoCAForm.groupHarmonyHome.text = v;},
              ),

              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about appreciability at work
              CustomHeading
              (
                headingText: q.level3TitleAppreciabilityAtWork,
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              SegmentedButtonWithTextField
              (
                segButtonTextOption1: 'Yes',
                segButtonTextOption2: 'No',
                segButtonTextOption3: "I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: widget.dtoCAForm.groupAppreciabilityAtWork.selection,
                textFieldStartValue: widget.dtoCAForm.groupAppreciabilityAtWork.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                parentSegmentedButtonValueCallBackFunction: (v) => _onSegmentedButtonSelection(widget.dtoCAForm.groupAppreciabilityAtWork, v),
                parentTextFieldValueCallBackFunction: (v) {widget.dtoCAForm.groupAppreciabilityAtWork.text = v;},
              ),
              
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about the earning ability
              CustomHeading
              (
                headingText: q.level3TitleIncomeEarningAbility,
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              SegmentedButtonWithTextField
              (
                segButtonTextOption1: 'Yes',
                segButtonTextOption2: 'No',
                segButtonTextOption3: "I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: widget.dtoCAForm.groupEarningAbility.selection,
                textFieldStartValue: widget.dtoCAForm.groupEarningAbility.text,
                textFieldHint: pleaseDevelopOrTakeNotesHint,
                parentSegmentedButtonValueCallBackFunction: (v) => _onSegmentedButtonSelection(widget.dtoCAForm.groupEarningAbility, v),
                parentTextFieldValueCallBackFunction: (v) {widget.dtoCAForm.groupEarningAbility.text = v;},
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