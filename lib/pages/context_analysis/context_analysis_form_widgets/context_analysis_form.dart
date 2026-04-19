import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_consts.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_questions.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/utils/project_specific/dto/dto_custom_checkbox_with_text_field.dart';
import 'package:journeyers/utils/project_specific/dto/dto_custom_segmented_button_with_text_field.dart';
import 'package:journeyers/utils/project_specific/global_keys/global_keys.dart';
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart' as tfu_proj; 
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_checkbox_with_text_field.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_sanitized_and_padded_for_context_analysis.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_segmented_button_with_text_field.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';

part 'context_analysis_form_ext.dart';

/// {@category Context analysis}
/// Form used in the context analysis.
class CAForm extends StatefulWidget 
{
  /// Callback function used to refresh the page from the context form to the dashboard
  final VoidCallback parentCallbackFunctionToRefreshTheCAPage;
  /// Callback function used to switch the focusability of the bottom bar items
  final ValueChanged<bool> parentCallbackFunctionToSetFocusabilityOfBottomBarItems;

  const CAForm
  ({
    super.key,
    required this.parentCallbackFunctionToRefreshTheCAPage,
    required this.parentCallbackFunctionToSetFocusabilityOfBottomBarItems
  });

  @override
  State<CAForm> createState() => CAFormState();
}

class CAFormState extends State<CAForm> 
{
  //**************** ACCESSIBILITY related data ****************//
  // Data related to the folding/unfolding of the expansion tiles
  bool _isIndividualAreaPerspectiveExpanded = false;
  bool _isGroupAreaPerspectiveExpanded = false;

  //**************** SESSION METADATA ****************//
  // Placeholder data for what is entered in addition to the form data
  String _fileName = "";
  Set<String> _keywords = {};
  String _analysisTitle = "";  
  
