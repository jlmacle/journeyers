import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_questions.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_consts.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_checkbox_list_tile_with_text_field.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_padded_text_field.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_segmented_button_with_text_field.dart';
import 'package:journeyers/widgets/custom/text/custom_heading.dart';

part 'context_analysis_form_ext.dart';

/// {@category Context analysis}
/// Form used in the context analysis.
class ContextAnalysisForm extends StatefulWidget 
{
  /// Global key for the context analysis form page
  final GlobalKey<ContextAnalysisProcessState> contextAnalysisFormPageKey;
  /// Callback function used to refresh the page from the context form to the dashboard
  final VoidCallback parentCallbackFunctionToRefreshTheContextAnalysisPage;
  /// Callback function used to switch the focusability of the bottom bar items
  final ValueChanged<bool> parentCallbackFunctionToSetFocusabilityOfBottomBarItems;

  const ContextAnalysisForm
  ({
    super.key,
    required this.contextAnalysisFormPageKey,
    required this.parentCallbackFunctionToRefreshTheContextAnalysisPage,
    required this.parentCallbackFunctionToSetFocusabilityOfBottomBarItems
  });

  @override
  State<ContextAnalysisForm> createState() => ContextAnalysisFormState();
}

class ContextAnalysisFormState extends State<ContextAnalysisForm> 
{
  //**************** ACCESSIBILITY related data ****************//
  // Data related to the folding/unfolding of the expansion tiles
  bool _isIndividualAreaPerspectiveExpanded = false;
  bool _isGroupAreaPerspectiveExpanded = false;

  //**************** SESSION METADATA ****************//
  // Placeholder data for what is entered in addition to the form data
  String _fileName = "";
  List<String> _keywords = [];
  String _analysisTitle = "";  
  
  // Method used to store the form data to CSV, and the session metadata in a file
  Future<void> saveDataAndMetadata() async 
  { 
    // Updating analysis title, keywords, and file name
    _analysisTitle = widget.contextAnalysisFormPageKey.currentState!.analysisTitle;
    _keywords = widget.contextAnalysisFormPageKey.currentState!.keywords;
    _fileName = widget.contextAnalysisFormPageKey.currentState!.fileName;

    // Building the data structure
    await dataStructureBuilding();

    // Transforming the data into a CSV-friendly form
    List<List<String>> preCSVDataIndividualPerspective = await cu.dataToPreCSV(perspectiveData: _enteredData[0]);
    List<List<String>> preCSVDataGroupPerspective = await cu.dataToPreCSV(perspectiveData: _enteredData[1]);

    if (csvBuildingDebug) pu.printd("CSV Building: preCSVDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building: $preCSVDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");
    if (csvBuildingDebug) pu.printd("CSV Building: preCSVDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building: $preCSVDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");

    List<List<String>> csvDataIndividualPerspective = await cu.preCSVToCSVData(preCSVData: preCSVDataIndividualPerspective);
    List<List<String>> csvDataGroupPerspective = await cu.preCSVToCSVData(preCSVData: preCSVDataGroupPerspective);
    // Printing to CSV
    String? pathToCSVFile = 
      await cu.printToCSV(csvDataIndividualPerspective: csvDataIndividualPerspective, 
                          csvDataGroupPerspective: csvDataGroupPerspective,
                          fileName: _fileName);
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
      (typeOfContextData: DashboardUtils.contextAnalysesContext, title: _analysisTitle, 
      keywords: _keywords, formattedDate: formattedDate, pathToFile: pathToCSVFile);
      await upu.saveWasSessionDataSaved(value: true, context: DashboardUtils.contextAnalysesContext);
    }
    
