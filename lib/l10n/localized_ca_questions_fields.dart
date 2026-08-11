import "package:flutter/widgets.dart";

import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/utils/string/string_utils.dart";

class LocalizedCAQuestionsFields
{
  AppLocalizations? _l10n;

// ─── USED IN THE CA FORM ───────────────────────────────────────
  // ─── QUESTIONS: INDIVIDUAL PERSPECTIVE ───────────────────────────────────────
  // Heading level 2
  /// Question asked in the form: As an individual: What problem am I trying to solve?
  String level2TitleIndividual = "";

  // Heading level 3 and sub items
  /// Question asked in the form: A Balance Issue?
  String level3TitleBalanceIssue = "";
  /// Question asked in the form: To balance studies and household life?
  String level3TitleBalanceIssueItem1 = "";
  /// Question asked in the form: To balance accessing income and household life?
  String level3TitleBalanceIssueItem2 = "";
  /// Question asked in the form: To balance earning an income and household life?
  String level3TitleBalanceIssueItem3 = "";
  /// Question asked in the form: To balance helping others and household life?
  String level3TitleBalanceIssueItem4 = "";

  // Heading level 3 and sub items
  /// Question asked in the form: A Workplace Issue?
  String level3TitleWorkplaceIssue = "";
  /// Question asked in the form: To solve a need to be more appreciated at work?
  String level3TitleWorkplaceIssueItem1 = "";
  /// Question asked in the form: To solve a need to remain appreciated at work?
  String level3TitleWorkplaceIssueItem2 = "";

  // Heading level 3 and sub items
  /// Question asked in the form: A Legacy Issue?
  String level3TitleLegacyIssue = "";

  /// Question asked in the form: A Legacy Issue? (for data saving)
  String level3TitleLegacyIssueForDataSaving = "";

  /// Question asked in the form: To have a better legacy to leave to my children/others?
  String level3TitleLegacyIssueItem1 = "";

  // Heading level 3 without sub items
  /// Question asked in the form: Is The issue Of Another Type?
  String level3TitleAnotherIssue = "";

  /// Question asked in the form: Is The issue Of Another Type? (for data saving)
  String level3TitleAnotherIssueForDataSaving = "";


  // ─── QUESTIONS: GROUP/TEAM PERSPECTIVE ───────────────────────────────────────
  // Heading level 2
  /// Question asked in the form: As a member of groups/teams: What problem(s) are we trying to solve?
  String level2TitleGroup = "";

  // Heading level 3 without sub items
  /// Question asked in the form: What problem(s) are the groups/teams trying to solve?
  String level3TitleGroupsProblematics = "";

  /// Question asked in the form: What problem(s) are the groups/teams trying to solve? (for data saving)
  String level3TitleGroupsProblematicsForDataSaving = "";

  // Heading level 3 without sub items
  /// Question asked in the form: Am I trying to solve the same problem(s) as my groups/teams?
  String level3TitleSameProblem = "";

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with harmony at home?
  String level3TitleHarmonyAtHome = "";

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with appreciability at work?
  String level3TitleAppreciabilityAtWork = "";

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with my income earning ability?
  String level3TitleIncomeEarningAbility = "";



  // ─── USED IN THE CA FORM DTO AND/OR THIS FILE ───────────────────────────────────────
  /// A util used to label checkbox data.
  String labelCheckbox = "checkbox";

  /// A util used to label text field data.
  String labelTextField = "textField";

  /// A util used to label segmented button data.
  String labelSegmentedButton = "segmentedButton";



  // ─── USED IN THE CA FORM DTO AND IN THE CA PREVIEW WIDGET ───────────────────────────────────────
  /// A mapping of question labels with the type of input items 
  /// (text field, checkbox with text field, segmented button with text field) used to answer.
  Map<String, String> questionsToInputItemsMapping = {};

  /// The set of the titles level 2.
  Set<String> level2Titles = {};