  // Method used to store the form data to CSV, and the session metadata in a file
  Future<void> saveDataAndMetadata() async 
  { 
    // Updating analysis title, keywords, and file name
    _analysisTitle = caProcessKey.currentState!.analysisTitle.trim() == "" 
                      ? "Untitled" : caProcessKey.currentState!.analysisTitle.trim();
    _keywords = caProcessKey.currentState!.keywords;
    _fileName = caProcessKey.currentState!.fileName;

    // Building the data structure
    await dataStructureBuilding();

    // Transforming the data into a CSV-friendly form
    List<List<String>> preCSVDataIndividualPerspective = await csvu.dataToPreCSV(perspectiveData: _enteredData["individualPerspective"] as LinkedHashMap<String, Object>);
    List<List<String>> preCSVDataGroupPerspective = await csvu.dataToPreCSV(perspectiveData: _enteredData["groupPerspective"] as LinkedHashMap<String, Object>);

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
        //************** ExpansionTile diplaying the individual perspective: beginning **************//
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
                CustomHeading
                (
                  key: balanceIssueHeadingKey,
                  headingText: q.level3TitleBalanceIssue,
                  headingLevel: 3,
                ),
                CheckboxWithTextField
                (
                  checkboxText: q.level3TitleBalanceIssueItem1,
                  textFieldHint: pleaseDescribeTextHouseholdHint,
                  parentCheckboxValueCallBackFunction: (v) => _onBalanceCheckbox(_studiesBalance, v),
                  parentTextFieldValueCallBackFunction: (v) { _studiesBalance.text = v; },
                ),
                CheckboxWithTextField
                (
                  checkboxText: q.level3TitleBalanceIssueItem2,
                  textFieldHint: pleaseDescribeTextHouseholdHint,
                  parentCheckboxValueCallBackFunction: (v) => _onBalanceCheckbox(_accessingIncomeBalance, v),
                  parentTextFieldValueCallBackFunction: (v) { _accessingIncomeBalance.text = v; },
                ),
                CheckboxWithTextField
                (
                  checkboxText: q.level3TitleBalanceIssueItem3,
                  textFieldHint: pleaseDescribeTextHouseholdHint,
                  parentCheckboxValueCallBackFunction: (v) => _onBalanceCheckbox(_earningIncomeBalance, v),
                  parentTextFieldValueCallBackFunction: (v) { _earningIncomeBalance.text = v; },
                ),
                CheckboxWithTextField
                (
                  checkboxText: q.level3TitleBalanceIssueItem4,
                  textFieldHint: pleaseDescribeTextHouseholdHint,
                  parentCheckboxValueCallBackFunction: (v) => _onBalanceCheckbox(_helpingOthersBalance, v),
                  parentTextFieldValueCallBackFunction: (v) { _helpingOthersBalance.text = v; },
                ),
                const Gap(preAndPostLevel3DividerGap),
                const Divider(thickness: betweenLevel3DividerThickness),
                const Gap(preAndPostLevel3DividerGap),

                /**** ➡️ Sub-point  ****/
                CustomHeading
                (
                  key: workplaceIssueHeadingKey,
                  headingText: q.level3TitleWorkplaceIssue,
                  headingLevel: 3,
                ),
                CheckboxWithTextField
                (
                  checkboxText: q.level3TitleWorkplaceIssueItem1,
                  textFieldHint: pleaseDescribeTextWorkplaceHint,
                  parentCheckboxValueCallBackFunction: (v) => _onWorkplaceCheckbox(_moreAppreciatedAtWork, v),
                  parentTextFieldValueCallBackFunction: (v) { _moreAppreciatedAtWork.text = v; },
                ),
                CheckboxWithTextField
                (
                  checkboxText: q.level3TitleWorkplaceIssueItem2,
                  textFieldHint: pleaseDescribeTextWorkplaceHint,
                  parentCheckboxValueCallBackFunction: (v) => _onWorkplaceCheckbox(_remainingAppreciatedAtWork, v),
                  parentTextFieldValueCallBackFunction: (v) { _remainingAppreciatedAtWork.text = v; },
                ),
                const Gap(preAndPostLevel3DividerGap),
                const Divider(thickness: betweenLevel3DividerThickness),
                const Gap(preAndPostLevel3DividerGap),

                /**** ➡️ Sub-point  ****/
                CustomHeading
                (
                  key: legacyIssueHeadingKey,
                  headingText: q.level3TitleLegacyIssue,
                  headingLevel: 3,
                ),
                CheckboxWithTextField
                (
                  checkboxText: q.level3TitleLegacyIssueItem1,
                  textFieldHint: pleaseDevelopOrTakeNotesHint,
                  parentCheckboxValueCallBackFunction: (v) => _onLegacyCheckbox(_betterLegacies, v),
                  parentTextFieldValueCallBackFunction: (v) { _betterLegacies.text = v; },
                ),
                const Gap(preAndPostLevel3DividerGap),
                const Divider(thickness: betweenLevel3DividerThickness),
                const Gap(preAndPostLevel3DividerGap),

                /**** ➡️ Sub-point  ****/
                CustomHeading
                (
                  key: anotherIssueHeadingKey,
                  headingText: q.level3TitleAnotherIssue,
                  headingLevel: 3,
                  ),
                const TextFieldSanitizedAndPaddedForCA
                (
                  stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldUtils.stringSanitizerBundlesErrorsMappingForCA,
                  textFieldStyle: analysisTextFieldStyle,
                  textFieldHint: pleaseDevelopOrTakeNotesHint,
                  textFieldHintStyle: analysisTextFieldHintStyle,
                  errorMessageStyle: analysisTextFieldErrorMessageStyle,
                  textFieldMaxLength: chars1Page,
                  textFieldCounter: TextFieldUtils.absentCounter,
                  parentTextFieldValueCallBackFunction: _onAnotherIssueText,
                ),
              ]
            ),
          ),

            const Gap(preAndPostLevel2DividerGap),
            const Divider(thickness: betweenLevel2DividerThickness),
            const Gap(preAndPostLevel2DividerGap),



            /**** Beginning of the team-related analysis ****/
            //************** ExpansionTile diplaying the group perspective: beginning **************//
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
                  CustomHeading
                  (
                    headingText: q.level3TitleGroupsProblematics,
                    headingLevel: 3,
                  ),
                  TextFieldSanitizedAndPaddedForCA
                  (
                    textFieldHint: pleaseDescribeTextGroupsHint,
                    stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldUtils.stringSanitizerBundlesErrorsMappingForCA,
                    textFieldStyle: analysisTextFieldStyle,
                    textFieldHintStyle: analysisTextFieldHintStyle,
                    errorMessageStyle: analysisTextFieldErrorMessageStyle,
                    textFieldMaxLength: chars1Page,
                    textFieldCounter: TextFieldUtils.absentCounter,
                    parentTextFieldValueCallBackFunction: (v) { _groupsProblemsText = v; },
                  ),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleSameProblem,
                    headingLevel: 3,
                  ),
                  const Gap(level3AndSegmentedButtonGap),
                  SegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHint: pleaseDevelopOrTakeNotesHint,
                    parentSegmentedButtonValueCallBackFunction: (v) => _onSegmentedButton(_sameProblems, v),
                    parentTextFieldValueCallBackFunction: (v) { _sameProblems.text = v; },
                  ),

                  const Gap(preAndPostLevel3DividerGap),
                  const Divider(thickness: betweenLevel3DividerThickness),
                  const Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleHarmonyAtHome,
                    headingLevel: 3,
                  ),
                  const Gap(level3AndSegmentedButtonGap),
                  SegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHint: pleaseDevelopOrTakeNotesHint,
                    parentSegmentedButtonValueCallBackFunction: (v) => _onSegmentedButton(_harmonyHome, v),
                    parentTextFieldValueCallBackFunction: (v) { _harmonyHome.text = v; },
                  ),

                  const Gap(preAndPostLevel3DividerGap),
                  const Divider(thickness: betweenLevel3DividerThickness),
                  const Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleAppreciabilityAtWork,
                    headingLevel: 3,
                  ),
                  const Gap(level3AndSegmentedButtonGap),
                  SegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHint: pleaseDevelopOrTakeNotesHint,
                    parentSegmentedButtonValueCallBackFunction: (v) => _onSegmentedButton(_appreciabilityAtWork, v),
                    parentTextFieldValueCallBackFunction: (v) { _appreciabilityAtWork.text = v; },
                  ),
                  
                  const Gap(preAndPostLevel3DividerGap),
                  const Divider(thickness: betweenLevel3DividerThickness),
                  const Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleIncomeEarningAbility,
                    headingLevel: 3,
                  ),
                  const Gap(level3AndSegmentedButtonGap),
                  SegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHint: pleaseDevelopOrTakeNotesHint,
                    parentSegmentedButtonValueCallBackFunction: (v) => _onSegmentedButton(_earningAbility, v),
                    parentTextFieldValueCallBackFunction: (v) { _earningAbility.text = v; },
                  ),
                ]
              ),
            ),
            //************** ExpansionTile diplaying the group perspective: end **************//

            const Gap(preAndPostLevel2DividerGap),
            const Divider(thickness: betweenLevel2DividerThickness),
            const Gap(preAndPostLevel2DividerGap),
     ],
    );
  }
}