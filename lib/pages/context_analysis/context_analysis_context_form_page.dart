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
import 'package:journeyers/pages/context_analysis/context_analysis_context_form_questions.dart';

class ContextAnalysisContextFormPage extends StatefulWidget {
  
  const ContextAnalysisContextFormPage({super.key});

  @override
  State<ContextAnalysisContextFormPage> createState() => _ContextAnalysisContextFormPageState();
}

class _ContextAnalysisContextFormPageState extends State<ContextAnalysisContextFormPage> 
{
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

  // Example of data for segmented button with text field
  Set<String> _currentSelectionSocialAbility = {};
  final TextEditingController _decreasedSocialAbilityTextController = TextEditingController();

  bool? _betterLegaciesCheckbox;  
  String? _betterLegaciesTextFieldContent;
 
  final TextEditingController _otherIssueTextController = TextEditingController();

  final TextEditingController _problemsTheGroupsAreTryingToSolveTextController = TextEditingController();

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

  _otherIssueTextFieldState(String newValue){setState(() {});}

  _problemsTheGroupsAreTryingToSolveTextFieldState(String newValue){setState(() {});}


  @override
  void dispose() {
    // Disposal of all controllers
    _decreasedSocialAbilityTextController.dispose();
    _otherIssueTextController.dispose();
    _problemsTheGroupsAreTryingToSolveTextController.dispose();
    _sameProblemsTextController.dispose();
    _harmonyHomeTextController.dispose();
    _appreciabilityAtWorkTextController.dispose();
    _earningAbilityTextController.dispose();
    super.dispose();
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
            CustomCheckBoxWithTextField(text: level3TitleStudiesHouseholdBalanceItem1, textFieldPlaceholder: pleaseDescribeTextHousehold,  
            onCheckboxChanged: _setStudiesHouseholdBalanceCheckboxState, onTextFieldChanged: _setStudiesHouseholdBalanceTextFieldState),
            CustomCheckBoxWithTextField(text: level3TitleStudiesHouseholdBalanceItem2, textFieldPlaceholder: pleaseDescribeTextHousehold, 
            onCheckboxChanged: _setAccessingIncomeHouseholdBalanceCheckboxState, onTextFieldChanged: _setAccessingIncomeHouseholdBalanceTextFieldState),
            CustomCheckBoxWithTextField(text: level3TitleStudiesHouseholdBalanceItem3, textFieldPlaceholder: pleaseDescribeTextHousehold, 
            onCheckboxChanged: _setEarningIncomeHouseholdBalanceCheckboxState, onTextFieldChanged: _setEarningIncomedHouseholdBalanceTextFieldState),
            CustomCheckBoxWithTextField(text: level3TitleStudiesHouseholdBalanceItem4, textFieldPlaceholder: pleaseDescribeTextHousehold, 
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
            CustomPaddedTextField(textFieldInputDecoration: InputDecoration(hintText: pleaseDevelopOrTakeNotes), textFieldEditingController: _otherIssueTextController, onTextFieldChanged: _otherIssueTextFieldState),

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
            CustomPaddedTextField(textFieldInputDecoration: InputDecoration(hintText: pleaseDescribeTextGroups), textFieldEditingController: _problemsTheGroupsAreTryingToSolveTextController, onTextFieldChanged: _problemsTheGroupsAreTryingToSolveTextFieldState),

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
           
            // /* Debug section */
            // Gap(20),
            // Divider(thickness: 3),
            // Gap(20),
            // Text('Debug:'),
            // Text("Studies / Household Balance: ${_studiesHouseholdBalanceCheckbox ?? false}, text: ${_studiesHouseholdBalanceTextFieldContent ?? 'No value entered in the text field'}"),
            // Text("Accessing Income / Household Balance: ${_accessingIncomeHouseholdBalanceCheckbox ?? false}, text: ${_accessingIncomeHouseholdBalanceTextFieldContent ?? 'No value entered in the text field'}"),
            // Text("Earning Income / Household Balance: ${_earningIncomeHouseholdBalanceCheckbox ?? false}, text: ${_earningIncomeHouseholdBalanceTextFieldContent ?? 'No value entered in the text field'}"),
            // Text("Helping Others / Household Balance: ${_helpingOthersHouseholdBalanceCheckbox ?? false}, text: ${_helpingOthersHouseholdBalanceTextFieldContent ?? 'No value entered in the text field'}"),

            // Text("More Appreciated At Work: ${_moreAppreciatedAtWorkCheckbox ?? false}, text: ${_moreAppreciatedAtWorkTextFieldContent ?? 'No value entered in the text field'}"),
            // Text("Remaining Appreciated At Work: ${_remainingAppreciatedAtWorkCheckbox ?? false}, text: ${_remainingAppreciatedAtWorkTextFieldContent ?? 'No value entered in the text field'}"),
           
            // Text("Better Legacies: ${_betterLegaciesCheckbox ?? false}, text: ${_betterLegaciesTextFieldContent ?? 'No value entered in the text field'}"),
            
            // Text("Other Issue: text: ${_otherIssueTextController.text}"),

            // Text("Problems The Groups Are Trying To Solve: text: ${_problemsTheGroupsAreTryingToSolveTextController.text}"),

            // Text("Same problems being solved?:  ${ _currentSelectionSameProblems.toString()}, text: ${_sameProblemsTextController.text}"),

            // Text("Harmony home?:  ${ _currentSelectionHarmonyHome.toString()}, text: ${_harmonyHomeTextController.text}"),

            // Text("Appreciability at work:  ${ _currentSelectionAppreciabilityAtWork.toString()}, text: ${_appreciabilityAtWorkTextController.text}"),

            // Text("Earning ability:  ${ _currentSelectionEarningAbility.toString()}, text: ${_earningAbilityTextController.text}"),
        
          ],
        ),
      )
    );
  }
}