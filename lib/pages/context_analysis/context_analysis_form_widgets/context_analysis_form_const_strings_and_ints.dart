import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_questions.dart';

/// A util used to label checkbox data.
const String checkbox = "checkbox";

/// A util used to label text field data.
const String textField = "textField";

/// A util used to label segmented button data.
const String segmentedButton = "segmentedButton";

/// Straight double quotes used to encapsulate the content of answered questions.
String quotesForCSV = '"';

/// A number of characters used to represent 10 lines of text field input on a computer.
const int chars10Lines = 1560;

/// A number of characters used to represent 1 page of text field input on a computer.
const int chars1Page = 7330; 

 /// The questions used in the form.
final CAFormQuestions q = CAFormQuestions();

/// A mapping of question labels with the type of input items 
/// (text field, checkbox with text field, segmented button with text field) used to answer.
Map<String, String> mappingLabelsToInputItems = 
{
  //** Individual perspective **/
  // balance issue
  q.level3TitleBalanceIssueItem1: checkbox,
  q.level3TitleBalanceIssueItem2: checkbox,
  q.level3TitleBalanceIssueItem3: checkbox,
  q.level3TitleBalanceIssueItem4: checkbox,
  // workplace issue
  q.level3TitleWorkplaceIssueItem1: checkbox,
  q.level3TitleWorkplaceIssueItem2: checkbox,
  // legacy issue
  q.level3TitleLegacyIssueItem1: checkbox,
  // another type
  q.level3TitleAnotherIssue: textField,

  //** Group/team perspective **/
  // group problematics
  q.level3TitleGroupsProblematics: textField,
  // same problem?
  q.level3TitleSameProblem: segmentedButton,
  // harmony at home
  q.level3TitleHarmonyAtHome: segmentedButton,
  // appreciability at work
  q.level3TitleAppreciabilityAtWork: segmentedButton,
  // earning ability
  q.level3TitleIncomeEarningAbility: segmentedButton,
};

/// A set of the titles level 2.
Set<String> titlesLevel2 = {q.level2TitleIndividual, q.level2TitleGroup};

// A set of the titles level 3 related to an individual perspective.
Set<String> titlesLevel3ForTheIndividualPerspective = {
    q.level3TitleBalanceIssue,
    q.level3TitleWorkplaceIssue,
    q.level3TitleLegacyIssue,
    q.level3TitleAnotherIssue,
  };

// A set of the titles level 3 related to a group/team perspective.
  Set<String> titlesLevel3ForTheGroupPerspective = {
  q.level3TitleGroupsProblematics,
  q.level3TitleSameProblem,
  q.level3TitleHarmonyAtHome,
  q.level3TitleAppreciabilityAtWork,
  q.level3TitleIncomeEarningAbility,
};

  /// A set of the titles level 3 with sub items.
  Set<String> titlesLevel3WithSubItems = {
    q.level3TitleBalanceIssue,
    q.level3TitleWorkplaceIssue,
    q.level3TitleLegacyIssue,
  };

  // Sets of the children of the titles level 3 with sub items
  /// A set of the children of the title level 3 related to balance issues.
   Set<String> childrenOfTitleLevel3BalanceIssue = {
    q.level3TitleBalanceIssueItem1,
    q.level3TitleBalanceIssueItem2,
    q.level3TitleBalanceIssueItem3,
    q.level3TitleBalanceIssueItem4,
  };

  /// A set of the children of the title level 3 related to workplace issues.
   Set<String> childrenOfTitleLevel3WorkplaceIssue = {
    q.level3TitleWorkplaceIssueItem1,
    q.level3TitleWorkplaceIssueItem2,
  };

  /// A set of the children of the title level 3 related to a legacy issue.
  Set<String> childrenOfTitleLevel3LegacyIssue = {q.level3TitleLegacyIssueItem1};

  // A set of the text fields only items
   Set<String> textFieldOnlyItems = {
    q.level3TitleAnotherIssue,
    q.level3TitleGroupsProblematics,
  };
