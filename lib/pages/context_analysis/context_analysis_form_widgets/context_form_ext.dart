part of 'context_form.dart';
//**************** FORM RELATED DATA AND METHODS ****************//

// Global keys to change text decoration when a checkbox is checked
final GlobalKey<CustomHeadingState> _balanceIssueHeadingKey = GlobalKey();
final GlobalKey<CustomHeadingState> _workplaceIssueHeadingKey = GlobalKey();
final GlobalKey<CustomHeadingState> _legacyIssueHeadingKey = GlobalKey();
final GlobalKey<CustomHeadingState> _anotherIssueHeadingKey = GlobalKey();

// Form questions
ContextAnalysisContextFormQuestions q = ContextAnalysisContextFormQuestions();

// Form values related data
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


// Callback methods related to the form: Individual perspective
_setStudiesHouseholdBalanceCheckboxState(bool? newValue) 
{
  _studiesHouseholdBalanceCheckboxValue = newValue!;
  _balanceIssueHeadingKey.currentState?.switchCustomHeadingDecorationIfCheckboxChecked();    
}

_setStudiesHouseholdBalanceTextFieldState(String newValue) {_studiesHouseholdBalanceTextFieldContent = newValue;}

_setAccessingIncomeHouseholdBalanceCheckboxState(bool? newValue) 
{
  _accessingIncomeHouseholdBalanceCheckboxValue = newValue!;
  _balanceIssueHeadingKey.currentState?.switchCustomHeadingDecorationIfCheckboxChecked();
}

_setAccessingIncomeHouseholdBalanceTextFieldState(String newValue) {_accessingIncomeHouseholdBalanceTextFieldContent = newValue;}

_setEarningIncomeHouseholdBalanceCheckboxState(bool? newValue) 
{
  _earningIncomeHouseholdBalanceCheckboxValue = newValue!;
  _balanceIssueHeadingKey.currentState?.switchCustomHeadingDecorationIfCheckboxChecked();
}

_setEarningIncomedHouseholdBalanceTextFieldState(String newValue) {_earningIncomeHouseholdBalanceTextFieldContent = newValue;}

_setHelpingOthersdBalanceCheckboxState(bool? newValue) 
{
  _helpingOthersHouseholdBalanceCheckboxValue = newValue!;
  _balanceIssueHeadingKey.currentState?.switchCustomHeadingDecorationIfCheckboxChecked();
}

_setHelpingOthersHouseholdBalanceTextFieldState(String newValue) {_helpingOthersHouseholdBalanceTextFieldContent = newValue;}

_setMoreAppreciatedAtWorkCheckboxState(bool? newValue) 
{
  _moreAppreciatedAtWorkCheckboxValue = newValue!;
  _workplaceIssueHeadingKey.currentState?.switchCustomHeadingDecorationIfCheckboxChecked();
}

_setMoreAppreciatedAtWorkTextFieldState(String newValue) {_moreAppreciatedAtWorkTextFieldContent = newValue;}

_setRemainingAppreciatedAtWorkCheckboxState(bool? newValue) 
{
  _remainingAppreciatedAtWorkCheckboxValue = newValue!;
  _workplaceIssueHeadingKey.currentState?.switchCustomHeadingDecorationIfCheckboxChecked();
}

_setRemainingAppreciatedAtWorkTextFieldState(String newValue) {_remainingAppreciatedAtWorkTextFieldContent = newValue;}

_setBetterLegaciesCheckboxState(bool? newValue) 
{
  _betterLegaciesCheckboxValue = newValue!;
  _legacyIssueHeadingKey.currentState?.switchCustomHeadingDecorationIfCheckboxChecked();
}

_setBetterLegaciesTextFieldState(String newValue) {_betterLegaciesTextFieldContent = newValue;}

_setAnotherIssueTextFieldState(String newValue) 
{
  _anotherIssueTextFieldContent = newValue;
  _anotherIssueHeadingKey.currentState?.switchCustomHeadingDecorationIfTextFieldUsed(newValue);
}

