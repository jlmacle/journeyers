import "dart:collection";
import "dart:core";
import "dart:io";

import "package:flutter/material.dart";

import "package:gap/gap.dart";
import "package:intl/intl.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_form_misc_constants.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_custom_checkbox_with_text_field.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_custom_segmented_button_with_text_field.dart";
import "package:journeyers/utils/generic/dashboard/dashboard_utils.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/utils/generic/text_fields/text_field_utils.dart";
import "package:journeyers/utils/project_specific/dev/utility_classes_import.dart";
import "package:journeyers/utils/project_specific/global_keys/global_keys.dart";
import "package:journeyers/utils/project_specific/text_fields/text_field_utils.dart" as tfu_proj; 
import "package:journeyers/widgets/custom/text/custom_heading.dart";

/// {@category Context analysis}
/// Form used in the context analysis.
class CAForm extends StatefulWidget 
{
  /// The DTO object related to the form.
  final DTOCAForm dtoCAForm;

  /// Callback function used to refresh the page from the context analysis process to the dashboard.
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
  // ─── DTO related data ───────────────────────────────────────
  DTOCAForm? _dtoCAForm;

  @override
  void initState() {
    super.initState();
            
    if (widgetSequenceDebug) pu.printdLine();
    if (widgetSequenceDebug) pu.printd("CAForm");

    // _dtoCAForm assigned only from the widget if null
    _dtoCAForm ??= widget.dtoCAForm;
  }

  // ─── ACCESSIBILITY related data ───────────────────────────────────────
  // Data related to the folding/unfolding of the expansion tiles
  bool _isPerspectiveAreaExpandedIndividual = false;
  bool _isPerspectiveAreaExpandedGroup = false;

  // ─── SESSION METADATA ───────────────────────────────────────
  // Placeholder data for what is entered in addition to the form data
  String _fileName = "";
  Set<String> _keywords = {};
  String _analysisTitle = "";  

  // Method used to update a DTOCheckboxWithTextField text 
  Future<void> _onDTOCheckboxWithTextFieldUpdate(DTOCheckboxWithTextField data, String text) async 
  => data.text = text;

  // Method used to update a DTOSegmentedButtonWithTextField text 
  Future<void> _onDTOSegmentedButtonWithTextFieldUpdate(DTOSegmentedButtonWithTextField data, String text) async 
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
  Future<void> _onSegmentedButtonSelected(DTOSegmentedButtonWithTextField data, Set<String>? values) async
   => data.selection = values ?? {};

  // Method used to update the DTO, and the item styling (another issue)
  Future<void> _onAnotherIssueFilled(String value) async 
  {
    _dtoCAForm!.indivAnotherIssueStr = value;
    anotherIssueHeadingKey.currentState
        ?.switchCustomHeadingDecorationIfTextFieldUsed(value);
  }

  // Method used to update the DTO ( group problems to solve)
  Future<void> _onGroupProblemsToSolveFilled(String value) async 
  {
    _dtoCAForm!.groupProblemsToSolveStr = value;
  }
  
