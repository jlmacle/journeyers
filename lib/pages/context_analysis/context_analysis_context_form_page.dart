import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_heading.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_checkbox_list_tile_with_text_field.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_padded_text_field.dart';
import 'package:journeyers/common_widgets/interaction_and_inputs/custom_segmented_button_with_text_field.dart';
import 'package:journeyers/core/utils/csv/csv_utils.dart';
import 'package:journeyers/core/utils/dashboard/dashboard_utils.dart';
import 'package:journeyers/core/utils/form/form_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_context_form_questions.dart';

class ContextAnalysisContextFormPage extends StatefulWidget {
  
  const ContextAnalysisContextFormPage({super.key});

  @override
  State<ContextAnalysisContextFormPage> createState() => _ContextAnalysisContextFormPageState();
}

class _ContextAnalysisContextFormPageState extends State<ContextAnalysisContextFormPage> 
{
  // Utility classes
  CSVUtils csvUtils = CSVUtils();

  // Data structure
  List<LinkedHashMap<String, dynamic>> _enteredData = [];

  //*****************    State related code    **********************//
  bool _studiesHouseholdBalanceCheckbox = false;
  String _studiesHouseholdBalanceTextFieldContent = "";

  bool _accessingIncomeHouseholdBalanceCheckbox = false; 
  String _accessingIncomeHouseholdBalanceTextFieldContent = "";

  bool _earningIncomeHouseholdBalanceCheckbox = false; 
  String _earningIncomeHouseholdBalanceTextFieldContent = "";

  bool _helpingOthersHouseholdBalanceCheckbox = false;  
  String _helpingOthersHouseholdBalanceTextFieldContent = "";

  bool _moreAppreciatedAtWorkCheckbox = false;
  String _moreAppreciatedAtWorkTextFieldContent = "";

  bool _remainingAppreciatedAtWorkCheckbox = false;  
  String _remainingAppreciatedAtWorkTextFieldContent = "";

  bool _betterLegaciesCheckbox = false;  
  String _betterLegaciesTextFieldContent = "";

  String _anotherIssueTextFieldContent = "";

  String _problemsTheGroupsAreTryingToSolveTextFieldContent = "";
 
  Set<String> _sameProblemsCurrentSelection = {};
  String _sameProblemsTextFieldContent = "";

  Set<String> _harmonyHomeCurrentSelection = {};
  String _harmonyHomeTextFieldContent = "";

  Set<String> _appreciabilityAtWorkCurrentSelection = {};
  String _appreciabilityAtWorkTextFieldContent = "";

  Set<String> _earningAbilityCurrentSelection = {};
  String _earningAbilityTextFieldContent = "";

  // Session title
  String _analysisTitle = "";

  // Callback methods from the form page
  // Individual perspective
  _setStudiesHouseholdBalanceCheckboxState(bool? newValue){setState(() {  _studiesHouseholdBalanceCheckbox = newValue!;});}
  _setStudiesHouseholdBalanceTextFieldState(String newValue){setState(() {_studiesHouseholdBalanceTextFieldContent = newValue;});}

  _setAccessingIncomeHouseholdBalanceCheckboxState(bool? newValue){setState(() { _accessingIncomeHouseholdBalanceCheckbox = newValue!;});}  
  _setAccessingIncomeHouseholdBalanceTextFieldState(String newValue){setState(() {_accessingIncomeHouseholdBalanceTextFieldContent = newValue;});}

  _setEarningIncomeHouseholdBalanceCheckboxState(bool? newValue){setState(() { _earningIncomeHouseholdBalanceCheckbox = newValue!;});}  
  _setEarningIncomedHouseholdBalanceTextFieldState(String newValue){setState(() {_earningIncomeHouseholdBalanceTextFieldContent = newValue;});}

  _setHelpingOthersdBalanceCheckboxState(bool? newValue){setState(() { _helpingOthersHouseholdBalanceCheckbox = newValue!;});}  
  _setHelpingOthersHouseholdBalanceTextFieldState(String newValue){setState(() {_helpingOthersHouseholdBalanceTextFieldContent = newValue;});}