  /// The set of the titles level 2 for the preview.
  Set<String> level2TitlesForPreview = {};

  /// The set of the titles level 3 related to an individual perspective.
  Set<String> level3TitlesIndividual = {};

  /// The set of the titles level 3 related to an individual perspective used in the preview.
  Set<String> level3TitlesIndividualForPreview = {};

  /// The set of the titles level 3 related to a group/team perspective.
  Set<String> level3TitlesGroup = {};

  /// The set of the titles level 3 related to a group/team perspective used in the preview.
  Set<String> level3TitlesGroupForPreview = {};

  /// The set of the titles level 3 related to a group/team perspective that are answered with segmented buttons.
  Set<String> level3TitlesGroupCustomSegmentedButtons = {};

  /// The set of the titles level 3 with sub items.
  Set<String> level3TitlesWithSubItems = {};

  /// The set of the children of the title level 3 related to balance issues.
  Set<String> childrenOfLevel3TitleBalanceIssue = {};

  /// The set of the children of the title level 3 related to workplace issues.
  Set<String> childrenOfLevel3TitleWorkplaceIssue = {};

  /// The set of the children of the title level 3 related to a legacy issue.
  Set<String> childrenOfLevel3TitleLegacyIssue = {};

  /// The set of the text fields only items.
  Set<String> textFieldOnlyItems = {};

