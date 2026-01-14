import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gap/gap.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/csv/csv_utils.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/custom_widgets/display_and_content/custom_heading.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_padded_text_field.dart';
import 'package:journeyers/custom_widgets/interaction_and_inputs/custom_segmented_button_with_text_field.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_context_form_questions.dart';


/// {@category Pages}
/// {@category Context analysis}
/// The form page for the context analysis.

// Scrolling down the questions while tab navigating is an issue if the bottom bar items are not excluded from focus.
// When an expansion tile is expanded, the bottom bar items are excluded from focus.
// If the user reaches the "save data" button, the bottom bar items are restored as accessible to focus. 
// If the user tab navigates from the "save data" button toward the analysis title with a "shift+tab", the bottom bar items are excluded again from focus.
class ContextAnalysisContextFormPage extends StatefulWidget 
{
  /// An "expansion tile expanded/folded"-related callback function for the parent widget, to enhance the tab navigation.
  final ValueChanged<bool> parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability;

  /// A placeholder void callback function with a bool parameter
  static void placeHolderFunctionBool(bool value) {}

  const ContextAnalysisContextFormPage({
    super.key,
    this.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability = placeHolderFunctionBool
    });

  @override
  State<ContextAnalysisContextFormPage> createState() => _ContextAnalysisContextFormPageState();
}

class _ContextAnalysisContextFormPageState extends State<ContextAnalysisContextFormPage> 
{
  // Utility classes
  CSVUtils cu = CSVUtils();
  DashboardUtils du = DashboardUtils();
  FormUtils fu = FormUtils();
  PrintUtils pu = PrintUtils();

  // Focus nodes and data related to reaching nodes
  final FocusNode _saveDataButtonFocusNode = FocusNode();
  final FocusNode _analysisTitleFocusNode = FocusNode();
  bool movingThroughButton = false;

  // Question labels for the form
  ContextAnalysisContextFormQuestions q = ContextAnalysisContextFormQuestions();

  // Data structure
  List<LinkedHashMap<String, dynamic>> _enteredData = [];

  //*****************    State related code    **********************//

  bool _isIndividualAreaPerspectiveExpanded = false;
  bool _isGroupAreaPerspectiveExpanded = false;

  bool _studiesHouseholdBalanceCheckboxValue = false;
  String _studiesHouseholdBalanceTextFieldContent = "";

  bool _accessingIncomeHouseholdBalanceCheckboxValue = false;
  String _accessingIncomeHouseholdBalanceTextFieldContent = "";

  bool _earningIncomeHouseholdBalanceCheckboxValue = false;
  String _earningIncomeHouseholdBalanceTextFieldContent = "";

  bool _helpingOthersHouseholdBalanceCheckboxValue = false;
  String _helpingOthersHouseholdBalanceTextFieldContent = "";

  bool _moreAppreciatedAtWorkCheckboxValue = false;
  String _moreAppreciatedAtWorkTextFieldContent = "";

  bool _remainingAppreciatedAtWorkCheckboxValue = false;
  String _remainingAppreciatedAtWorkTextFieldContent = "";

  bool _betterLegaciesCheckboxValue = false;
  String _betterLegaciesTextFieldContent = "";

  String _anotherIssueTextFieldContent = "";

  String _problemsTheGroupsAreTryingToSolveTextFieldContent = "";

  Set<String> _sameProblemsSegmentedButtonSelection = {};
  String _sameProblemsTextFieldContent = "";

  Set<String> _harmonyHomeSegmentedButtonSelection = {};
  String _harmonyHomeTextFieldContent = "";

  Set<String> _appreciabilityAtWorkSegmentedButtonSelection = {};
  String _appreciabilityAtWorkTextFieldContent = "";

  Set<String> _earningAbilitySegmentedButtonSelection = {};
  String _earningAbilityTextFieldContent = "";

  // Session title
  String _analysisTitle = "";

  // Callback methods from the form page
  // Individual perspective
  _setStudiesHouseholdBalanceCheckboxState(bool? newValue) {setState(() {_studiesHouseholdBalanceCheckboxValue = newValue!;});}

  _setStudiesHouseholdBalanceTextFieldState(String newValue) {setState(() {_studiesHouseholdBalanceTextFieldContent = newValue;});}