    // Page refreshing for dashboard display
    widget.parentCallbackFunctionToRefreshTheContextAnalysisPage();
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
                  key: _balanceIssueHeadingKey,
                  headingText: q.level3TitleBalanceIssue,
                  headingLevel: 3,
                ),
                CustomCheckBoxWithTextField
                (
                  checkboxText: q.level3TitleBalanceIssueItem1,
                  textFieldHint: pleaseDescribeTextHouseholdHint,
                  parentCheckboxValueCallBackFunction: _setStudiesHouseholdBalanceCheckboxState,
                  parentTextFieldValueCallBackFunction: _setStudiesHouseholdBalanceTextFieldState,
                ),
                CustomCheckBoxWithTextField
                (
                  checkboxText: q.level3TitleBalanceIssueItem2,
                  textFieldHint: pleaseDescribeTextHouseholdHint,
                  parentCheckboxValueCallBackFunction: _setAccessingIncomeHouseholdBalanceCheckboxState,
                  parentTextFieldValueCallBackFunction: _setAccessingIncomeHouseholdBalanceTextFieldState,
                ),
                CustomCheckBoxWithTextField
                (
                  checkboxText: q.level3TitleBalanceIssueItem3,
                  textFieldHint: pleaseDescribeTextHouseholdHint,
                  parentCheckboxValueCallBackFunction: _setEarningIncomeHouseholdBalanceCheckboxState,
                  parentTextFieldValueCallBackFunction: _setEarningIncomedHouseholdBalanceTextFieldState,
                ),
                CustomCheckBoxWithTextField
                (
                  checkboxText: q.level3TitleBalanceIssueItem4,
                  textFieldHint: pleaseDescribeTextHouseholdHint,
                  parentCheckboxValueCallBackFunction: _setHelpingOthersdBalanceCheckboxState,
                  parentTextFieldValueCallBackFunction: _setHelpingOthersHouseholdBalanceTextFieldState,
                ),
                const Gap(preAndPostLevel3DividerGap),
                const Divider(thickness: betweenLevel3DividerThickness),
                const Gap(preAndPostLevel3DividerGap),

                /**** ➡️ Sub-point  ****/
                CustomHeading
                (
                  key: _workplaceIssueHeadingKey,
                  headingText: q.level3TitleWorkplaceIssue,
                  headingLevel: 3,
                ),
                CustomCheckBoxWithTextField
                (
                  checkboxText: q.level3TitleWorkplaceIssueItem1,
                  textFieldHint: pleaseDescribeTextWorkplaceHint,
                  parentCheckboxValueCallBackFunction: _setMoreAppreciatedAtWorkCheckboxState,
                  parentTextFieldValueCallBackFunction: _setMoreAppreciatedAtWorkTextFieldState,
                ),
                CustomCheckBoxWithTextField
                (
                  checkboxText: q.level3TitleWorkplaceIssueItem2,
                  textFieldHint: pleaseDescribeTextWorkplaceHint,
                  parentCheckboxValueCallBackFunction: _setRemainingAppreciatedAtWorkCheckboxState,
                  parentTextFieldValueCallBackFunction: _setRemainingAppreciatedAtWorkTextFieldState,
                ),
                const Gap(preAndPostLevel3DividerGap),
                const Divider(thickness: betweenLevel3DividerThickness),
                const Gap(preAndPostLevel3DividerGap),

                /**** ➡️ Sub-point  ****/
                CustomHeading
                (
                  key: _legacyIssueHeadingKey,
                  headingText: q.level3TitleLegacyIssue,
                  headingLevel: 3,
                ),
                CustomCheckBoxWithTextField
                (
                  checkboxText: q.level3TitleLegacyIssueItem1,
                  textFieldHint: pleaseDevelopOrTakeNotesHint,
                  parentCheckboxValueCallBackFunction: _setBetterLegaciesCheckboxState,
                  parentTextFieldValueCallBackFunction: _setBetterLegaciesTextFieldState,
                ),
                const Gap(preAndPostLevel3DividerGap),
                const Divider(thickness: betweenLevel3DividerThickness),
                const Gap(preAndPostLevel3DividerGap),

                /**** ➡️ Sub-point  ****/
                CustomHeading
                (
                  key: _anotherIssueHeadingKey,
                  headingText: q.level3TitleAnotherIssue,
                  headingLevel: 3,
                  ),
                const CustomPaddedTextField
                (
                  textFieldHint: pleaseDevelopOrTakeNotesHint,
                  textFieldMaxLength: chars1Page,
                  textFieldCounter: TextFieldUtils.absentCounter,
                  parentTextFieldValueCallBackFunction:_setAnotherIssueTextFieldState,
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
                  const CustomPaddedTextField
                  (
                    textFieldHint: pleaseDescribeTextGroupsHint,
                    textFieldMaxLength: chars1Page,
                    textFieldCounter: TextFieldUtils.absentCounter,
                    parentTextFieldValueCallBackFunction: _setProblemsTheGroupsAreTryingToSolveTextFieldState,
                  ),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleSameProblem,
                    headingLevel: 3,
                  ),
                  const Gap(level3AndSegmentedButtonGap),
                  const CustomSegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHint: pleaseDevelopOrTakeNotesHint,
                    parentSegmentedButtonValueCallBackFunction: _setSameProblemsSegmentedButtonState,
                    parentTextFieldValueCallBackFunction: _setSameProblemsTextFieldState,
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
                  const CustomSegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHint: pleaseDevelopOrTakeNotesHint,
                    parentSegmentedButtonValueCallBackFunction: _setHarmonyHomeSegmentedButtonState,
                    parentTextFieldValueCallBackFunction: _setHarmonyHomeTextFieldState,
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
                  const CustomSegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHint: pleaseDevelopOrTakeNotesHint,
                    parentSegmentedButtonValueCallBackFunction: _setAppreciabilityAtWorkSegmentedButtonState,
                    parentTextFieldValueCallBackFunction: _setAppreciabilityAtWorkTextFieldState,
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
                  const CustomSegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHint: pleaseDevelopOrTakeNotesHint,
                    parentSegmentedButtonValueCallBackFunction: _setEarningAbilitySegmentedButtonState,
                    parentTextFieldValueCallBackFunction: _setEarningAbilityTextFieldState,
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