// ─── USED IN THE CA FORM ───────────────────────────────────────
// ─── QUESTIONS: INDIVIDUAL PERSPECTIVE ───────────────────────────────────────

// Heading level 2
/// As an individual: What problem am I trying to solve?
const String level2TitleIndividual = 'As an individual: What problem am I trying to solve?';

// Heading level 3 and sub items
/// A Balance Issue?
const String level3TitleBalanceIssue = 'A Balance Issue?';
/// To balance studies and household life?
const String level3TitleBalanceIssueItem1 = 'To balance studies and household life?';
/// To balance accessing income and household life?
const String level3TitleBalanceIssueItem2 = 'To balance accessing income and household life?';
/// To balance earning an income and household life?
const String level3TitleBalanceIssueItem3 = 'To balance earning an income and household life?';
/// To balance helping others and household life?
const String level3TitleBalanceIssueItem4 = 'To balance helping others and household life?';

// Heading level 3 and sub items
/// A Workplace Issue?
const String level3TitleWorkplaceIssue = 'A Workplace Issue?';
/// To solve a need to be more appreciated at work?
const String level3TitleWorkplaceIssueItem1 = 'To solve a need to be more appreciated at work?';
/// To solve a need to remain appreciated at work?
const String level3TitleWorkplaceIssueItem2 = 'To solve a need to remain appreciated at work?';

// Heading level 3 and sub items
/// A Legacy Issue?
const String level3TitleLegacyIssue = 'A Legacy Issue?';
/// To have better legacies to leave to our children/others?
const String level3TitleLegacyIssueItem1 = 'To have better legacies to leave to our children/others?';

// Heading level 3 without sub items
/// Is the issue of another type?
const String level3TitleAnotherIssue = 'Is the issue of another type?';



// ─── QUESTIONS: GROUP/TEAM PERSPECTIVE ───────────────────────────────────────

// Heading level 2
/// As a member of groups/teams: What problem(s) are we trying to solve?
const String level2TitleGroup = 'As a member of groups/teams: What problem(s) are we trying to solve?';

// Heading level 3 without sub items
/// What problem(s) are the groups/teams trying to solve?
const String level3TitleGroupsProblematics = 'What problem(s) are the groups/teams trying to solve?';

// Heading level 3 without sub items
/// Am I trying to solve the same problem(s) as my groups/teams?
const String level3TitleSameProblem = 'Am I trying to solve the same problem(s) as my groups/teams?';

// Heading level 3 without sub items
/// Is entering the group problem-solving process consistent with harmony at home?
const String level3TitleHarmonyAtHome = 'Is entering the group problem-solving process consistent with harmony at home?';

// Heading level 3 without sub items
/// Is entering the group problem-solving process consistent with appreciability at work?
const String level3TitleAppreciabilityAtWork = 'Is entering the group problem-solving process consistent with appreciability at work?';

// Heading level 3 without sub items
/// Is entering the group problem-solving process consistent with my income earning ability?
const String level3TitleIncomeEarningAbility = 'Is entering the group problem-solving process consistent with my income earning ability?';



// ─── USED IN THE CA FORM DTO AND/OR THIS FILE ───────────────────────────────────────
/// A util used to label checkbox data.
const String checkbox = "checkbox";

/// A util used to label text field data.
const String textField = "textField";

/// A util used to label segmented button data.
const String segmentedButton = "segmentedButton";

/// Straight double quotes used to encapsulate the content of answered questions.
const String quotesForCSV = '"';


// ─── USED IN THE CA TEXT FIELDS ───────────────────────────────────────

/// A number of characters used to represent 10 lines of text field input on a computer.
const int chars10Lines = 1560;

/// A number of characters used to represent 1 page of text field input on a computer.
const int chars1Page = 7330; 



// ─── USED IN THE CA FORM DTO AND IN THE CA PREVIEW WIDGET ───────────────────────────────────────

/// A mapping of question labels with the type of input items 
/// (text field, checkbox with text field, segmented button with text field) used to answer.
const Map<String, String> mappingLabelsToInputItems = 
{
  //** Individual perspective **/
  // balance issue
  level3TitleBalanceIssueItem1: checkbox,
  level3TitleBalanceIssueItem2: checkbox,
  level3TitleBalanceIssueItem3: checkbox,
  level3TitleBalanceIssueItem4: checkbox,
  // workplace issue
  level3TitleWorkplaceIssueItem1: checkbox,
  level3TitleWorkplaceIssueItem2: checkbox,
  // legacy issue
  level3TitleLegacyIssueItem1: checkbox,
  // another type
  level3TitleAnotherIssue: textField,

  //** Group/team perspective **/
  // group problematics
  level3TitleGroupsProblematics: textField,
  // same problem?
  level3TitleSameProblem: segmentedButton,
  // harmony at home
  level3TitleHarmonyAtHome: segmentedButton,
  // appreciability at work
  level3TitleAppreciabilityAtWork: segmentedButton,
  // earning ability
  level3TitleIncomeEarningAbility: segmentedButton,
};

/// A set of the titles level 2.
const Set<String> titlesLevel2 = {level2TitleIndividual, level2TitleGroup};

// A set of the titles level 3 related to an individual perspective.
const Set<String> titlesLevel3ForTheIndividualPerspective = {
    level3TitleBalanceIssue,
    level3TitleWorkplaceIssue,
    level3TitleLegacyIssue,
    level3TitleAnotherIssue,
  };

// A set of the titles level 3 related to a group/team perspective.
const Set<String> titlesLevel3ForTheGroupPerspective = {
  level3TitleGroupsProblematics,
  level3TitleSameProblem,
  level3TitleHarmonyAtHome,
  level3TitleAppreciabilityAtWork,
  level3TitleIncomeEarningAbility,
};

  /// A set of the titles level 3 with sub items.
  const Set<String> titlesLevel3WithSubItems = {
    level3TitleBalanceIssue,
    level3TitleWorkplaceIssue,
    level3TitleLegacyIssue,
  };

  // Sets of the children of the titles level 3 with sub items
  /// A set of the children of the title level 3 related to balance issues.
  const  Set<String> childrenOfTitleLevel3BalanceIssue = {
    level3TitleBalanceIssueItem1,
    level3TitleBalanceIssueItem2,
    level3TitleBalanceIssueItem3,
    level3TitleBalanceIssueItem4,
  };

  /// A set of the children of the title level 3 related to workplace issues.
  const  Set<String> childrenOfTitleLevel3WorkplaceIssue = {
    level3TitleWorkplaceIssueItem1,
    level3TitleWorkplaceIssueItem2,
  };

  /// A set of the children of the title level 3 related to a legacy issue.
  const Set<String> childrenOfTitleLevel3LegacyIssue = {level3TitleLegacyIssueItem1};

  // A set of the text fields only items
  const  Set<String> textFieldOnlyItems = {
    level3TitleAnotherIssue,
    level3TitleGroupsProblematics,
  };