  _setAccessingIncomeHouseholdBalanceCheckboxState(bool? newValue) {setState(() {_accessingIncomeHouseholdBalanceCheckboxValue = newValue!;});}

  _setAccessingIncomeHouseholdBalanceTextFieldState(String newValue) {setState(() {_accessingIncomeHouseholdBalanceTextFieldContent = newValue;});}

  _setEarningIncomeHouseholdBalanceCheckboxState(bool? newValue) {setState(() {_earningIncomeHouseholdBalanceCheckboxValue = newValue!;});}

  _setEarningIncomedHouseholdBalanceTextFieldState(String newValue) {setState(() {_earningIncomeHouseholdBalanceTextFieldContent = newValue;});}

  _setHelpingOthersdBalanceCheckboxState(bool? newValue) {setState(() {_helpingOthersHouseholdBalanceCheckboxValue = newValue!;});}

  _setHelpingOthersHouseholdBalanceTextFieldState(String newValue) {setState(() {_helpingOthersHouseholdBalanceTextFieldContent = newValue;});}

  _setMoreAppreciatedAtWorkCheckboxState(bool? newValue) {setState(() {_moreAppreciatedAtWorkCheckboxValue = newValue!;});}

  _setMoreAppreciatedAtWorkTextFieldState(String newValue) {setState(() {_moreAppreciatedAtWorkTextFieldContent = newValue;});}

  _setRemainingAppreciatedAtWorkCheckboxState(bool? newValue) {setState(() {_remainingAppreciatedAtWorkCheckboxValue = newValue!;});}

  _setRemainingAppreciatedAtWorkTextFieldState(String newValue) {setState(() {_remainingAppreciatedAtWorkTextFieldContent = newValue;});}

  _setBetterLegaciesCheckboxState(bool? newValue) {setState(() {_betterLegaciesCheckboxValue = newValue!;});}

  _setBetterLegaciesTextFieldState(String newValue) {setState(() {_betterLegaciesTextFieldContent = newValue;});}

  _setAnotherIssueTextFieldState(String newValue) {setState(() {_anotherIssueTextFieldContent = newValue;});}

  // Groups/Teams perspective
  _setProblemsTheGroupsAreTryingToSolveTextFieldState(String newValue) {setState(() {_problemsTheGroupsAreTryingToSolveTextFieldContent = newValue;});}

  _setSameProblemsSegmentedButtonState(Set<String>? values) {setState(() {_sameProblemsSegmentedButtonSelection = values!;});}

  _setSameProblemsTextFieldState(String newValue) {setState(() {_sameProblemsTextFieldContent = newValue;});}

  _setHarmonyHomeSegmentedButtonState(Set<String>? values) {setState(() {_harmonyHomeSegmentedButtonSelection = values!;});}

  _setHarmonyHomeTextFieldState(String newValue) {setState(() {_harmonyHomeTextFieldContent = newValue;});}

  _setAppreciabilityAtWorkSegmentedButtonState(Set<String>? values) {setState(() {_appreciabilityAtWorkSegmentedButtonSelection = values!;});}

  _setAppreciabilityAtWorkTextFieldState(String newValue) {setState(() {_appreciabilityAtWorkTextFieldContent = newValue;});}

  _setEarningAbilitySegmentedButtonState(Set<String>? values) {setState(() {_earningAbilitySegmentedButtonSelection = values!;});}

  _setEarningAbilityTextFieldState(String newValue) {setState(() {_earningAbilityTextFieldContent = newValue;});}

  _setAnalysisTitleTextFieldState(String newValue) {setState(() {_analysisTitle = newValue;});}

