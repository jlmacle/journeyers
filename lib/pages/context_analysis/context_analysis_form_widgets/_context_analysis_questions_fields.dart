/// {@category Context analysis}

/// A class with fields related to the questions of the context analysis.
class CAQuestionsFields
{
  // ─── USED IN THE CA FORM ───────────────────────────────────────
  // ─── QUESTIONS: INDIVIDUAL PERSPECTIVE ───────────────────────────────────────
  // Heading level 2
  /// Question asked in the form: As an individual: What problem am I trying to solve?
  String level2TitleIndividual = 'As an individual: What problem am I trying to solve?';

  // Heading level 3 and sub items
  /// Question asked in the form: A Balance Issue?
  String level3TitleBalanceIssue = 'A Balance Issue?';
  /// Question asked in the form: To balance studies and household life?
  String level3TitleBalanceIssueItem1 = 'To balance studies and household life?';
  /// Question asked in the form: To balance accessing income and household life?
  String level3TitleBalanceIssueItem2 = 'To balance accessing income and household life?';
  /// Question asked in the form: To balance earning an income and household life?
  String level3TitleBalanceIssueItem3 = 'To balance earning an income and household life?';
  /// Question asked in the form: To balance helping others and household life?
  String level3TitleBalanceIssueItem4 = 'To balance helping others and household life?';

  // Heading level 3 and sub items
  /// Question asked in the form: A Workplace Issue?
  String level3TitleWorkplaceIssue = 'A Workplace Issue?';
  /// Question asked in the form: To solve a need to be more appreciated at work?
  String level3TitleWorkplaceIssueItem1 = 'To solve a need to be more appreciated at work?';
  /// Question asked in the form: To solve a need to remain appreciated at work?
  String level3TitleWorkplaceIssueItem2 = 'To solve a need to remain appreciated at work?';

  // Heading level 3 and sub items
  /// Question asked in the form: A Legacy Issue?
  String level3TitleLegacyIssue = 'A Legacy Issue?';
  /// Question asked in the form: To have better legacies to leave to our children/others?
  String level3TitleLegacyIssueItem1 = 'To have better legacies to leave to our children/others?';

  // Heading level 3 without sub items
  /// Question asked in the form: Is the issue of another type?
  String level3TitleAnotherIssue = 'Is the issue of another type?';



  // ─── QUESTIONS: GROUP/TEAM PERSPECTIVE ───────────────────────────────────────
  // Heading level 2
  /// Question asked in the form: As a member of groups/teams: What problem(s) are we trying to solve?
  String level2TitleGroup = 'As a member of groups/teams: What problem(s) are we trying to solve?';

  // Heading level 3 without sub items
  /// Question asked in the form: What problem(s) are the groups/teams trying to solve?
  String level3TitleGroupsProblematics = 'What problem(s) are the groups/teams trying to solve?';

  // Heading level 3 without sub items
  /// Question asked in the form: Am I trying to solve the same problem(s) as my groups/teams?
  String level3TitleSameProblem = 'Am I trying to solve the same problem(s) as my groups/teams?';

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with harmony at home?
  String level3TitleHarmonyAtHome = 'Is entering the group problem-solving process consistent with harmony at home?';

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with appreciability at work?
  String level3TitleAppreciabilityAtWork = 'Is entering the group problem-solving process consistent with appreciability at work?';

  // Heading level 3 without sub items
  /// Question asked in the form: Is entering the group problem-solving process consistent with my income earning ability?
  String level3TitleIncomeEarningAbility = 'Is entering the group problem-solving process consistent with my income earning ability?';



  // ─── USED IN THE CA FORM DTO AND/OR THIS FILE ───────────────────────────────────────
  /// A util used to label checkbox data.
  String keyCheckbox = "checkbox";

  /// A util used to label text field data.
  String keyTextField = "textField";

  /// A util used to label segmented button data.
  String keySegmentedButton = "segmentedButton";



  // ─── USED IN THE CA FORM DTO AND IN THE CA PREVIEW WIDGET ───────────────────────────────────────
  /// A mapping of question labels with the type of input items 
  /// (text field, checkbox with text field, segmented button with text field) used to answer.
  Map<String, String> mappingLabelsToInputItems = {};