// Callback methods related to the form: Groups/Teams perspective
_setProblemsTheGroupsAreTryingToSolveTextFieldState(String newValue) {_problemsTheGroupsAreTryingToSolveTextFieldContent = newValue;}

_setSameProblemsSegmentedButtonState(Set<String>? values) {_sameProblemsSegmentedButtonSelection = values!;}

_setSameProblemsTextFieldState(String newValue) {_sameProblemsTextFieldContent = newValue;}

_setHarmonyHomeSegmentedButtonState(Set<String>? values) {_harmonyHomeSegmentedButtonSelection = values!;}

_setHarmonyHomeTextFieldState(String newValue) {_harmonyHomeTextFieldContent = newValue;}

_setAppreciabilityAtWorkSegmentedButtonState(Set<String>? values) {_appreciabilityAtWorkSegmentedButtonSelection = values!;}

_setAppreciabilityAtWorkTextFieldState(String newValue) {_appreciabilityAtWorkTextFieldContent = newValue;}

_setEarningAbilitySegmentedButtonState(Set<String>? values) {_earningAbilitySegmentedButtonSelection = values!;}

_setEarningAbilityTextFieldState(String newValue) {_earningAbilityTextFieldContent = newValue;}


// Method used to transform the segmented buttons selections data into a string
  String segButtonValuesToString(Set<String> values)
  {
    String stringified = "";
    stringified = values.join("/");

    return stringified;
  } 