  // Used in CAProcess.
  // Method used to store the form data to CSV, and the session metadata in a file.
  Future<void> saveDataAndMetadata() async 
  { 
    // Updating analysis title, keywords, and file name
    _analysisTitle = caProcessKey.currentState!.analysisTitle.trim() == "" 
                      ? "Untitled" : caProcessKey.currentState!.analysisTitle.trim();
    _keywords = caProcessKey.currentState!.analysisKeywords;
    _fileName = caProcessKey.currentState!.analysisFileName;

    // Building the data structure
    final LinkedHashMap<String, Object> enteredData = await _dtoCAForm!.dataStructureBuilding(context);

    // Transforming the data into a CSV-friendly form
    List<List<String>> preCSVDataIndividualPerspective = await _dtoCAForm!.dataToPreCSV(perspectiveData: enteredData["individualPerspective"] as LinkedHashMap<String, Object>);
    List<List<String>> preCSVDataGroupPerspective = await _dtoCAForm!.dataToPreCSV(perspectiveData: enteredData["groupPerspective"] as LinkedHashMap<String, Object>);

    if (csvBuildingDebug) pu.printd("CSV Building: preCSVDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building: $preCSVDataIndividualPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");
    if (csvBuildingDebug) pu.printd("CSV Building: preCSVDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building: $preCSVDataGroupPerspective");
    if (csvBuildingDebug) pu.printd("CSV Building");

    List<List<String>> csvDataIndividualPerspective = await _dtoCAForm!.preCSVToCSVData(preCSVData: preCSVDataIndividualPerspective);
    List<List<String>> csvDataGroupPerspective = await _dtoCAForm!.preCSVToCSVData(preCSVData: preCSVDataGroupPerspective);
    // Printing to CSV
    String? pathToCSVFile = 
      await _dtoCAForm!.printToCSV(csvDataIndividualPerspective: csvDataIndividualPerspective, 
                          csvDataGroupPerspective: csvDataGroupPerspective,
                          fileName: _fileName);
    // Updating the file names list: after printToCSV
    if(Platform.isAndroid || Platform.isIOS) 
    {
      await du.getStoredFileNamesOnMobile();
      if (sessionDataDebug) pu.printd("Session Data: currentListOfStoredFileNames (after retrieval): ${du.currentListOfStoredFileNames}");
      if (sessionDataDebug) pu.printd("Session Data: pathToCSVFile: $pathToCSVFile");
    }
    
    // Saving the dashboard metadata if filePath not null
    if (pathToCSVFile != null)
    { 
      // Date
      var now = DateTime.now();
      //.add_jm() to add this hour:minutes format: 5:08 PM
      var formatter = DateFormat("MMMM dd, yyyy").add_jm();
      var formattedDate = formatter.format(now);   
      await du.saveDashboardMetadata
      (
        typeOfDashboardContext: DashboardUtils.caContext, 
        title: _analysisTitle, 
        keywords: _keywords.toList(), 
        formattedDate: formattedDate, 
        filePath: pathToCSVFile
      );
      await rtdu.saveWasSessionDataSaved(wasDataSaved: true, context: DashboardUtils.caContext);
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
          toggled: false, // seems necessary (as of 26/01/11) to have "button" voiced on Android
          button: true, // with tooltip, useful for NVDA
          // tooltip: "Zone to click to expand data", // both label and tooltip were voiced with Narrator
          label: "Zone to click to expand data", // for Orca
          expanded: _isPerspectiveAreaExpandedIndividual, // useful for NVDA, not voiced by Narrator at the time of coding (26/01/11)
          child:
          ExpansionTile
          ( 
            tilePadding: const EdgeInsets.only(top:0),
            expandedCrossAxisAlignment: CrossAxisAlignment.center,
            internalAddSemanticForOnTap: true, 
            onExpansionChanged: (value) 
            {
              setState(() {_isPerspectiveAreaExpandedIndividual = value;});
              widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems(!(_isPerspectiveAreaExpandedIndividual || _isPerspectiveAreaExpandedGroup));
              },
            // on Windows, for Narrator: was necessary (as of 26/01/11) to have "button" voiced after the title was voiced
            maintainState: true, // to keep the state of the children widget
            title:             
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CustomHeading
                (
                  headingText: AppLocalizations.of(context)?.ca_process_individual_perspective_title_question ?? "Issue with the title question for the individual perspective",
                  headingLevel: 2,
                ),
              ),
            children: <Widget>
            [
              /**** ➡️ Sub-point  ****/
              // Balance issue questions
              CustomHeading
              (
                key: balanceIssueHeadingKey,
                headingText: AppLocalizations.of(context)?.ca_process_individual_perspective_balance_issue_section_question ?? "Issue with the section question for the balance issue, in the individual perspective", 
                headingLevel: 3,
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: AppLocalizations.of(context)?.ca_process_individual_perspective_balance_studies_household ?? "Issue with the studies-household life balance question, in the individual perspective",
                // Initializing the checkbox value with the DTO's value
                checkboxStartValue:  _dtoCAForm!.indivBalanceStudiesHousehold.checked,
                // Initializing the text field value with the DTO's value
                textFieldStartValue: _dtoCAForm!.indivBalanceStudiesHousehold.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_past_outcomes_text_field_hint ?? "Issue with the text field hint, for the past outcomes for the household",
                // Updating DTO and UI (heading and item styling)
                onCheckboxValueChangedCallbackFunction: (v) async => await _onBalanceItemChecked(_dtoCAForm!.indivBalanceStudiesHousehold, v),
                // Updating DTO
                onTextFieldValueChangedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldUpdate(_dtoCAForm!.indivBalanceStudiesHousehold, v),
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: AppLocalizations.of(context)?.ca_process_individual_perspective_balance_accessing_income_household ?? "Issue with the accessing income-household life balance question, in the individual perspective",
                checkboxStartValue: _dtoCAForm!.indivBalanceAccessingIncomeHousehold.checked,
                textFieldStartValue: _dtoCAForm!.indivBalanceAccessingIncomeHousehold.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_past_outcomes_text_field_hint ?? "Issue with the text field hint, for the past outcomes for the household",
                onCheckboxValueChangedCallbackFunction: (v) async => await _onBalanceItemChecked(_dtoCAForm!.indivBalanceAccessingIncomeHousehold, v),
                onTextFieldValueChangedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldUpdate(_dtoCAForm!.indivBalanceAccessingIncomeHousehold, v),
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: AppLocalizations.of(context)?.ca_process_individual_perspective_balance_earning_income_household ?? "Issue with the earning income-household life balance question, in the individual perspective",
                checkboxStartValue: _dtoCAForm!.indivBalanceEarningIncomeHousehold.checked,
                textFieldStartValue: _dtoCAForm!.indivBalanceEarningIncomeHousehold.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_past_outcomes_text_field_hint ?? "Issue with the text field hint, for the past outcomes for the household",
                onCheckboxValueChangedCallbackFunction: (v) async => await _onBalanceItemChecked(_dtoCAForm!.indivBalanceEarningIncomeHousehold, v),
                onTextFieldValueChangedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldUpdate(_dtoCAForm!.indivBalanceEarningIncomeHousehold, v),
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: AppLocalizations.of(context)?.ca_process_individual_perspective_balance_helping_others_household ?? "Issue with the helping others-household life balance question, in the individual perspective",
                checkboxStartValue: _dtoCAForm!.indivBalanceHelpingOthersHousehold.checked,
                textFieldStartValue: _dtoCAForm!.indivBalanceHelpingOthersHousehold.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_helping_household_text_field_hint ?? "Issue with the text field hint, for the past outcomes for the household",
                onCheckboxValueChangedCallbackFunction: (v) async => await _onBalanceItemChecked(_dtoCAForm!.indivBalanceHelpingOthersHousehold, v),
                onTextFieldValueChangedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldUpdate(_dtoCAForm!.indivBalanceHelpingOthersHousehold, v),
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Workplace issue questions
              CustomHeading
              (
                key: workplaceIssueHeadingKey,
                headingText: AppLocalizations.of(context)?.ca_process_individual_perspective_workplace_issue_section_question ?? "Issue with the section question for the workplace issue, in the individual perspective",
                headingLevel: 3,
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: AppLocalizations.of(context)?.ca_process_individual_perspective_workplace_more_appreciated ?? "Issue with the more-appreciated-at-work question, in the individual perspective",
                checkboxStartValue: _dtoCAForm!.indivAtWorkMoreAppreciated.checked,
                textFieldStartValue: _dtoCAForm!.indivAtWorkMoreAppreciated.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_past_workplace_outcomes_text_field_hint ?? "Issue with the text field hint, for the past outcomes for the workplace",
                onCheckboxValueChangedCallbackFunction: (v) async  => await _onWorkplaceItemChecked(_dtoCAForm!.indivAtWorkMoreAppreciated, v),
                onTextFieldValueChangedCallbackFunction:  (v) async => await _onDTOCheckboxWithTextFieldUpdate(_dtoCAForm!.indivAtWorkMoreAppreciated , v),
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: AppLocalizations.of(context)?.ca_process_individual_perspective_workplace_to_remain_appreciated ?? "Issue with the to-remain-appreciated-at-work question, in the individual perspective",
                checkboxStartValue: _dtoCAForm!.indivAtWorkRemainingAppreciated.checked,
                textFieldStartValue: _dtoCAForm!.indivAtWorkRemainingAppreciated.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_past_workplace_outcomes_text_field_hint ?? "Issue with the text field hint, for the past outcomes for the workplace",
                onCheckboxValueChangedCallbackFunction: (v) async => await _onWorkplaceItemChecked(_dtoCAForm!.indivAtWorkRemainingAppreciated, v),
                onTextFieldValueChangedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldUpdate(_dtoCAForm!.indivAtWorkRemainingAppreciated, v),
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Legacy issue question
              CustomHeading
              (
                key: legacyIssueHeadingKey,
                headingText: AppLocalizations.of(context)?.ca_process_individual_perspective_legacy_issue_section_question ?? "Issue with the section question for the legacy issue, in the individual perspective",
                headingLevel: 3,
              ),
              CACheckboxWithSanitizedAndPaddedTextField
              (
                checkboxText: AppLocalizations.of(context)?.ca_process_individual_perspective_legacy_better_legacy ?? "Issue with the better legacy question, in the individual perspective",
                checkboxStartValue: _dtoCAForm!.indivBetterLegacies.checked,
                textFieldStartValue: _dtoCAForm!.indivBetterLegacies.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_please_develop_text_field_hint ?? "Issue with the text field hint inviting to develop",
                onCheckboxValueChangedCallbackFunction: (v) async => await _onLegacyItemChecked(_dtoCAForm!.indivBetterLegacies, v),
                onTextFieldValueChangedCallbackFunction: (v) async => await _onDTOCheckboxWithTextFieldUpdate(_dtoCAForm!.indivBetterLegacies, v),
              ),
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Another issue question
              CustomHeading
              (
                key: anotherIssueHeadingKey,
                headingText: AppLocalizations.of(context)?.ca_process_individual_perspective_another_issue_section_question ?? "Issue with the section question for an issue of another type, in the individual perspective",
                headingLevel: 3,
                ),
              CATextFieldSanitizedAndPadded
              (
                key: const Key("ca-process-another-issue-widget"),
                stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
                textFieldStyle: analysisTextFieldStyle,
                textFieldStartValue:_dtoCAForm!.indivAnotherIssueStr,
                textFieldHint: AppLocalizations.of(context)?.ca_process_please_develop_text_field_hint ?? "Issue with the text field hint inviting to develop",
                textFieldHintStyle: analysisTextFieldHintStyle,
                errorMessageStyle: analysisTextFieldErrorMessageStyle,
                textFieldMaxLength: CAFormMiscConstants.chars1Page,
                textFieldCounter: TextFieldUtils.counterAbsent,
                onTextFieldValueChangedCallbackFunction: (v) async => await _onAnotherIssueFilled(v), 
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
          toggled: false, // seems necessary (as of 26/01/11) to have "button" voiced on Android
          button: true, // with tooltip, useful for NVDA
          // tooltip: "Zone to click to expand data", // both label and tooltip were voiced with Narrator
          label: "Zone to click to expand data", // for Orca
          expanded: _isPerspectiveAreaExpandedGroup, // useful for NVDA, not voiced by Narrator at the time of coding (26/01/11)
          child:
          ExpansionTile
          ( 
            expandedCrossAxisAlignment: CrossAxisAlignment.center,
            expandedAlignment: Alignment.center,
            internalAddSemanticForOnTap: true, 
            onExpansionChanged: (value) 
            {setState(() 
            {
              _isPerspectiveAreaExpandedGroup = value;
              widget.parentCallbackFunctionToSetFocusabilityOfBottomBarItems(!(_isPerspectiveAreaExpandedIndividual || _isPerspectiveAreaExpandedGroup));
            });
            },
            // on Windows, for Narrator: was necessary (as of 26/01/11) to have "button" voiced after the title was voiced
            maintainState: true, // to keep the state of the children widget
            title:              
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CustomHeading
                (
                  headingText: AppLocalizations.of(context)?.ca_process_group_perspective_title_question ?? "Issue with the title question for the groups/teams perspective",
                  headingLevel: 2,
                ),
              ),
            children: <Widget>
            [
              /**** ➡️ Sub-point  ****/
              // Question about the group problems
              CustomHeading
              (
                headingText: AppLocalizations.of(context)?.ca_process_group_perspective_problems ?? "Issue with the question for the problem(s) the groups/teams are trying to solve",
                headingLevel: 3,
              ),
              CATextFieldSanitizedAndPadded
              (
                key: const Key("ca-process-group-problems-to-solve-widget"),
                textFieldStartValue: _dtoCAForm!.groupProblemsToSolveStr,
                textFieldHint: AppLocalizations.of(context)?.ca_process_please_describe_problems_text_field_hint ?? "Issue with the text field hint inviting to describe the problem(s) that the groups/teams are trying to solve",
                stringSanitizerBundlesErrorsMap: tfu_proj.TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForCA,
                textFieldStyle: analysisTextFieldStyle,
                textFieldHintStyle: analysisTextFieldHintStyle,
                errorMessageStyle: analysisTextFieldErrorMessageStyle,
                textFieldMaxLength: CAFormMiscConstants.chars1Page,
                textFieldCounter: TextFieldUtils.counterAbsent,
                onTextFieldValueChangedCallbackFunction: (v) async => await _onGroupProblemsToSolveFilled(v),
              ),

              /**** ➡️ Sub-point  ****/
              // Question about the same problems
              CustomHeading
              (
                headingText: AppLocalizations.of(context)?.ca_process_group_perspective_solving_same_problems ?? "Issue with the question related to solving the same problem(s) as the groups/teams",
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              CASegmentedButtonWithSanitizedAndPaddedTextField
              (
                key: const Key("ca-process-group-same-problems-to-solve-widget"),
                segButtonTextOption1: AppLocalizations.of(context)?.segmented_button_yes ?? "Issue with the l10n for Yes",
                segButtonTextOption2: AppLocalizations.of(context)?.segmented_button_no ?? "Issue with the l10n for No",
                segButtonTextOption3: AppLocalizations.of(context)?.segmented_button_I_don_t_know ?? "Issue with the l10n for I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: _dtoCAForm!.groupSameProblemsToSolve.selection,
                textFieldStartValue: _dtoCAForm!.groupSameProblemsToSolve.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_please_develop_text_field_hint ?? "Issue with the text field hint inviting to develop",
                onSegmentedButtonOptionsSelectedCallbackFunction: (v) async => await _onSegmentedButtonSelected(_dtoCAForm!.groupSameProblemsToSolve, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOSegmentedButtonWithTextFieldUpdate(_dtoCAForm!.groupSameProblemsToSolve, v),
              ),

              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about harmony at home
              CustomHeading
              (
                headingText: AppLocalizations.of(context)?.ca_process_group_perspective_harmony_home ?? "Issue with the question related to harmony at home",
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              CASegmentedButtonWithSanitizedAndPaddedTextField
              (
                key: const Key("ca-process-group-harmony-home-widget"),
                segButtonTextOption1: AppLocalizations.of(context)?.segmented_button_yes ?? "Issue with the l10n for Yes",
                segButtonTextOption2: AppLocalizations.of(context)?.segmented_button_no ?? "Issue with the l10n for No",
                segButtonTextOption3: AppLocalizations.of(context)?.segmented_button_I_don_t_know ?? "Issue with the l10n for I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: _dtoCAForm!.groupHarmonyHome.selection,
                textFieldStartValue: _dtoCAForm!.groupHarmonyHome.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_please_develop_text_field_hint ?? "Issue with the text field hint inviting to develop",
                onSegmentedButtonOptionsSelectedCallbackFunction: (v) async => await _onSegmentedButtonSelected(_dtoCAForm!.groupHarmonyHome, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOSegmentedButtonWithTextFieldUpdate(_dtoCAForm!.groupHarmonyHome, v),
              ),

              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about appreciability at work
              CustomHeading
              (
                headingText: AppLocalizations.of(context)?.ca_process_group_perspective_appreciability_work ?? "Issue with the question related to the consistency with appreciability at work?",
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              CASegmentedButtonWithSanitizedAndPaddedTextField
              (
                key: const Key("ca-process-group-appreciability-at-work-widget"),
                segButtonTextOption1: AppLocalizations.of(context)?.segmented_button_yes ?? "Issue with the l10n for Yes",
                segButtonTextOption2: AppLocalizations.of(context)?.segmented_button_no ?? "Issue with the l10n for No",
                segButtonTextOption3: AppLocalizations.of(context)?.segmented_button_I_don_t_know ?? "Issue with the l10n for I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: _dtoCAForm!.groupAppreciabilityAtWork.selection,
                textFieldStartValue: _dtoCAForm!.groupAppreciabilityAtWork.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_please_develop_text_field_hint ?? "Issue with the text field hint inviting to develop",
                onSegmentedButtonOptionsSelectedCallbackFunction: (v) async => await _onSegmentedButtonSelected(_dtoCAForm!.groupAppreciabilityAtWork, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOSegmentedButtonWithTextFieldUpdate(_dtoCAForm!.groupAppreciabilityAtWork, v),
              ),
              
              const Gap(preAndPostLevel3DividerGap),
              const Divider(thickness: betweenLevel3DividerThickness),
              const Gap(preAndPostLevel3DividerGap),

              /**** ➡️ Sub-point  ****/
              // Question about the earning ability
              CustomHeading
              (
                headingText: AppLocalizations.of(context)?.ca_process_group_perspective_earning_ability ?? "Issue with the question related to the consistency with earning ability?",
                headingLevel: 3,
              ),
              const Gap(level3AndSegmentedButtonGap),
              CASegmentedButtonWithSanitizedAndPaddedTextField
              (                
                key: const Key("ca-process-group-earning-ability-widget"),
                segButtonTextOption1: AppLocalizations.of(context)?.segmented_button_yes ?? "Issue with the l10n for Yes",
                segButtonTextOption2: AppLocalizations.of(context)?.segmented_button_no ?? "Issue with the l10n for No",
                segButtonTextOption3: AppLocalizations.of(context)?.segmented_button_I_don_t_know ?? "Issue with the l10n for I don't know",
                segButtonTextOptionsfontSize: 16,
                segButtonStartValue: _dtoCAForm!.groupEarningAbility.selection,
                textFieldStartValue: _dtoCAForm!.groupEarningAbility.text,
                textFieldHint: AppLocalizations.of(context)?.ca_process_please_develop_text_field_hint ?? "Issue with the text field hint inviting to develop",
                onSegmentedButtonOptionsSelectedCallbackFunction: (v) async => await _onSegmentedButtonSelected(_dtoCAForm!.groupEarningAbility, v),
                onTextFieldValueSubmittedCallbackFunction: (v) async => await _onDTOSegmentedButtonWithTextFieldUpdate(_dtoCAForm!.groupEarningAbility, v),
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