  //*****************    Data structure related code    **********************//
  void dataStructureBuilding() 
  {
    // Using LinkedHashMaps for an insertion-ordered hash-table based (source code).

    //************************* Individual perspective ******************************/
    // Individual level: balance issue
    // level3TitleBalanceIssueItem1Data
    LinkedHashMap<String, dynamic> level3TitleBalanceItem1Data = LinkedHashMap<String, dynamic>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleBalanceItem1Data[FormUtils.checkbox] = _studiesHouseholdBalanceCheckboxValue;
    // Keeping the text field value only if the checkbox is checked
    if (_studiesHouseholdBalanceCheckboxValue) level3TitleBalanceItem1Data[FormUtils.textField] = _studiesHouseholdBalanceTextFieldContent;    
    // level3TitleBalanceIssueItem2Data
    LinkedHashMap<String, dynamic> level3TitleBalanceItem2Data = LinkedHashMap<String, dynamic>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleBalanceItem2Data[FormUtils.checkbox] = _accessingIncomeHouseholdBalanceCheckboxValue;
    if (_accessingIncomeHouseholdBalanceCheckboxValue) level3TitleBalanceItem2Data[FormUtils.textField] = _accessingIncomeHouseholdBalanceTextFieldContent;
    // level3TitleBalanceIssueItem3Data
    LinkedHashMap<String, dynamic> level3TitleBalanceItem3Data = LinkedHashMap<String, dynamic>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleBalanceItem3Data[FormUtils.checkbox] = _earningIncomeHouseholdBalanceCheckboxValue;
    if (_earningIncomeHouseholdBalanceCheckboxValue) level3TitleBalanceItem3Data[FormUtils.textField] = _earningIncomeHouseholdBalanceTextFieldContent;
    // level3TitleBalanceIssueItem4Data
    LinkedHashMap<String, dynamic> level3TitleBalanceItem4Data = LinkedHashMap<String, dynamic>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleBalanceItem4Data[FormUtils.checkbox] = _helpingOthersHouseholdBalanceCheckboxValue;
    if (_helpingOthersHouseholdBalanceCheckboxValue) level3TitleBalanceItem4Data[FormUtils.textField] = _helpingOthersHouseholdBalanceTextFieldContent;
    // level3TitleBalanceIssueData
    LinkedHashMap<String, dynamic> level3TitleBalanceIssueData = LinkedHashMap<String, dynamic>.from
    ({
      q.level3TitleBalanceIssueItem1: level3TitleBalanceItem1Data,
      q.level3TitleBalanceIssueItem2: level3TitleBalanceItem2Data,
      q.level3TitleBalanceIssueItem3: level3TitleBalanceItem3Data,
      q.level3TitleBalanceIssueItem4: level3TitleBalanceItem4Data,
    });

    // Individual level: workplace issue
    // level3TitleWorkplaceIssueItem1Data
    LinkedHashMap<String, dynamic> level3TitleWorkplaceIssueItem1Data = LinkedHashMap<String, dynamic>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleWorkplaceIssueItem1Data[FormUtils.checkbox] = _moreAppreciatedAtWorkCheckboxValue;
    if (_moreAppreciatedAtWorkCheckboxValue) level3TitleWorkplaceIssueItem1Data[FormUtils.textField] = _moreAppreciatedAtWorkTextFieldContent;
    // level3TitleWorkplaceIssueItem2Data
    LinkedHashMap<String, dynamic> level3TitleWorkplaceIssueItem2Data = LinkedHashMap<String, dynamic>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleWorkplaceIssueItem2Data[FormUtils.checkbox] = _remainingAppreciatedAtWorkCheckboxValue;
    if (_remainingAppreciatedAtWorkCheckboxValue) level3TitleWorkplaceIssueItem2Data[FormUtils.textField] = _remainingAppreciatedAtWorkTextFieldContent;
    // level3TitleWorkplaceIssueData
    LinkedHashMap<String, dynamic> level3TitleWorkplaceIssueData = LinkedHashMap<String, dynamic>.from
    ({
      q.level3TitleWorkplaceIssueItem1: level3TitleWorkplaceIssueItem1Data,
      q.level3TitleWorkplaceIssueItem2: level3TitleWorkplaceIssueItem2Data,
    });

    // Individual level: legacy issue
    // level3TitleLegacyIssueItem1
    LinkedHashMap<String, dynamic> level3TitleLegacyIssueItem1Data = LinkedHashMap<String, dynamic>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleLegacyIssueItem1Data[FormUtils.checkbox] = _betterLegaciesCheckboxValue;
    if (_betterLegaciesCheckboxValue) level3TitleLegacyIssueItem1Data[FormUtils.textField] = _betterLegaciesTextFieldContent;
    // level3TitleLegacyIssueData
    LinkedHashMap<String, dynamic> level3TitleLegacyIssueData = LinkedHashMap<String, dynamic>.from({q.level3TitleLegacyIssueItem1: level3TitleLegacyIssueItem1Data});

    // Individual level: another issue
    // level3TitleAnotherIssueItem1
    LinkedHashMap<String, dynamic> level3TitleAnotherIssueItem1Data = LinkedHashMap<String, dynamic>.from({FormUtils.textField: ""});
    level3TitleAnotherIssueItem1Data[FormUtils.textField] = _anotherIssueTextFieldContent;
    // Different pattern for the text field only inputs (might modify later)

    // Adding to the level2TitleIndividual data
    // level2TitleIndividualData
    LinkedHashMap<String, dynamic> level2TitleIndividualData = LinkedHashMap<String, dynamic>.from
    ({
      q.level2TitleIndividual: 
      {
        q.level3TitleBalanceIssue: level3TitleBalanceIssueData,
        q.level3TitleWorkplaceIssue: level3TitleWorkplaceIssueData,
        q.level3TitleLegacyIssue: level3TitleLegacyIssueData,
        q.level3TitleAnotherIssue: level3TitleAnotherIssueItem1Data,
      },
    });

    //************************* Groups/Teams perspective ******************************/
    // Groups/teams level: problematics the groups/teams are trying to solve
    // level3TitleGroupsProblematicsItem1
    LinkedHashMap<String, dynamic> level3TitleGroupsProblematicsItem1Data = LinkedHashMap<String, dynamic>.from({FormUtils.textField: ""});
    level3TitleGroupsProblematicsItem1Data[FormUtils.textField] = _problemsTheGroupsAreTryingToSolveTextFieldContent;

    // Groups/teams level: trying to solve the same problems?
    // level3TitleSameProblemsItem1
    LinkedHashMap<String, dynamic> level3TitleSameProblemsItem1Data = LinkedHashMap<String, dynamic>.from({FormUtils.segmentedButton: "", FormUtils.textField: ""});
    // CustomSegmentedButtonWithTextField: this.multiSelectionEnabled = false
    if (_sameProblemsSegmentedButtonSelection.length == 1) {level3TitleSameProblemsItem1Data[FormUtils.segmentedButton] = _sameProblemsSegmentedButtonSelection.first;} 
    else {level3TitleSameProblemsItem1Data[FormUtils.segmentedButton] = "";}
    if (_sameProblemsSegmentedButtonSelection.isNotEmpty) level3TitleSameProblemsItem1Data[FormUtils.textField] = _sameProblemsTextFieldContent;

    // Groups/teams level: harmony at home
    // level3TitleHarmonyAtHomeItem1
    LinkedHashMap<String, dynamic> level3TitleHarmonyAtHomeItems1Data = LinkedHashMap<String, dynamic>.from({FormUtils.segmentedButton: "", FormUtils.textField: ""});
    if (_harmonyHomeSegmentedButtonSelection.length == 1) {level3TitleHarmonyAtHomeItems1Data[FormUtils.segmentedButton] = _harmonyHomeSegmentedButtonSelection.first;} 
    else {level3TitleHarmonyAtHomeItems1Data[FormUtils.segmentedButton] = "";}
    if (_harmonyHomeSegmentedButtonSelection.isNotEmpty) level3TitleHarmonyAtHomeItems1Data[FormUtils.textField] = _harmonyHomeTextFieldContent;

    // Groups/teams level: appreciability at work
    // level3TitleAppreciabilityAtWorkItem1
    LinkedHashMap<String, dynamic> level3TitleAppreciabilityAtWorkItem1Data = LinkedHashMap<String, dynamic>.from({FormUtils.segmentedButton: "", FormUtils.textField: ""});
    if (_appreciabilityAtWorkSegmentedButtonSelection.length == 1) {level3TitleAppreciabilityAtWorkItem1Data[FormUtils.segmentedButton] = _appreciabilityAtWorkSegmentedButtonSelection.first;} 
    else {level3TitleAppreciabilityAtWorkItem1Data[FormUtils.segmentedButton] = "";}
    if (_appreciabilityAtWorkSegmentedButtonSelection.isNotEmpty) level3TitleAppreciabilityAtWorkItem1Data[FormUtils.textField] = _appreciabilityAtWorkTextFieldContent;

    // Groups/teams level: income earning abillity
    // level3TitleIncomeEarningAbilityItem1
    LinkedHashMap<String, dynamic> level3TitleIncomeEarningAbilityItem1Data = LinkedHashMap<String, dynamic>.from({FormUtils.segmentedButton: "", FormUtils.textField: ""});
    if (_earningAbilitySegmentedButtonSelection.length == 1) {level3TitleIncomeEarningAbilityItem1Data[FormUtils.segmentedButton] = _earningAbilitySegmentedButtonSelection.first;} 
    else {level3TitleIncomeEarningAbilityItem1Data[FormUtils.segmentedButton] = "";}
    if (_earningAbilitySegmentedButtonSelection.isNotEmpty) level3TitleIncomeEarningAbilityItem1Data[FormUtils.textField] = _earningAbilityTextFieldContent;

    // Adding to the level2TitleGroup data
    // level2TitleGroupData
    LinkedHashMap<String, dynamic> level2TitleGroupData = LinkedHashMap<String, dynamic>.from
    ({
        q.level2TitleGroup: 
        {
          q.level3TitleGroupsProblematics: level3TitleGroupsProblematicsItem1Data,
          q.level3TitleSameProblem: level3TitleSameProblemsItem1Data,
          q.level3TitleHarmonyAtHome: level3TitleHarmonyAtHomeItems1Data,
          q.level3TitleAppreciabilityAtWork: level3TitleAppreciabilityAtWorkItem1Data,
          q.level3TitleIncomeEarningAbility: level3TitleIncomeEarningAbilityItem1Data,
        },
    });

    // Adding individual and team perspective to root level data
    _enteredData = [level2TitleIndividualData, level2TitleGroupData];

    pu.printd("");
    pu.printd("_enteredData");
    pu.printd("$_enteredData");
    pu.printd("");
  }