  _setMoreAppreciatedAtWorkCheckboxState(bool? newValue){setState(() { _moreAppreciatedAtWorkCheckbox = newValue!;});}  
  _setMoreAppreciatedAtWorkTextFieldState(String newValue){setState(() {_moreAppreciatedAtWorkTextFieldContent = newValue;});}

  _setRemainingAppreciatedAtWorkCheckboxState(bool? newValue){setState(() { _remainingAppreciatedAtWorkCheckbox = newValue!;});}  
  _setRemainingAppreciatedAtWorkTextFieldState(String newValue){setState(() {_remainingAppreciatedAtWorkTextFieldContent = newValue;});}

  _setBetterLegaciesCheckboxState(bool? newValue){setState(() { _betterLegaciesCheckbox = newValue!;});}  
  _setBetterLegaciesTextFieldState(String newValue){setState(() {_betterLegaciesTextFieldContent = newValue;});}

  _setAnotherIssueTextFieldState(String newValue){setState(() {_anotherIssueTextFieldContent = newValue;});}


  // Team perspective
  _setProblemsTheGroupsAreTryingToSolveTextControllerTextFieldState(String newValue){setState(() {_problemsTheGroupsAreTryingToSolveTextFieldContent = newValue;});}

  _setSameProblemsSegmentedButtonState(Set<String>? values){setState(() {_sameProblemsCurrentSelection = values!;});}
  _setSameProblemsTextFieldState(String newValue){setState(() {_sameProblemsTextFieldContent = newValue;});}


  _setHarmonyHomeSegmentedButtonState(Set<String>? values){setState(() {_harmonyHomeCurrentSelection = values!;});}
  _setHarmonyHomeTextFieldState(String newValue){setState(() {_harmonyHomeTextFieldContent= newValue;});}

  _setAppreciabilityAtWorkSegmentedButtonState(Set<String>? values){setState(() {_appreciabilityAtWorkCurrentSelection = values!;});}
  _setAppreciabilityAtWorkTextFieldState(String newValue){setState(() {_appreciabilityAtWorkTextFieldContent= newValue;});}


  _setEarningAbilitySegmentedButtonState(Set<String>? values){setState(() {_earningAbilityCurrentSelection = values!;});}
  _setEarningAbilityTextFieldState(String newValue){setState(() {_earningAbilityTextFieldContent= newValue;});}

  _setAnalysisTitleTextFieldState(String newValue){setState(() {_analysisTitle= newValue;});}