//**************** DATA STRUCTURE related data and methods ****************//
  // Data structure to store the entered data
  List<LinkedHashMap<String, Object>> _enteredData = [];

  // Method used to store, in _enteredData, the data entered in the checkboxes, text fields and segmented buttons
  Future<void> dataStructureBuilding() async  
  {

    // Using LinkedHashMaps for an insertion-ordered hash table based.

    //************************* Individual perspective ******************************/
    // Individual level: balance issue
    // level3TitleBalanceIssueItem1Data
    LinkedHashMap<String, String> level3TitleBalanceItem1Data = LinkedHashMap<String, String>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleBalanceItem1Data[FormUtils.checkbox] = "$_studiesHouseholdBalanceCheckboxValue";
    // Keeping the text field value only if the checkbox is checked
    if (_studiesHouseholdBalanceCheckboxValue) level3TitleBalanceItem1Data[FormUtils.textField] = _studiesHouseholdBalanceTextFieldContent;    
    // level3TitleBalanceIssueItem2Data
    LinkedHashMap<String, String> level3TitleBalanceItem2Data = LinkedHashMap<String, String>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleBalanceItem2Data[FormUtils.checkbox] = "$_accessingIncomeHouseholdBalanceCheckboxValue";
    if (_accessingIncomeHouseholdBalanceCheckboxValue) level3TitleBalanceItem2Data[FormUtils.textField] = _accessingIncomeHouseholdBalanceTextFieldContent;
    // level3TitleBalanceIssueItem3Data
    LinkedHashMap<String, String> level3TitleBalanceItem3Data = LinkedHashMap<String, String>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleBalanceItem3Data[FormUtils.checkbox] = "$_earningIncomeHouseholdBalanceCheckboxValue";
    if (_earningIncomeHouseholdBalanceCheckboxValue) level3TitleBalanceItem3Data[FormUtils.textField] = _earningIncomeHouseholdBalanceTextFieldContent;
    // level3TitleBalanceIssueItem4Data
    LinkedHashMap<String, String> level3TitleBalanceItem4Data = LinkedHashMap<String, String>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleBalanceItem4Data[FormUtils.checkbox] = "$_helpingOthersHouseholdBalanceCheckboxValue";
    if (_helpingOthersHouseholdBalanceCheckboxValue) level3TitleBalanceItem4Data[FormUtils.textField] = _helpingOthersHouseholdBalanceTextFieldContent;
    // level3TitleBalanceIssueData
    // Adding all the LinkedHashMap<String, String> together
    LinkedHashMap<String, LinkedHashMap<String, String>> level3TitleBalanceIssueData = 
    LinkedHashMap<String, LinkedHashMap<String, String>>.from
    ({
      q.level3TitleBalanceIssueItem1: level3TitleBalanceItem1Data,
      q.level3TitleBalanceIssueItem2: level3TitleBalanceItem2Data,
      q.level3TitleBalanceIssueItem3: level3TitleBalanceItem3Data,
      q.level3TitleBalanceIssueItem4: level3TitleBalanceItem4Data,
    });

    // Individual level: workplace issue
    // level3TitleWorkplaceIssueItem1Data
    LinkedHashMap<String, String> level3TitleWorkplaceIssueItem1Data = LinkedHashMap<String, String>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleWorkplaceIssueItem1Data[FormUtils.checkbox] = "$_moreAppreciatedAtWorkCheckboxValue";
    if (_moreAppreciatedAtWorkCheckboxValue) level3TitleWorkplaceIssueItem1Data[FormUtils.textField] = _moreAppreciatedAtWorkTextFieldContent;
    // level3TitleWorkplaceIssueItem2Data
    LinkedHashMap<String, String> level3TitleWorkplaceIssueItem2Data = LinkedHashMap<String, String>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleWorkplaceIssueItem2Data[FormUtils.checkbox] = "$_remainingAppreciatedAtWorkCheckboxValue";
    if (_remainingAppreciatedAtWorkCheckboxValue) level3TitleWorkplaceIssueItem2Data[FormUtils.textField] = _remainingAppreciatedAtWorkTextFieldContent;
    // level3TitleWorkplaceIssueData
    LinkedHashMap<String, LinkedHashMap<String, String>> level3TitleWorkplaceIssueData = 
    LinkedHashMap<String, LinkedHashMap<String, String>>.from
    ({
      q.level3TitleWorkplaceIssueItem1: level3TitleWorkplaceIssueItem1Data,
      q.level3TitleWorkplaceIssueItem2: level3TitleWorkplaceIssueItem2Data,
    });

    // Individual level: legacy issue
    // level3TitleLegacyIssueItem1
    LinkedHashMap<String, String> level3TitleLegacyIssueItem1Data = LinkedHashMap<String, String>.from({FormUtils.checkbox: "false", FormUtils.textField: ""});
    level3TitleLegacyIssueItem1Data[FormUtils.checkbox] = "$_betterLegaciesCheckboxValue";
    if (_betterLegaciesCheckboxValue) level3TitleLegacyIssueItem1Data[FormUtils.textField] = _betterLegaciesTextFieldContent;
    // level3TitleLegacyIssueData
    LinkedHashMap<String, LinkedHashMap<String, String>> level3TitleLegacyIssueData = 
    LinkedHashMap<String, LinkedHashMap<String, String>>.from({q.level3TitleLegacyIssueItem1: level3TitleLegacyIssueItem1Data});

    // Individual level: another issue
    // level3TitleAnotherIssueItem1
    LinkedHashMap<String, String> level3TitleAnotherIssueItem1Data = LinkedHashMap<String, String>.from({FormUtils.textField: ""});
    level3TitleAnotherIssueItem1Data[FormUtils.textField] = _anotherIssueTextFieldContent;
    // Different pattern for the text field only inputs (might modify later)

    // Adding to the level2TitleIndividual data
    // level2TitleIndividualData
    LinkedHashMap<String, LinkedHashMap<String, LinkedHashMap<String, Object>>> level2TitleIndividualData = LinkedHashMap<String, LinkedHashMap<String, LinkedHashMap<String, Object>>>.from
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
    LinkedHashMap<String, String> level3TitleGroupsProblematicsItem1Data = LinkedHashMap<String, String>.from({FormUtils.textField: ""});
    level3TitleGroupsProblematicsItem1Data[FormUtils.textField] = _problemsTheGroupsAreTryingToSolveTextFieldContent;

    // Groups/teams level: trying to solve the same problems?
    // level3TitleSameProblemsItem1
    LinkedHashMap<String, String> level3TitleSameProblemsItem1Data = LinkedHashMap<String, String>.from({FormUtils.segmentedButton: "", FormUtils.textField: ""});
    // CustomSegmentedButtonWithTextField: this.multiSelectionEnabled = true
    if (_sameProblemsSegmentedButtonSelection.isNotEmpty) {level3TitleSameProblemsItem1Data[FormUtils.segmentedButton] = segButtonValuesToString(_sameProblemsSegmentedButtonSelection);} 
    else {level3TitleSameProblemsItem1Data[FormUtils.segmentedButton] = "";}
    if (_sameProblemsSegmentedButtonSelection.isNotEmpty) level3TitleSameProblemsItem1Data[FormUtils.textField] = _sameProblemsTextFieldContent;

    // Groups/teams level: harmony at home
    // level3TitleHarmonyAtHomeItem1
    LinkedHashMap<String, String> level3TitleHarmonyAtHomeItems1Data = LinkedHashMap<String, String>.from({FormUtils.segmentedButton: "", FormUtils.textField: ""});
    if (_harmonyHomeSegmentedButtonSelection.isNotEmpty) {level3TitleHarmonyAtHomeItems1Data[FormUtils.segmentedButton] = segButtonValuesToString(_harmonyHomeSegmentedButtonSelection);} 
    else {level3TitleHarmonyAtHomeItems1Data[FormUtils.segmentedButton] = "";}
    if (_harmonyHomeSegmentedButtonSelection.isNotEmpty) level3TitleHarmonyAtHomeItems1Data[FormUtils.textField] = _harmonyHomeTextFieldContent;

    // Groups/teams level: appreciability at work
    // level3TitleAppreciabilityAtWorkItem1
    LinkedHashMap<String, String> level3TitleAppreciabilityAtWorkItem1Data = LinkedHashMap<String, String>.from({FormUtils.segmentedButton: "", FormUtils.textField: ""});
    if (_appreciabilityAtWorkSegmentedButtonSelection.isNotEmpty) {level3TitleAppreciabilityAtWorkItem1Data[FormUtils.segmentedButton] = segButtonValuesToString(_appreciabilityAtWorkSegmentedButtonSelection);} 
    else {level3TitleAppreciabilityAtWorkItem1Data[FormUtils.segmentedButton] = "";}
    if (_appreciabilityAtWorkSegmentedButtonSelection.isNotEmpty) level3TitleAppreciabilityAtWorkItem1Data[FormUtils.textField] = _appreciabilityAtWorkTextFieldContent;

    // Groups/teams level: income earning abillity
    // level3TitleIncomeEarningAbilityItem1
    LinkedHashMap<String, String> level3TitleIncomeEarningAbilityItem1Data = LinkedHashMap<String, String>.from({FormUtils.segmentedButton: "", FormUtils.textField: ""});
    if (_earningAbilitySegmentedButtonSelection.isNotEmpty) {level3TitleIncomeEarningAbilityItem1Data[FormUtils.segmentedButton] = segButtonValuesToString(_earningAbilitySegmentedButtonSelection);} 
    else {level3TitleIncomeEarningAbilityItem1Data[FormUtils.segmentedButton] = "";}
    if (_earningAbilitySegmentedButtonSelection.isNotEmpty) level3TitleIncomeEarningAbilityItem1Data[FormUtils.textField] = _earningAbilityTextFieldContent;

    // Adding to the level2TitleGroup data
    // level2TitleGroupData
    LinkedHashMap<String, LinkedHashMap<String, LinkedHashMap<String, Object>>> level2TitleGroupData = LinkedHashMap<String, LinkedHashMap<String, LinkedHashMap<String, Object>>>.from
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

    if (sessionDataDebug) pu.printd("Session Data");
    if (sessionDataDebug) pu.printd("Session Data: _enteredData");
    if (sessionDataDebug) pu.printd("Session Data: $_enteredData");
    if (sessionDataDebug) pu.printd("Session Data");
  }