  /// A set of the titles level 2.
  Set<String> titlesLevel2 = {};

  /// A set of the titles level 3 related to an individual perspective.
  Set<String> titlesLevel3ForTheIndividualPerspective = {};

  /// A set of the titles level 3 related to a group/team perspective.
  Set<String> titlesLevel3ForTheGroupPerspective = {};

  /// A set of the titles level 3 with sub items.
  Set<String> titlesLevel3WithSubItems = {};

  /// A set of the children of the title level 3 related to balance issues.
  Set<String> childrenOfTitleLevel3BalanceIssue = {};

  /// A set of the children of the title level 3 related to workplace issues.
  Set<String> childrenOfTitleLevel3WorkplaceIssue = {};

  /// A set of the children of the title level 3 related to a legacy issue.
  Set<String> childrenOfTitleLevel3LegacyIssue = {};

  /// A set of the text fields only items
  Set<String> textFieldOnlyItems = {};

  CAQuestionsFields()
  {
    /// A mapping of question labels with the type of input items 
    /// (text field, checkbox with text field, segmented button with text field) used to answer.
    mappingLabelsToInputItems = 
    {
      //** Individual perspective **/
      // balance issue
      level3TitleBalanceIssueItem1: keyCheckbox,
      level3TitleBalanceIssueItem2: keyCheckbox,
      level3TitleBalanceIssueItem3: keyCheckbox,
      level3TitleBalanceIssueItem4: keyCheckbox,
      // workplace issue
      level3TitleWorkplaceIssueItem1: keyCheckbox,
      level3TitleWorkplaceIssueItem2: keyCheckbox,
      // legacy issue
      level3TitleLegacyIssueItem1: keyCheckbox,
      // another type
      level3TitleAnotherIssue: keyTextField,

      //** Group/team perspective **/
      // group problematics
      level3TitleGroupsProblematics: keyTextField,
      // same problem?
      level3TitleSameProblem: keySegmentedButton,
      // harmony at home
      level3TitleHarmonyAtHome: keySegmentedButton,
      // appreciability at work
      level3TitleAppreciabilityAtWork: keySegmentedButton,
      // earning ability
      level3TitleIncomeEarningAbility: keySegmentedButton,
    };

    /// A set of the titles level 2.
    titlesLevel2 = {level2TitleIndividual, level2TitleGroup};

    /// A set of the titles level 3 related to an individual perspective.
    titlesLevel3ForTheIndividualPerspective = {
        level3TitleBalanceIssue,
        level3TitleWorkplaceIssue,
        level3TitleLegacyIssue,
        level3TitleAnotherIssue,
      };

    /// A set of the titles level 3 related to a group/team perspective.
    titlesLevel3ForTheGroupPerspective = {
      level3TitleGroupsProblematics,
      level3TitleSameProblem,
      level3TitleHarmonyAtHome,
      level3TitleAppreciabilityAtWork,
      level3TitleIncomeEarningAbility,
    };

    /// A set of the titles level 3 with sub items.
    titlesLevel3WithSubItems = {
      level3TitleBalanceIssue,
      level3TitleWorkplaceIssue,
      level3TitleLegacyIssue,
    };

    // Sets of the children of the titles level 3 with sub items

    /// A set of the children of the title level 3 related to balance issues.
    childrenOfTitleLevel3BalanceIssue = {
      level3TitleBalanceIssueItem1,
      level3TitleBalanceIssueItem2,
      level3TitleBalanceIssueItem3,
      level3TitleBalanceIssueItem4,
    };

    /// A set of the children of the title level 3 related to workplace issues.
    childrenOfTitleLevel3WorkplaceIssue = {
      level3TitleWorkplaceIssueItem1,
      level3TitleWorkplaceIssueItem2,
    };

    /// A set of the children of the title level 3 related to a legacy issue.
    childrenOfTitleLevel3LegacyIssue = {level3TitleLegacyIssueItem1};

    /// A set of the text fields only items
    textFieldOnlyItems = {
      level3TitleAnotherIssue,
      level3TitleGroupsProblematics,
    };
  }
}