  //*****************    Data structure related code    **********************//
  void dataStructureBuild()
  {

    //************************* Individual perspective ******************************/
    //Individual level: balance issue
    // level3TitleBalanceIssueItem1Data
    LinkedHashMap<String, dynamic> level3TitleBalanceItem1Data = LinkedHashMap<String, dynamic>.from({checkbox:"false",textField:""});
    level3TitleBalanceItem1Data[checkbox] = _studiesHouseholdBalanceCheckbox;
    level3TitleBalanceItem1Data[textField] = _studiesHouseholdBalanceTextFieldContent;    
    // level3TitleBalanceIssueItem2Data
    LinkedHashMap<String, dynamic> level3TitleBalanceItem2Data = LinkedHashMap<String, dynamic>.from({checkbox:"false",textField:""});
    level3TitleBalanceItem2Data[checkbox] = _accessingIncomeHouseholdBalanceCheckbox;
    level3TitleBalanceItem2Data[textField] = _accessingIncomeHouseholdBalanceTextFieldContent;   
    // level3TitleBalanceIssueItem3Data
    LinkedHashMap<String, dynamic> level3TitleBalanceItem3Data = LinkedHashMap<String, dynamic>.from({checkbox:"false",textField:""});
    level3TitleBalanceItem3Data[checkbox] = _earningIncomeHouseholdBalanceCheckbox;
    level3TitleBalanceItem3Data[textField] = _earningIncomeHouseholdBalanceTextFieldContent;
    // level3TitleBalanceIssueItem4Data
    LinkedHashMap<String, dynamic> level3TitleBalanceItem4Data = LinkedHashMap<String, dynamic>.from({checkbox:"false",textField:""});
    level3TitleBalanceItem4Data[checkbox] = _helpingOthersHouseholdBalanceCheckbox;
    level3TitleBalanceItem4Data[textField] = _helpingOthersHouseholdBalanceTextFieldContent;
    // level3TitleBalanceIssueData
    LinkedHashMap<String, dynamic> level3TitleBalanceIssueData 
    = LinkedHashMap<String, dynamic>.from({level3TitleBalanceIssueItem1:level3TitleBalanceItem1Data,level3TitleBalanceIssueItem2:level3TitleBalanceItem2Data, 
                                           level3TitleBalanceIssueItem3:level3TitleBalanceItem3Data,level3TitleBalanceIssueItem4:level3TitleBalanceItem4Data});

    //Individual level: workplace issue
    // level3TitleWorkplaceIssueItem1Data
    LinkedHashMap<String, dynamic> level3TitleWorkplaceIssueItem1Data = LinkedHashMap<String, dynamic>.from({checkbox:"false",textField:""});
    level3TitleWorkplaceIssueItem1Data[checkbox] = _moreAppreciatedAtWorkCheckbox;
    level3TitleWorkplaceIssueItem1Data[textField] = _moreAppreciatedAtWorkTextFieldContent;
    // level3TitleWorkplaceIssueItem2Data
    LinkedHashMap<String, dynamic> level3TitleWorkplaceIssueItem2Data = LinkedHashMap<String, dynamic>.from({checkbox:"false",textField:""});
    level3TitleWorkplaceIssueItem2Data[checkbox] = _remainingAppreciatedAtWorkCheckbox;
    level3TitleWorkplaceIssueItem2Data[textField] = _remainingAppreciatedAtWorkTextFieldContent; 
    // level3TitleWorkplaceIssueData
    LinkedHashMap<String, dynamic> level3TitleWorkplaceIssueData 
    = LinkedHashMap<String, dynamic>.from({level3TitleWorkplaceIssueItem1:level3TitleWorkplaceIssueItem1Data,level3TitleWorkplaceIssueItem2:level3TitleWorkplaceIssueItem2Data});

    //Individual level: legacy issue
    // level3TitleLegacyIssueItem1
    LinkedHashMap<String, dynamic> level3TitleLegacyIssueItem1Data = LinkedHashMap<String, dynamic>.from({checkbox:"false",textField:""});
    level3TitleLegacyIssueItem1Data[checkbox] = _betterLegaciesCheckbox;
    level3TitleLegacyIssueItem1Data[textField] = _betterLegaciesTextFieldContent;
    // level3TitleWorkplaceIssueData
    LinkedHashMap<String, dynamic> level3TitleLegacyIssueData 
    = LinkedHashMap<String, dynamic>.from({level3TitleLegacyIssueItem1:level3TitleLegacyIssueItem1Data});

    //Individual level: another issue
    // level3TitleAnotherIssueItem1
    LinkedHashMap<String, dynamic> level3TitleAnotherIssueItem1Data = LinkedHashMap<String, dynamic>.from({textField:""});
    level3TitleAnotherIssueItem1Data[textField] = _anotherIssueTextFieldContent;
 
    // Adding to to the level2TitleIndividual level
    // level2TitleIndividualData
    // Different pattern for "level3TitleAnotherIssue:level3TitleLegacyIssueItem1Data"
    LinkedHashMap<String, dynamic> level2TitleIndividualData = 
    LinkedHashMap<String, dynamic>.from(
      {level2TitleIndividual:{level3TitleBalanceIssue:level3TitleBalanceIssueData,level3TitleWorkplaceIssue:level3TitleWorkplaceIssueData,
                              level3TitleLegacyIssue:level3TitleLegacyIssueData,level3TitleAnotherIssue:level3TitleAnotherIssueItem1Data}});

    //************************* Group/Team perspective ******************************/
    //Group/team level: 
    // level3TitleGroupsProblematicsItem1
    LinkedHashMap<String, dynamic>  level3TitleGroupsProblematicsItem1Data = LinkedHashMap<String, dynamic>.from({textField:""});
    level3TitleGroupsProblematicsItem1Data[textField] = _problemsTheGroupsAreTryingToSolveTextFieldContent;

    // level3TitleSameProblemsItem1
    LinkedHashMap<String, dynamic>  level3TitleSameProblemsItem1Data = LinkedHashMap<String, dynamic>.from({segmentedButton:"", textField:""});
    if (_sameProblemsCurrentSelection.length == 1) {level3TitleSameProblemsItem1Data[segmentedButton] = _sameProblemsCurrentSelection.first;}
    else {level3TitleSameProblemsItem1Data[segmentedButton] = "";}
    level3TitleSameProblemsItem1Data[textField] = _sameProblemsTextFieldContent;

    // level3TitleHarmonyAtHomeItem1
    LinkedHashMap<String, dynamic>  level3TitleHarmonyAtHomeItems1Data = LinkedHashMap<String, dynamic>.from({segmentedButton:"", textField:""});
    if(_harmonyHomeCurrentSelection.length == 1)  {level3TitleHarmonyAtHomeItems1Data[segmentedButton] = _harmonyHomeCurrentSelection.first;}
    else {level3TitleHarmonyAtHomeItems1Data[segmentedButton] = "";}
    level3TitleHarmonyAtHomeItems1Data[textField] = _harmonyHomeTextFieldContent;

    // // level3TitleAppreciabilityAtWorkItem1
    LinkedHashMap<String, dynamic>  level3TitleAppreciabilityAtWorkItem1Data = LinkedHashMap<String, dynamic>.from({segmentedButton:"", textField:""});
    if (_appreciabilityAtWorkCurrentSelection.length == 1) {level3TitleAppreciabilityAtWorkItem1Data[segmentedButton] = _appreciabilityAtWorkCurrentSelection.first;}
    else {level3TitleAppreciabilityAtWorkItem1Data[segmentedButton] = "";}
    level3TitleAppreciabilityAtWorkItem1Data[textField] = _appreciabilityAtWorkTextFieldContent;

    // level3TitleIncomeEarningAbilityItem1
    LinkedHashMap<String, dynamic>  level3TitleIncomeEarningAbilityItem1Data = LinkedHashMap<String, dynamic>.from({segmentedButton:"", textField:""});
    if(_earningAbilityCurrentSelection.length == 1)  {level3TitleIncomeEarningAbilityItem1Data[segmentedButton] = _earningAbilityCurrentSelection.first;}
    else {level3TitleIncomeEarningAbilityItem1Data[segmentedButton] = "";}
    level3TitleIncomeEarningAbilityItem1Data[textField] = _earningAbilityTextFieldContent;

    // Adding to to the level2TitleGroup level
    // level2TitleGroupData
    LinkedHashMap<String, dynamic> level2TitleTeamData = 
    LinkedHashMap<String, dynamic>.from(
      {level2TitleGroup:{level3TitleGroupsProblematics:level3TitleGroupsProblematicsItem1Data,level3TitleSameProblem:level3TitleSameProblemsItem1Data,
      level3TitleHarmonyAtHome:level3TitleHarmonyAtHomeItems1Data,level3TitleAppreciabilityAtWork:level3TitleAppreciabilityAtWorkItem1Data,
      level3TitleIncomeEarningAbility:level3TitleIncomeEarningAbilityItem1Data}});
     
    // Adding individual and team perspective to root level data
    _enteredData = [level2TitleIndividualData, level2TitleTeamData];

    printd("");
    printd("_enteredData");
    printd("$_enteredData");
    printd("");
    
  }

