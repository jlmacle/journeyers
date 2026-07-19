/// {@category Context analysis}

/// A class with fields related to the questions of the context analysis.
class CAQuestionsFields
{
  // ─── USED IN THE CA FORM ───────────────────────────────────────
  // ─── QUESTIONS: INDIVIDUAL PERSPECTIVE ───────────────────────────────────────
  // Heading level 2
  /// Question asked in the form: As an individual: What problem am I trying to solve?
  String level2TitleIndividual = "As an individual: What problem am I trying to solve?";

  // Heading level 3 and sub items
  /// Question asked in the form: A Balance Issue?
  String level3TitleBalanceIssue = "A Balance Issue?";
  /// Question asked in the form: To balance studies and household life?
  String level3TitleBalanceIssueItem1 = "To balance studies and household life?";
  /// Question asked in the form: To balance accessing income and household life?
  String level3TitleBalanceIssueItem2 = "To balance accessing income and household life?";
  /// Question asked in the form: To balance earning an income and household life?
  String level3TitleBalanceIssueItem3 = "To balance earning an income and household life?";
  /// Question asked in the form: To balance helping others and household life?
  String level3TitleBalanceIssueItem4 = "To balance helping others and household life?";

  // Heading level 3 and sub items
  /// Question asked in the form: A Workplace Issue?
  String level3TitleWorkplaceIssue = "A Workplace Issue?";
  /// Question asked in the form: To solve a need to be more appreciated at work?
  String level3TitleWorkplaceIssueItem1 = "To solve a need to be more appreciated at work?";
  /// Question asked in the form: To solve a need to remain appreciated at work?
  String level3TitleWorkplaceIssueItem2 = "To solve a need to remain appreciated at work?";

  // Heading level 3 and sub items
  /// Question asked in the form: A Legacy Issue?
  String level3TitleLegacyIssue = "A Legacy Issue?";
  /// Question asked in the form: To have better legacies to leave to our children/others?
  String level3TitleLegacyIssueItem1 = "To have better legacies to leave to our children/others?";

  // Heading level 3 without sub items
  /// Question asked in the form: Is the issue of another type?
  String level3TitleAnotherIssue = "Is the issue of another type?";



  // ─── QUESTIONS: GROUP/TEAM PERSPECTIVE ───────────────────────────────────────
  // Heading level 2
  /// Question asked in the form: As a member of groups/teams: What problem(s) are we trying to solve?
  String level2TitleGroup = "As a member of groups/teams: What problem(s) are we trying to solve?";

  // Heading level 3 without sub items
  /// Question asked in the form: What problem(s) are the groups/teams trying to solve?
  String level3TitleGroupsProblematics = "What problem(s) are the groups/teams trying to solve?";

  // Heading level 3 without sub items
  /// Question asked in the form: Am I trying to solve the same problem(s) as my groups/teams?
  String level3TitleSameProblem = "Am I trying to solve the same problem(s) as my groups/teams?";

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with harmony at home?
  String level3TitleHarmonyAtHome = "Is entering the group problem-solving process consistent with harmony at home?";

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with appreciability at work?
  String level3TitleAppreciabilityAtWork = "Is entering the group problem-solving process consistent with appreciability at work?";

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with my income earning ability?
  String level3TitleIncomeEarningAbility = "Is entering the group problem-solving process consistent with my income earning ability?";



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

  /// The set of the titles level 3 related to an individual perspective.
  Set<String> level3TitlesIndividual = {};

  /// The set of the titles level 3 related to a group/team perspective.
  Set<String> level3TitlesGroup = {};

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

  CAQuestionsFields()
  {
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
      level3TitleAnotherIssue: labelTextField,

      //** Group/team perspective **/
      // group problematics
      level3TitleGroupsProblematics: labelTextField,
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

    /// The set of the titles level 3 related to an individual perspective.
    level3TitlesIndividual = {
        level3TitleBalanceIssue,
        level3TitleWorkplaceIssue,
        level3TitleLegacyIssue,
        level3TitleAnotherIssue,
      };

    /// The set of the titles level 3 related to a group/team perspective.
    level3TitlesGroup = {
      level3TitleGroupsProblematics,
      level3TitleSameProblem,
      level3TitleHarmonyAtHome,
      level3TitleAppreciabilityAtWork,
      level3TitleIncomeEarningAbility,
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
      level3TitleAnotherIssue,
      level3TitleGroupsProblematics,
    };
  }
}