  void print2CSV() async 
  {
    dataStructureBuilding();

    // Transforming the data into a CSV-friendly form
    var preCSVDataIndividualPerspective = cu.dataToPreCSV(perspectiveData: _enteredData[0]);
    var preCSVDataGroupPerspective = cu.dataToPreCSV(perspectiveData: _enteredData[1]);

    pu.printd("preCSVDataIndividualPerspective");
    pu.printd("$preCSVDataIndividualPerspective");
    pu.printd("");
    pu.printd("preCSVDataGroupPerspective");
    pu.printd("$preCSVDataGroupPerspective");
    pu.printd("");

    List<dynamic> csvDataIndividualPerspective = cu.preCSVToCSVData(preCSVData: preCSVDataIndividualPerspective);
    List<dynamic> csvDataGroupPerspective = cu.preCSVToCSVData(preCSVData: preCSVDataGroupPerspective);
    // Printing to CSV
    String? pathToCSVFile = await cu.printToCSV(csvDataIndividualPerspective: csvDataIndividualPerspective, csvDataGroupPerspective: csvDataGroupPerspective);
    pu.printd("pathToCSVFile: $pathToCSVFile");
    // Saving the dashboard data if filePath not null
    if (pathToCSVFile != null)
    {
      du.saveDashboardData(typeOfContextData: DashboardUtils.contextAnalysesContext, analysisTitle: _analysisTitle, pathToCSVFile: pathToCSVFile);
    }
  }