  LocalizedCAQuestionsFields(BuildContext context)
  {    
    /// Question asked in the form: As an individual: What problem am I trying to solve?
    level2TitleIndividual = AppLocalizations.of(context)?.ca_process_individual_perspective_title_question
          ?? "Issue with the title question for the individual perspective";

    /// Question asked in the form: A Balance Issue?
    level3TitleBalanceIssue = AppLocalizations.of(context)?.ca_process_individual_perspective_balance_issue_section_question ?? "Issue with the section question for the balance issue, in the individual perspective";
    /// Question asked in the form: To balance studies and household life?
    level3TitleBalanceIssueItem1 = AppLocalizations.of(context)?.ca_process_individual_perspective_balance_studies_household ?? "Issue with the studies-household life balance question, in the individual perspective";
    /// Question asked in the form: To balance accessing income and household life?
    level3TitleBalanceIssueItem2 = AppLocalizations.of(context)?.ca_process_individual_perspective_balance_accessing_income_household ?? "Issue with the accessing income-household life balance question, in the individual perspective";
    /// Question asked in the form: To balance earning an income and household life?
    level3TitleBalanceIssueItem3 = AppLocalizations.of(context)?.ca_process_individual_perspective_balance_earning_income_household ?? "Issue with the earning income-household life balance question, in the individual perspective";
    /// Question asked in the form: To balance helping others and household life?
    level3TitleBalanceIssueItem4 = AppLocalizations.of(context)?.ca_process_individual_perspective_balance_helping_others_household ?? "Issue with the helping others-household life balance question, in the individual perspective";

    // Question asked in the form: A Workplace Issue?
    level3TitleWorkplaceIssue = AppLocalizations.of(context)?.ca_process_individual_perspective_workplace_issue_section_question ?? "Issue with the section question for the workplace issue, in the individual perspective";
    /// Question asked in the form: To solve a need to be more appreciated at work?
    level3TitleWorkplaceIssueItem1 = AppLocalizations.of(context)?.ca_process_individual_perspective_workplace_more_appreciated ?? "Issue with the more-appreciated-at-work question, in the individual perspective";
    /// Question asked in the form: To solve a need to remain appreciated at work?
    level3TitleWorkplaceIssueItem2 = AppLocalizations.of(context)?.ca_process_individual_perspective_workplace_to_remain_appreciated ?? "Issue with the to-remain-appreciated-at-work question, in the individual perspective";

    // Heading level 3 and sub items
    /// Question asked in the form: A Legacy Issue?
    level3TitleLegacyIssue = AppLocalizations.of(context)?.ca_process_individual_perspective_legacy_issue_section_question ?? "Issue with the section question for the legacy issue, in the individual perspective";
    /// Question asked in the form: A Legacy Issue? (for data saving)
    level3TitleLegacyIssueForDataSaving = lineReturnToSpace(level3TitleLegacyIssue)!;

    /// Question asked in the form: To have a better legacy to leave to my children/others?
    level3TitleLegacyIssueItem1 = AppLocalizations.of(context)?.ca_process_individual_perspective_legacy_better_legacy ?? "Issue with the better legacy question, in the individual perspective";

    // Heading level 3 without sub items
    /// Question asked in the form: Is The issue Of Another Type?
    level3TitleAnotherIssue = AppLocalizations.of(context)?.ca_process_individual_perspective_another_issue_section_question ?? "Issue with the section question for an issue of another type, in the individual perspective";

    /// Question asked in the form: Is The issue Of Another Type? (for data saving)
    level3TitleAnotherIssueForDataSaving = lineReturnToSpace(level3TitleAnotherIssue)!;

    // Heading level 2
    /// Question asked in the form: As a member of groups/teams: What problem(s) are we trying to solve?
    level2TitleGroup = AppLocalizations.of(context)?.ca_process_group_perspective_title_question ?? "Issue with the title question for the groups/teams perspective";

    // Heading level 3 without sub items
    /// Question asked in the form: What problem(s) are the groups/teams trying to solve?
    level3TitleGroupsProblematics = AppLocalizations.of(context)?.ca_process_group_perspective_problems ?? "Issue with the question for the problem(s) the groups/teams are trying to solve";

    /// Question asked in the form: What problem(s) are the groups/teams trying to solve? (for data saving)
    level3TitleGroupsProblematicsForDataSaving = lineReturnToSpace(level3TitleGroupsProblematics)!;

    // Heading level 3 without sub items
    /// Question asked in the form: Am I trying to solve the same problem(s) as my groups/teams?
    level3TitleSameProblem = AppLocalizations.of(context)?.ca_process_group_perspective_solving_same_problems ?? "Issue with the question related to solving the same problem(s) as the groups/teams";

    // Heading level 3 without sub items
    /// Question asked in the form: Is entering the group problem-solving process consistent with harmony at home?
    level3TitleHarmonyAtHome = AppLocalizations.of(context)?.ca_process_group_perspective_harmony_home ?? "Issue with the question related to harmony at home";

    // Heading level 3 without sub items
    /// Question asked in the form: Is entering the group problem-solving process consistent with appreciability at work?
    level3TitleAppreciabilityAtWork = AppLocalizations.of(context)?.ca_process_group_perspective_appreciability_work ?? "Issue with the question related to the consistency with appreciability at work?";

    // Heading level 3 without sub items
    /// Question asked in the form: Is entering the group problem-solving process consistent with my income earning ability?
    level3TitleIncomeEarningAbility = AppLocalizations.of(context)?.ca_process_group_perspective_earning_ability ?? "Issue with the question related to the consistency with earning ability?";

    /// A mapping of question labels with the type of input items used to answer the questions
    /// (text field, checkbox with text field, segmented button with text field).
    questionsToInputItemsMapping = 
    {
      //** Individual perspective **/
      // balance issue
      level3TitleBalanceIssueItem1: labelCheckbox,
      level3TitleBalanceIssueItem2: labelCheckbox,
      level3TitleBalanceIssueItem3: labelCheckbox,
      level3TitleBalanceIssueItem4: labelCheckbox,
      // workplace issue
      level3TitleWorkplaceIssueItem1: labelCheckbox,
      level3TitleWorkplaceIssueItem2: labelCheckbox,
      // legacy issue
      level3TitleLegacyIssueItem1: labelCheckbox,
      // another type
      level3TitleAnotherIssueForDataSaving: labelTextField,

      //** Group/team perspective **/
      // group problematics
      level3TitleGroupsProblematicsForDataSaving: labelTextField,
      // same problem?
      level3TitleSameProblem: labelSegmentedButton,
      // harmony at home
      level3TitleHarmonyAtHome: labelSegmentedButton,
      // appreciability at work
      level3TitleAppreciabilityAtWork: labelSegmentedButton,
      // earning ability
      level3TitleIncomeEarningAbility: labelSegmentedButton,
    };

    /// The set of the titles level 2.
    level2Titles = {level2TitleIndividual, level2TitleGroup};

    /// The set of the titles level 2 for the preview.
    level2TitlesForPreview = {lineReturnToSpace(level2TitleIndividual)!, lineReturnToSpace(level2TitleGroup)!};

    /// The set of the titles level 3 related to an individual perspective.
    level3TitlesIndividual = {
        level3TitleBalanceIssue,
        level3TitleWorkplaceIssue,
        level3TitleLegacyIssue,
        level3TitleAnotherIssue,
      };   

    /// The set of the titles level 3 related to an individual perspective.
    level3TitlesIndividualForPreview = {
      lineReturnToSpace(level3TitleBalanceIssue)!,
      lineReturnToSpace(level3TitleWorkplaceIssue)!,
      lineReturnToSpace(level3TitleLegacyIssue)!,
      lineReturnToSpace(level3TitleAnotherIssue)!,
      };    

    /// The set of the titles level 3 related to a group/team perspective.
    level3TitlesGroup = {
      level3TitleGroupsProblematics,
      level3TitleSameProblem,
      level3TitleHarmonyAtHome,
      level3TitleAppreciabilityAtWork,
      level3TitleIncomeEarningAbility,
    };

    level3TitlesGroupForPreview = {
      lineReturnToSpace(level3TitleGroupsProblematics)!,
      lineReturnToSpace(level3TitleSameProblem)!,
      lineReturnToSpace(level3TitleHarmonyAtHome)!,
      lineReturnToSpace(level3TitleAppreciabilityAtWork)!,
      lineReturnToSpace(level3TitleIncomeEarningAbility)!,
    };

    /// The set of the titles level 3 related to a group/team perspective that are answered with segmented buttons.
    level3TitlesGroupCustomSegmentedButtons = {
      level3TitleSameProblem,
      level3TitleHarmonyAtHome,
      level3TitleAppreciabilityAtWork,
      level3TitleIncomeEarningAbility,
    };

    /// The set of the titles level 3 with sub items.
    level3TitlesWithSubItems = {
      level3TitleBalanceIssue,
      level3TitleWorkplaceIssue,
      level3TitleLegacyIssue,
    };

    // Sets of the children of the titles level 3 with sub items

    /// The set of the children of the title level 3 related to balance issues.
    childrenOfLevel3TitleBalanceIssue = {
      level3TitleBalanceIssueItem1,
      level3TitleBalanceIssueItem2,
      level3TitleBalanceIssueItem3,
      level3TitleBalanceIssueItem4,
    };

    /// The set of the children of the title level 3 related to workplace issues.
    childrenOfLevel3TitleWorkplaceIssue = {
      level3TitleWorkplaceIssueItem1,
      level3TitleWorkplaceIssueItem2,
    };

    /// The set of the children of the title level 3 related to a legacy issue.
    childrenOfLevel3TitleLegacyIssue = {level3TitleLegacyIssueItem1};

    /// The set of the text fields only items
    textFieldOnlyItems = {
      level3TitleAnotherIssueForDataSaving,
      level3TitleGroupsProblematicsForDataSaving,
    };
  }


  
  // Method used to get the level2 titles without line returns
  List<String> getSanitizedLevel2Titles(BuildContext context) {
    return    
    [
      _l10n?.ca_process_individual_perspective_title_question
          ?? "Issue with the title question for the individual perspective",
      _l10n?.ca_process_group_perspective_title_question
          ?? "Issue with the title question for the group perspective"
    ];
     
  }

}