  void print2CSV() async
  {
    setState(() {
      // Building the data from the form
      dataStructureBuild();
    });
    // Transforming the data into a CSV-friendly form
    var preCSVDataIndividualPerspective = csvUtils.dataToPreCSV(_enteredData[0]);
    var preCSVDataTeamPerspective = csvUtils.dataToPreCSV(_enteredData[1]);

    printd("preCSVDataIndividualPerspective");
    printd("$preCSVDataIndividualPerspective");
    printd("");
    printd("preCSVDataTeamPerspective");
    printd("$preCSVDataTeamPerspective");
    printd("");

    List<dynamic> csvDataIndividualPerspective = csvUtils.preCSVToCSVData(preCSVDataIndividualPerspective);
    List<dynamic> csvDataTeamPerspective = csvUtils.preCSVToCSVData(preCSVDataTeamPerspective);
    // Printing to CSV
    String? filePath = await csvUtils.printToCSV(csvDataIndividualPerspective, csvDataTeamPerspective);
    printd("filePath:$filePath");
    // Saving the dashboard data if filePath not null
    if (filePath != null) dashboardDataSaving(contextAnalysesData, _analysisTitle, filePath);

  }

  
  @override
  Widget build(BuildContext context) 
  {
   
    final ScrollController scrollController = ScrollController();
    double scrollbarThickness = 0;

    // TODO: to modify for tablets
    if (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS) scrollbarThickness = 15;
    
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
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: 
          [ 
           
            //*********** Form ***********//
            Center(
              child: CustomHeading
              (
                headingTitle: 'Context analysis',
                headingLevel: 1,
              ),
            ),
            Gap(40),
            Center
            (
              child:CustomHeading
              (
                headingTitle: level2TitleIndividual,
                headingLevel: 2,
              ),
            ),
            Gap(postHeaderLevel2Gap),

            /**** ➡️ Sub-point  ****/
            CustomHeading
            (
              headingTitle: level3TitleBalanceIssue,
              headingLevel: 3,
              headingAlignment: TextAlign.left,
            ),
            CustomCheckBoxWithTextField
            (
              checkboxText: level3TitleBalanceIssueItem1, textFieldHintText: pleaseDescribeTextHousehold, 
              parentWidgetCheckboxValueCallBackFunction: _setStudiesHouseholdBalanceCheckboxState,
              parentWidgetTextFieldValueCallBackFunction: _setStudiesHouseholdBalanceTextFieldState
            ),
            CustomCheckBoxWithTextField
            (
              checkboxText: level3TitleBalanceIssueItem2, 
              textFieldHintText: pleaseDescribeTextHousehold,
              parentWidgetCheckboxValueCallBackFunction: _setAccessingIncomeHouseholdBalanceCheckboxState,
              parentWidgetTextFieldValueCallBackFunction: _setAccessingIncomeHouseholdBalanceTextFieldState
            ),
            CustomCheckBoxWithTextField
            (
              checkboxText: level3TitleBalanceIssueItem3, textFieldHintText: pleaseDescribeTextHousehold,
              parentWidgetCheckboxValueCallBackFunction: _setEarningIncomeHouseholdBalanceCheckboxState,
              parentWidgetTextFieldValueCallBackFunction: _setEarningIncomedHouseholdBalanceTextFieldState
            ),
            CustomCheckBoxWithTextField
            (
              checkboxText: level3TitleBalanceIssueItem4, textFieldHintText: pleaseDescribeTextHousehold,
              parentWidgetCheckboxValueCallBackFunction: _setHelpingOthersdBalanceCheckboxState ,
              parentWidgetTextFieldValueCallBackFunction: _setHelpingOthersHouseholdBalanceTextFieldState
            ),
            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

            /**** ➡️ Sub-point  ****/
            CustomHeading
            (
              headingTitle: level3TitleWorkplaceIssue,
              headingLevel: 3,
              headingAlignment: TextAlign.left,
            ),
            CustomCheckBoxWithTextField
            (
              checkboxText: level3TitleWorkplaceIssueItem1, textFieldHintText: pleaseDescribeTextWorkplace,
              parentWidgetCheckboxValueCallBackFunction:  _setMoreAppreciatedAtWorkCheckboxState,
              parentWidgetTextFieldValueCallBackFunction: _setMoreAppreciatedAtWorkTextFieldState
            ),
            CustomCheckBoxWithTextField
            (
              checkboxText: level3TitleWorkplaceIssueItem2, textFieldHintText: pleaseDescribeTextWorkplace,
              parentWidgetCheckboxValueCallBackFunction: _setRemainingAppreciatedAtWorkCheckboxState ,
              parentWidgetTextFieldValueCallBackFunction: _setRemainingAppreciatedAtWorkTextFieldState
            ),
            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

           
            /**** ➡️ Sub-point  ****/
            CustomHeading
            (
              headingTitle: level3TitleLegacyIssue,
              headingLevel: 3,
              headingAlignment: TextAlign.left,
            ),
            CustomCheckBoxWithTextField
            (
              checkboxText: level3TitleLegacyIssueItem1, textFieldHintText: pleaseDevelopOrTakeNotes,
              parentWidgetCheckboxValueCallBackFunction:  _setBetterLegaciesCheckboxState,
              parentWidgetTextFieldValueCallBackFunction: _setBetterLegaciesTextFieldState
            ),
            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

            /**** ➡️ Sub-point  ****/
            CustomHeading
            (
              headingTitle: level3TitleAnotherIssue,
              headingLevel: 3,
              headingAlignment: TextAlign.left,
            ),
            CustomPaddedTextField
            ( textFieldHintText: pleaseDevelopOrTakeNotes, 
              textFieldMaxLength: chars1Page, textFieldCounter: absentCounter,
              parentWidgetTextFieldValueCallBackFunction: _setAnotherIssueTextFieldState),

            Gap(preAndPostLevel2DividerGap),
            Divider(thickness: betweenLevel2DividerThickness),
            Gap(preAndPostLevel2DividerGap),

            /**** Beginning of the team-related analysis ****/
            Center
            (
              child:CustomHeading
              (
                headingTitle: level2TitleGroup,
                headingLevel: 2,
              ),
            ),
            Gap(postHeaderLevel2Gap),

            CustomHeading
            (
              headingTitle: level3TitleGroupsProblematics,
              headingLevel: 3,
              headingAlignment: TextAlign.left,
            ),
            CustomPaddedTextField
            (
              textFieldHintText: pleaseDescribeTextGroups, 
              textFieldMaxLength: chars1Page, textFieldCounter: absentCounter,
              parentWidgetTextFieldValueCallBackFunction: _setProblemsTheGroupsAreTryingToSolveTextControllerTextFieldState
            ),

            /**** ➡️ Sub-point  ****/
            CustomHeading
            (
              headingTitle: level3TitleSameProblem,
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
              headingTitle: level3TitleHarmonyAtHome,
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
              parentWidgetTextFieldValueCallBackFunction:  _setHarmonyHomeTextFieldState,
            ),

            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

            /**** ➡️ Sub-point  ****/
            CustomHeading
            (
              headingTitle: level3TitleAppreciabilityAtWork,
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
              headingTitle: level3TitleIncomeEarningAbility,
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
             //********** Data saving ************//
            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),
            Center
            (
              child: Container(
                child: Column(
                  children: [
                    CustomPaddedTextField
                    (  
                      textAlignment: TextAlign.center,                    
                      textFieldHintText: "Please enter a title for this analysis",
                      textFieldMaxLength: 150,
                      parentWidgetTextFieldValueCallBackFunction: _setAnalysisTitleTextFieldState,
                    ),
                    ElevatedButton
                    (
                      onPressed: print2CSV, 
                      child: Text('Click to save your data in CSV, \nspreadsheet-compatible format', style: dataSavingStyle, textAlign: TextAlign.center,)
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
              )
              ),

          ],
        ),
      )
    );
  }
}