  @override
  void initState() {
    super.initState();

    // Listeners to know when some elements receive focus
    _saveDataButtonFocusNode.addListener(
      (){
        pu.printd("Button used to save data reached");
        // restoring focus capability to the bottom items
        widget.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability(true);
        // data helping to know if the user tab navigates back up
        movingThroughButton = true;
      }
    );

    _analysisTitleFocusNode.addListener(
      (){
        pu.printd("Analysis title text field reached");
        if (movingThroughButton)
        {
          pu.printd("Tab navigating up");
          // removing focus capability to the bottom items
          widget.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability(false);
          movingThroughButton = false;
        }
      }
    );
    
  }

  @override
  void dispose()
  {
    _saveDataButtonFocusNode.dispose();
    _analysisTitleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    final ScrollController scrollController = ScrollController();
    double scrollbarThickness = 0;

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
            Center
            (
              child: 
              CustomHeading
              (
                headingText: 'Context analysis',
                headingLevel: 1,
              ),
            ),
            Gap(40),




            //************** ExpansionTile diplaying the individual perspective: beginning **************//
            Semantics
            (
              toggled: false, // seems necessary (as of 26/01/11) to have 'button' voiced on Android
              button: true, // with tooltip, useful for NVDA
              tooltip: "Zone to click to expand data",
              label: "Zone to click to expand data", // for Orca
              expanded: _isIndividualAreaPerspectiveExpanded, // useful for NVDA, not voiced by Narrator at the time of coding (26/01/11)
              child:
              ExpansionTile
              ( 
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                internalAddSemanticForOnTap: true, 
                onExpansionChanged: (value) 
                {
                  setState(() {_isIndividualAreaPerspectiveExpanded = value;});
                  widget.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability(!(_isIndividualAreaPerspectiveExpanded || _isGroupAreaPerspectiveExpanded));
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
                    headingText: q.level3TitleBalanceIssue,
                    headingLevel: 3,
                    headingAlignment: TextAlign.left,
                  ),
                  CustomCheckBoxWithTextField
                  (
                    checkboxText: q.level3TitleBalanceIssueItem1,
                    textFieldHintText: pleaseDescribeTextHousehold,
                    parentWidgetCheckboxValueCallBackFunction: _setStudiesHouseholdBalanceCheckboxState,
                    parentWidgetTextFieldValueCallBackFunction: _setStudiesHouseholdBalanceTextFieldState,
                  ),
                  CustomCheckBoxWithTextField
                  (
                    checkboxText: q.level3TitleBalanceIssueItem2,
                    textFieldHintText: pleaseDescribeTextHousehold,
                    parentWidgetCheckboxValueCallBackFunction: _setAccessingIncomeHouseholdBalanceCheckboxState,
                    parentWidgetTextFieldValueCallBackFunction: _setAccessingIncomeHouseholdBalanceTextFieldState,
                  ),
                  CustomCheckBoxWithTextField
                  (
                    checkboxText: q.level3TitleBalanceIssueItem3,
                    textFieldHintText: pleaseDescribeTextHousehold,
                    parentWidgetCheckboxValueCallBackFunction: _setEarningIncomeHouseholdBalanceCheckboxState,
                    parentWidgetTextFieldValueCallBackFunction: _setEarningIncomedHouseholdBalanceTextFieldState,
                  ),
                  CustomCheckBoxWithTextField
                  (
                    checkboxText: q.level3TitleBalanceIssueItem4,
                    textFieldHintText: pleaseDescribeTextHousehold,
                    parentWidgetCheckboxValueCallBackFunction: _setHelpingOthersdBalanceCheckboxState,
                    parentWidgetTextFieldValueCallBackFunction: _setHelpingOthersHouseholdBalanceTextFieldState,
                  ),
                  Gap(preAndPostLevel3DividerGap),
                  Divider(thickness: betweenLevel3DividerThickness),
                  Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleWorkplaceIssue,
                    headingLevel: 3,
                    headingAlignment: TextAlign.left,
                  ),
                  CustomCheckBoxWithTextField
                  (
                    checkboxText: q.level3TitleWorkplaceIssueItem1,
                    textFieldHintText: pleaseDescribeTextWorkplace,
                    parentWidgetCheckboxValueCallBackFunction: _setMoreAppreciatedAtWorkCheckboxState,
                    parentWidgetTextFieldValueCallBackFunction: _setMoreAppreciatedAtWorkTextFieldState,
                  ),
                  CustomCheckBoxWithTextField
                  (
                    checkboxText: q.level3TitleWorkplaceIssueItem2,
                    textFieldHintText: pleaseDescribeTextWorkplace,
                    parentWidgetCheckboxValueCallBackFunction: _setRemainingAppreciatedAtWorkCheckboxState,
                    parentWidgetTextFieldValueCallBackFunction: _setRemainingAppreciatedAtWorkTextFieldState,
                  ),
                  Gap(preAndPostLevel3DividerGap),
                  Divider(thickness: betweenLevel3DividerThickness),
                  Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleLegacyIssue,
                    headingLevel: 3,
                    headingAlignment: TextAlign.left,
                  ),
                  CustomCheckBoxWithTextField
                  (
                    checkboxText: q.level3TitleLegacyIssueItem1,
                    textFieldHintText: pleaseDevelopOrTakeNotes,
                    parentWidgetCheckboxValueCallBackFunction: _setBetterLegaciesCheckboxState,
                    parentWidgetTextFieldValueCallBackFunction: _setBetterLegaciesTextFieldState,
                  ),
                  Gap(preAndPostLevel3DividerGap),
                  Divider(thickness: betweenLevel3DividerThickness),
                  Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleAnotherIssue,
                    headingLevel: 3,
                    headingAlignment: TextAlign.left,
                  ),
                  CustomPaddedTextField
                  (
                    textFieldHintText: pleaseDevelopOrTakeNotes,
                    textFieldMaxLength: FormUtils.chars1Page,
                    textFieldCounter: FormUtils.absentCounter,
                    parentWidgetTextFieldValueCallBackFunction:_setAnotherIssueTextFieldState,
                  ),
                ]
              ),
            ),
            //************** ExpansionTile diplaying the individual perspective: end **************//
            
            Gap(preAndPostLevel2DividerGap),
            Divider(thickness: betweenLevel2DividerThickness),
            Gap(preAndPostLevel2DividerGap),



            /**** Beginning of the team-related analysis ****/
            //************** ExpansionTile diplaying the group perspective: beginning **************//
            Semantics
            ( 
              toggled: false, // seems necessary (as of 26/01/11) to have 'button' voiced on Android
              button: true, // with tooltip, useful for NVDA
              tooltip: "Zone to click to expand data",
              label: "Zone to click to expand data", // for Orca
              expanded: _isGroupAreaPerspectiveExpanded, // useful for NVDA, not voiced by Narrator at the time of coding (26/01/11)
              child:
              ExpansionTile
              ( 
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                internalAddSemanticForOnTap: true, 
                onExpansionChanged: (value) 
                {setState(() 
                {
                  _isGroupAreaPerspectiveExpanded = value;
                  widget.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability(!(_isIndividualAreaPerspectiveExpanded || _isGroupAreaPerspectiveExpanded));
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
                    headingAlignment: TextAlign.left,
                  ),
                  CustomPaddedTextField
                  (
                    textFieldHintText: pleaseDescribeTextGroups,
                    textFieldMaxLength: FormUtils.chars1Page,
                    textFieldCounter: FormUtils.absentCounter,
                    parentWidgetTextFieldValueCallBackFunction: _setProblemsTheGroupsAreTryingToSolveTextFieldState,
                  ),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleSameProblem,
                    headingLevel: 3,
                    headingAlignment: TextAlign.left,
                  ),
                  Gap(level3AndSegmentedButtonGap),
                  CustomSegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHintText: pleaseDevelopOrTakeNotes,
                    parentWidgetSegmentedButtonValueCallBackFunction: _setSameProblemsSegmentedButtonState,
                    parentWidgetTextFieldValueCallBackFunction: _setSameProblemsTextFieldState,
                  ),

                  Gap(preAndPostLevel3DividerGap),
                  Divider(thickness: betweenLevel3DividerThickness),
                  Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleHarmonyAtHome,
                    headingLevel: 3,
                    headingAlignment: TextAlign.left,
                  ),
                  Gap(level3AndSegmentedButtonGap),
                  CustomSegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHintText: pleaseDevelopOrTakeNotes,
                    parentWidgetSegmentedButtonValueCallBackFunction: _setHarmonyHomeSegmentedButtonState,
                    parentWidgetTextFieldValueCallBackFunction: _setHarmonyHomeTextFieldState,
                  ),

                  Gap(preAndPostLevel3DividerGap),
                  Divider(thickness: betweenLevel3DividerThickness),
                  Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleAppreciabilityAtWork,
                    headingLevel: 3,
                    headingAlignment: TextAlign.left,
                  ),
                  Gap(level3AndSegmentedButtonGap),
                  CustomSegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHintText: pleaseDevelopOrTakeNotes,
                    parentWidgetSegmentedButtonValueCallBackFunction: _setAppreciabilityAtWorkSegmentedButtonState,
                    parentWidgetTextFieldValueCallBackFunction: _setAppreciabilityAtWorkTextFieldState,
                  ),

                  Gap(preAndPostLevel3DividerGap),
                  Divider(thickness: betweenLevel3DividerThickness),
                  Gap(preAndPostLevel3DividerGap),

                  /**** ➡️ Sub-point  ****/
                  CustomHeading
                  (
                    headingText: q.level3TitleIncomeEarningAbility,
                    headingLevel: 3,
                    headingAlignment: TextAlign.left,
                  ),
                  CustomSegmentedButtonWithTextField
                  (
                    textOption1: 'Yes',
                    textOption2: 'No',
                    textOption3: "I don't know",
                    textOptionsfontSize: 16,
                    textFieldHintText: pleaseDevelopOrTakeNotes,
                    parentWidgetSegmentedButtonValueCallBackFunction: _setEarningAbilitySegmentedButtonState,
                    parentWidgetTextFieldValueCallBackFunction: _setEarningAbilityTextFieldState,
                  ),
                ]
              ),
            ),
            //************** ExpansionTile diplaying the group perspective: end **************//

            Gap(preAndPostLevel2DividerGap),
            Divider(thickness: betweenLevel2DividerThickness),
            Gap(preAndPostLevel2DividerGap),
            
            //********** Data saving ************//
            Center
            (
              child: 
              Column
              (
                children: 
                [
                  TextField
                  (
                    focusNode: _analysisTitleFocusNode,
                    textAlign: TextAlign.center,
                    style: dataSavingStyle, // TODO: to clean
                    decoration: InputDecoration
                    (
                      hint: Text("Please enter a title for this analysis"),
                      hintStyle: dataSavingStyle, // TODO: to clean
                    ),
                    maxLength: 150,
                    onChanged: _setAnalysisTitleTextFieldState,
                  ),
                  Focus(
                    onKeyEvent: (FocusNode node, KeyEvent event)
                    {
                      if(event.logicalKey == LogicalKeyboardKey.tab
                          && HardwareKeyboard.instance.isShiftPressed)
                          {
                            pu.printd("Shift-tab detected");
                            widget.parentWidgetCallbackFunctionForContextAnalysisPageToSetFocusability(false);
                            return KeyEventResult.ignored;
                          }

                      return KeyEventResult.ignored;
                    },
                  child: ElevatedButton
                  (
                    focusNode: _saveDataButtonFocusNode,
                    // and removed only at data saving time
                    onPressed: print2CSV,
                    // https://gemini.google.com/app/d67570647b3006af
                    
                    child: 
                    Text
                    (
                      'Click to save your data in CSV, \nspreadsheet-compatible format',
                      style: dataSavingStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ),

                  // Gap(20),
                  // Divider(thickness: 3),

                  /* Debug section */
                  // Gap(20),
                  // Divider(thickness: 3),
                  // Gap(20),
                  // Text('Debug:'),
                  // Text("Studies / Household Balance: $_studiesHouseholdBalanceCheckbox, text: $_studiesHouseholdBalanceTextFieldContent"),
                  // Text("Accessing Income / Household Balance: $_accessingIncomeHouseholdBalanceCheckbox, text: $_accessingIncomeHouseholdBalanceTextFieldContent"),
                  // Text("Earning Income / Household Balance: $_earningIncomeHouseholdBalanceCheckbox, text: $_earningIncomeHouseholdBalanceTextFieldContent"),
                  // Text("Helping Others / Household Balance: $_helpingOthersHouseholdBalanceCheckbox , text: $_helpingOthersHouseholdBalanceTextFieldContent"),

                  // Text("More Appreciated At Work: $_moreAppreciatedAtWorkCheckbox, text: $_moreAppreciatedAtWorkTextFieldContent"),
                  // Text("Remaining Appreciated At Work: $_remainingAppreciatedAtWorkCheckbox, text: $_remainingAppreciatedAtWorkTextFieldContent"),

                  // Text("Better Legacies: $_betterLegaciesCheckbox, text: $_betterLegaciesTextFieldContent"),

                  // Text("Other Issue: text: $_anotherIssueTextFieldContent"),

                  // Text("Problems The Groups Are Trying To Solve: text: $_problemsTheGroupsAreTryingToSolveTextFieldContent"),

                  // Text("Same problems being solved?:  $_sameProblemsCurrentSelection.toString(), text: $_sameProblemsTextFieldContent"),

                  // Text("Harmony home?:  $_harmonyHomeCurrentSelection.toString(), text: $_harmonyHomeTextFieldContent"),

                  // Text("Appreciability at work:  $_appreciabilityAtWorkCurrentSelection.toString(), text: $_appreciabilityAtWorkTextFieldContent"),

                  // Text("Earning ability:  $_earningAbilityCurrentSelection.toString(), text: $_earningAbilityTextFieldContent"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
