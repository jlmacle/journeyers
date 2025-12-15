import 'dart:collection';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:journeyers/app_themes.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_header.dart';
import 'package:journeyers/common_widgets/display_and_content/custom_text.dart';
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
  // Session title
  String _analysisTitle = "";
  // TextEditingController for the session title
  TextEditingController analysisTitleController = TextEditingController();

  String _errorMessageOtherIssue = "";
  String _errorMessageProblemsTheGroupsAreTryingToSolve = "";

 // Data structure
  List<LinkedHashMap<String, dynamic>> _enteredData = [];

  //*****************    State related code    **********************//
  // Example of data for checkbox with text field
  bool? _studiesHouseholdBalanceCheckbox;
  String? _studiesHouseholdBalanceTextFieldContent;

  bool? _accessingIncomeHouseholdBalanceCheckbox;  
  String? _accessingIncomeHouseholdBalanceTextFieldContent;

  bool? _earningIncomeHouseholdBalanceCheckbox;  
  String? _earningIncomeHouseholdBalanceTextFieldContent;

  bool? _helpingOthersHouseholdBalanceCheckbox;  
  String? _helpingOthersHouseholdBalanceTextFieldContent;

  bool? _moreAppreciatedAtWorkCheckbox;  
  String? _moreAppreciatedAtWorkTextFieldContent;

  bool? _remainingAppreciatedAtWorkCheckbox;  
  String? _remainingAppreciatedAtWorkTextFieldContent;

  bool? _betterLegaciesCheckbox;  
  String? _betterLegaciesTextFieldContent;
 
  final TextEditingController _otherIssueTextController = TextEditingController();

  final TextEditingController _problemsTheGroupsAreTryingToSolveTextController = TextEditingController();

  // Example of data for segmented button with text field
  Set<String> _currentSelectionSameProblems = {};
  final TextEditingController _sameProblemsTextController = TextEditingController();

  Set<String> _currentSelectionHarmonyHome = {};
  final TextEditingController _harmonyHomeTextController = TextEditingController();

  Set<String> _currentSelectionAppreciabilityAtWork = {};
  final TextEditingController _appreciabilityAtWorkTextController = TextEditingController();

  Set<String> _currentSelectionEarningAbility = {};
  final TextEditingController _earningAbilityTextController = TextEditingController();

  _setStudiesHouseholdBalanceCheckboxState(bool newValue){setState(() { _studiesHouseholdBalanceCheckbox = newValue;});}
  _setStudiesHouseholdBalanceTextFieldState(String newValue){setState(() {_studiesHouseholdBalanceTextFieldContent = newValue;});}

  _setAccessingIncomeHouseholdBalanceCheckboxState(bool newValue){setState(() { _accessingIncomeHouseholdBalanceCheckbox = newValue;});}  
  _setAccessingIncomeHouseholdBalanceTextFieldState(String newValue){setState(() {_accessingIncomeHouseholdBalanceTextFieldContent = newValue;});}

  _setEarningIncomeHouseholdBalanceCheckboxState(bool newValue){setState(() { _earningIncomeHouseholdBalanceCheckbox = newValue;});}  
  _setEarningIncomedHouseholdBalanceTextFieldState(String newValue){setState(() {_earningIncomeHouseholdBalanceTextFieldContent = newValue;});}

  _setHelpingOthersdBalanceCheckboxState(bool newValue){setState(() { _helpingOthersHouseholdBalanceCheckbox = newValue;});}  
  _setHelpingOthersHouseholdBalanceTextFieldState(String newValue){setState(() {_helpingOthersHouseholdBalanceTextFieldContent = newValue;});}

  _moreAppreciatedAtWorkCheckboxState(bool newValue){setState(() { _moreAppreciatedAtWorkCheckbox = newValue;});}  
  _moreAppreciatedAtWorkTextFieldState(String newValue){setState(() {_moreAppreciatedAtWorkTextFieldContent = newValue;});}

  _remainingAppreciatedAtWorkCheckboxState(bool newValue){setState(() { _remainingAppreciatedAtWorkCheckbox = newValue;});}  
  _remainingAppreciatedAtWorkTextFieldState(String newValue){setState(() {_remainingAppreciatedAtWorkTextFieldContent = newValue;});}

  _betterLegaciesCheckboxState(bool newValue){setState(() { _betterLegaciesCheckbox = newValue;});}  
  _betterLegaciesTextFieldState(String newValue){setState(() {_betterLegaciesTextFieldContent = newValue;});}


  @override
  void dispose() {
    // Disposal of all controllers
    _otherIssueTextController.dispose();
    _problemsTheGroupsAreTryingToSolveTextController.dispose();
    _sameProblemsTextController.dispose();
    _harmonyHomeTextController.dispose();
    _appreciabilityAtWorkTextController.dispose();
    _earningAbilityTextController.dispose();
    super.dispose();
  }

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
    level3TitleAnotherIssueItem1Data[textField] = _otherIssueTextController.text;
 
    // Adding to to the level2TitleIndividual level
    // level2TitleIndividualData
    // Different pattern for "level3TitleAnotherIssue:level3TitleLegacyIssueItem1Data"
    LinkedHashMap<String, dynamic> level2TitleIndividualData = 
    LinkedHashMap<String, dynamic>.from(
      {level2TitleIndividual:{level3TitleBalanceIssue:level3TitleBalanceIssueData, level3TitleWorkplaceIssue:level3TitleWorkplaceIssueData,
                              level3TitleLegacyIssue:level3TitleLegacyIssueData, level3TitleAnotherIssue:level3TitleAnotherIssueItem1Data}});

    //************************* Group/Team perspective ******************************/
    //Group/team level: 
    // level3TitleGroupsProblematicsItem1
    LinkedHashMap<String, dynamic>  level3TitleGroupsProblematicsItem1Data = LinkedHashMap<String, dynamic>.from({textField:""});
    level3TitleGroupsProblematicsItem1Data[textField] = _problemsTheGroupsAreTryingToSolveTextController.text;

    // level3TitleSameProblemsItem1
    LinkedHashMap<String, dynamic>  level3TitleSameProblemsItem1Data = LinkedHashMap<String, dynamic>.from({segmentedButton:"", textField:""});
    if (_currentSelectionSameProblems.length == 1) {level3TitleSameProblemsItem1Data[segmentedButton] = _currentSelectionSameProblems.first;}
    else {level3TitleSameProblemsItem1Data[segmentedButton] = "";}
    level3TitleSameProblemsItem1Data[textField] = _sameProblemsTextController.text;

    // level3TitleHarmonyAtHomeItem1
    LinkedHashMap<String, dynamic>  level3TitleHarmonyAtHomeItems1Data = LinkedHashMap<String, dynamic>.from({segmentedButton:"", textField:""});
    if(_currentSelectionHarmonyHome.length == 1)  {level3TitleHarmonyAtHomeItems1Data[segmentedButton] = _currentSelectionHarmonyHome.first;}
    else {level3TitleHarmonyAtHomeItems1Data[segmentedButton] = "";}
    level3TitleHarmonyAtHomeItems1Data[textField] = _harmonyHomeTextController.text;

    // // level3TitleAppreciabilityAtWorkItem1
    LinkedHashMap<String, dynamic>  level3TitleAppreciabilityAtWorkItem1Data = LinkedHashMap<String, dynamic>.from({segmentedButton:"", textField:""});
    if (_currentSelectionAppreciabilityAtWork.length == 1) {level3TitleAppreciabilityAtWorkItem1Data[segmentedButton] = _currentSelectionAppreciabilityAtWork.first;}
    else {level3TitleAppreciabilityAtWorkItem1Data[segmentedButton] = "";}
    level3TitleAppreciabilityAtWorkItem1Data[textField] = _appreciabilityAtWorkTextController.text;

    // level3TitleIncomeEarningAbilityItem1
    LinkedHashMap<String, dynamic>  level3TitleIncomeEarningAbilityItem1Data = LinkedHashMap<String, dynamic>.from({segmentedButton:"", textField:""});
    if(_currentSelectionEarningAbility.length == 1)  {level3TitleIncomeEarningAbilityItem1Data[segmentedButton] = _currentSelectionEarningAbility.first;}
    else {level3TitleIncomeEarningAbilityItem1Data[segmentedButton] = "";}
    level3TitleIncomeEarningAbilityItem1Data[textField] = _earningAbilityTextController.text;

    // Adding to to the level2TitleGroup level
    // level2TitleGroupData
    LinkedHashMap<String, dynamic> level2TitleGroupData = 
    LinkedHashMap<String, dynamic>.from(
      {level2TitleGroup:{level3TitleGroupsProblematics:level3TitleGroupsProblematicsItem1Data, level3TitleSameProblem:level3TitleSameProblemsItem1Data,
      level3TitleHarmonyAtHome:level3TitleHarmonyAtHomeItems1Data, level3TitleAppreciabilityAtWork: level3TitleAppreciabilityAtWorkItem1Data,
      level3TitleIncomeEarningAbility: level3TitleIncomeEarningAbilityItem1Data}});
     
    // Adding individual and group perspective to root level data
    _enteredData = [level2TitleIndividualData, level2TitleGroupData];

    
  }

  void print2CSV() async
  {
    setState(() {
      // Building the data from the form
      dataStructureBuild();
    });
    // Transforming the data into a CSV-friendly form
    var preCSVDataIndividualPerspective = dataToPreCSV(_enteredData[0]);
    var preCSVDataTeamPerspective = dataToPreCSV(_enteredData[1]);
    List<dynamic> csvDataIndividualPerspective = preCSVToCSVData(preCSVDataIndividualPerspective);
    List<dynamic> csvDataTeamPerspective = preCSVToCSVData(preCSVDataTeamPerspective);
    // Printing to CSV
    String? filePath = await printToCSV(csvDataIndividualPerspective, csvDataTeamPerspective);
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
              child: CustomHeader
              (
                headerTitle: 'Context analysis',
                headerLevel: 1,
              ),
            ),
            Gap(40),
            Center
            (
              child:CustomHeader
              (
                headerTitle: level2TitleIndividual,
                headerLevel: 2,
              ),
            ),
            Gap(postHeaderLevel2Gap),

            /**** ➡️ Sub-point  ****/
            CustomHeader
            (
              headerTitle: level3TitleBalanceIssue,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            CustomCheckBoxWithTextField(text: level3TitleBalanceIssueItem1, textFieldPlaceholder: pleaseDescribeTextHousehold,  
            onCheckboxChanged: _setStudiesHouseholdBalanceCheckboxState, onTextFieldChanged: _setStudiesHouseholdBalanceTextFieldState),
            CustomCheckBoxWithTextField(text: level3TitleBalanceIssueItem2, textFieldPlaceholder: pleaseDescribeTextHousehold, 
            onCheckboxChanged: _setAccessingIncomeHouseholdBalanceCheckboxState, onTextFieldChanged: _setAccessingIncomeHouseholdBalanceTextFieldState),
            CustomCheckBoxWithTextField(text: level3TitleBalanceIssueItem3, textFieldPlaceholder: pleaseDescribeTextHousehold, 
            onCheckboxChanged: _setEarningIncomeHouseholdBalanceCheckboxState, onTextFieldChanged: _setEarningIncomedHouseholdBalanceTextFieldState),
            CustomCheckBoxWithTextField(text: level3TitleBalanceIssueItem4, textFieldPlaceholder: pleaseDescribeTextHousehold, 
            onCheckboxChanged: _setHelpingOthersdBalanceCheckboxState, onTextFieldChanged: _setHelpingOthersHouseholdBalanceTextFieldState),
            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

            /**** ➡️ Sub-point  ****/
            CustomHeader
            (
              headerTitle: level3TitleWorkplaceIssue,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            CustomCheckBoxWithTextField(text: level3TitleWorkplaceIssueItem1, textFieldPlaceholder: pleaseDescribeTextWorkplace,
            onCheckboxChanged: _moreAppreciatedAtWorkCheckboxState, onTextFieldChanged: _moreAppreciatedAtWorkTextFieldState),
            CustomCheckBoxWithTextField(text: level3TitleWorkplaceIssueItem2, textFieldPlaceholder: pleaseDescribeTextWorkplace,
            onCheckboxChanged: _remainingAppreciatedAtWorkCheckboxState, onTextFieldChanged: _remainingAppreciatedAtWorkTextFieldState),
            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

           
            /**** ➡️ Sub-point  ****/
            CustomHeader
            (
              headerTitle: level3TitleLegacyIssue,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            CustomCheckBoxWithTextField(text: level3TitleLegacyIssueItem1, textFieldPlaceholder: pleaseDevelopOrTakeNotes,
            onCheckboxChanged: _betterLegaciesCheckboxState, onTextFieldChanged: _betterLegaciesTextFieldState),
            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

            /**** ➡️ Sub-point  ****/
            CustomHeader
            (
              headerTitle: level3TitleAnotherIssue,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            CustomPaddedTextField(textFieldHintText: pleaseDevelopOrTakeNotes, textFieldEditingController: _otherIssueTextController, 
            textFieldMaxLength: chars1Page, buildCounter: absentCounter),

            Gap(preAndPostLevel2DividerGap),
            Divider(thickness: betweenLevel2DividerThickness),
            Gap(preAndPostLevel2DividerGap),

            /**** Beginning of the group-related analysis ****/
            Center
            (
              child:CustomHeader
              (
                headerTitle: level2TitleGroup,
                headerLevel: 2,
              ),
            ),
            Gap(postHeaderLevel2Gap),

            CustomHeader
            (
              headerTitle: level3TitleGroupsProblematics,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            CustomPaddedTextField(textFieldHintText: pleaseDescribeTextGroups, textFieldEditingController: _problemsTheGroupsAreTryingToSolveTextController, 
            textFieldMaxLength: chars1Page, buildCounter: absentCounter),

            /**** ➡️ Sub-point  ****/
            CustomHeader
            (
              headerTitle: level3TitleSameProblem,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            Gap(level3AndSegmentedButtonGap),
            CustomSegmentedButtonWithTextField
            (
              textOption1: 'Yes',
              textOption2: 'No',
              textOption3: "I don't know",
              textOptionsfontSize: 16,
              // : Theme.of(context).colorScheme.onSurface,          
              onSelectionChanged: (newSelection) {
                setState(() {
                  _currentSelectionSameProblems = newSelection;
                });
              },
              textFieldPlaceholder: pleaseDevelopOrTakeNotes,
              onTextChanged: (String value){setState(() {});},
              textFieldEditingController: _sameProblemsTextController,
            ),
            

            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

            /**** ➡️ Sub-point  ****/
            CustomHeader
            (
              headerTitle: level3TitleHarmonyAtHome,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            Gap(level3AndSegmentedButtonGap),
            CustomSegmentedButtonWithTextField
            (
              textOption1: 'Yes',
              textOption2: 'No',
              textOption3: "I don't know",
              textOptionsfontSize: 16,         
              onSelectionChanged: (newSelection) {
                setState(() {
                  _currentSelectionHarmonyHome = newSelection;
                });
              },
              textFieldPlaceholder: pleaseDevelopOrTakeNotes,
              onTextChanged: (String value){setState(() {});},
              textFieldEditingController: _harmonyHomeTextController,
            ),

            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

            /**** ➡️ Sub-point  ****/
            CustomHeader
            (
              headerTitle: level3TitleAppreciabilityAtWork,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            Gap(level3AndSegmentedButtonGap),
            CustomSegmentedButtonWithTextField
            (
              textOption1: 'Yes',
              textOption2: 'No',
              textOption3: "I don't know",
              textOptionsfontSize: 16,      
              onSelectionChanged: (newSelection) {
                setState(() {
                  _currentSelectionAppreciabilityAtWork = newSelection;
                });
              },
              textFieldPlaceholder: pleaseDevelopOrTakeNotes,
              onTextChanged: (String value){setState(() {});},
              textFieldEditingController: _appreciabilityAtWorkTextController,
            ),

            Gap(preAndPostLevel3DividerGap),
            Divider(thickness: betweenLevel3DividerThickness),
            Gap(preAndPostLevel3DividerGap),

            /**** ➡️ Sub-point  ****/
            CustomHeader
            (
              headerTitle: level3TitleIncomeEarningAbility,
              headerLevel: 3,
              headerAlign: TextAlign.left,
            ),
            CustomSegmentedButtonWithTextField
            (
              textOption1: 'Yes',
              textOption2: 'No',
              textOption3: "I don't know",
              textOptionsfontSize: 16,        
              onSelectionChanged: (newSelection) {
                setState(() {
                  _currentSelectionEarningAbility = newSelection;
                });
              },
              textFieldPlaceholder: pleaseDevelopOrTakeNotes,
              onTextChanged: (String value){setState(() {});},
              textFieldEditingController: _earningAbilityTextController,
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
                      textFieldEditingController: analysisTitleController, // not used
                      textFieldMaxLength: 150,
                    ),
                    ElevatedButton
                    (
                      onPressed: print2CSV, 
                      child: Text('Click to save your data in CSV, \nspreadsheet-compatible format', style: dataSavingStyle, textAlign: TextAlign.center,)
                    ),
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