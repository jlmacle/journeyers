part of 'context_analysis_form.dart';

// ─── Heading Keys ─────────────────────────────────────────────────────────────

final GlobalKey<CustomHeadingState> _balanceIssueHeadingKey   = GlobalKey();
final GlobalKey<CustomHeadingState> _workplaceIssueHeadingKey = GlobalKey();
final GlobalKey<CustomHeadingState> _legacyIssueHeadingKey    = GlobalKey();
final GlobalKey<CustomHeadingState> _anotherIssueHeadingKey   = GlobalKey();

// ─── Form Questions ───────────────────────────────────────────────────────────

final CAFormQuestions q = CAFormQuestions();

// ─── Form State: Individual Perspective ──────────────────────────────────────

// Balance issue
final _studiesBalance         = DTOCheckboxWithTextField();
final _accessingIncomeBalance = DTOCheckboxWithTextField();
final _earningIncomeBalance   = DTOCheckboxWithTextField();
final _helpingOthersBalance   = DTOCheckboxWithTextField();

// Workplace issue
final _moreAppreciatedAtWork      = DTOCheckboxWithTextField();
final _remainingAppreciatedAtWork = DTOCheckboxWithTextField();

// Legacy issue
final _betterLegacies = DTOCheckboxWithTextField();

// Another issue (text field only)
String _anotherIssueText = '';

// ─── Form State: Groups/Teams Perspective ─────────────────────────────────────

String _groupsProblemsText = '';

final _sameProblems         = DTOSegmentedButtonWithTextField();
final _harmonyHome          = DTOSegmentedButtonWithTextField();
final _appreciabilityAtWork = DTOSegmentedButtonWithTextField();
final _earningAbility       = DTOSegmentedButtonWithTextField();

// ─── Callbacks: Individual Perspective ───────────────────────────────────────

void _onBalanceCheckbox(DTOCheckboxWithTextField data, bool? value) {
  data.checked = value!;
  _balanceIssueHeadingKey.currentState
      ?.switchCustomHeadingDecorationIfCheckboxChecked();
}

void _onWorkplaceCheckbox(DTOCheckboxWithTextField data, bool? value) {
  data.checked = value!;
  _workplaceIssueHeadingKey.currentState
      ?.switchCustomHeadingDecorationIfCheckboxChecked();
}

void _onLegacyCheckbox(DTOCheckboxWithTextField data, bool? value) {
  data.checked = value!;
  _legacyIssueHeadingKey.currentState
      ?.switchCustomHeadingDecorationIfCheckboxChecked();
}

void _onAnotherIssueText(String value) {
  _anotherIssueText = value;
  _anotherIssueHeadingKey.currentState
      ?.switchCustomHeadingDecorationIfTextFieldUsed(value);
}

// ─── Callbacks: Groups/Teams Perspective ─────────────────────────────────────

void _onSegmentedButton(DTOSegmentedButtonWithTextField data, Set<String>? values) =>
    data.selection = values ?? {};

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Serialises a segmented-button selection to a slash-separated string.
String _segmentedToString(Set<String> values) => values.join('/');

/// Converts a [DTOCheckboxWithTextField] to the standard LinkedHashMap wire format.
/// The text value is omitted (left empty) when the checkbox is unchecked.
LinkedHashMap<String, String> _checkboxDataToMap(DTOCheckboxWithTextField f) =>
    LinkedHashMap<String, String>.from({
      checkbox:  '${f.checked}',
      textField: f.checked ? f.text : '',
    });

/// Converts a [DTOSegmentedButtonWithTextField] to the standard LinkedHashMap wire format.
/// Both values are omitted (left empty) when nothing is selected.
LinkedHashMap<String, String> _segmentedDataToMap(DTOSegmentedButtonWithTextField f) =>
    LinkedHashMap<String, String>.from({
      segmentedButton: f.selection.isNotEmpty ? _segmentedToString(f.selection) : '',
      textField:       f.selection.isNotEmpty ? f.text : '',
    });

// ─── Data Structure Building ──────────────────────────────────────────────────

LinkedHashMap<String, Object> _enteredData = LinkedHashMap<String, Object>.from({});

Future<void> dataStructureBuilding() async {
  // Individual perspective
  final individualData = LinkedHashMap<String, Object>.from({
    q.level2TitleIndividual: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
      q.level3TitleBalanceIssue: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
        q.level3TitleBalanceIssueItem1: _checkboxDataToMap(_studiesBalance),
        q.level3TitleBalanceIssueItem2: _checkboxDataToMap(_accessingIncomeBalance),
        q.level3TitleBalanceIssueItem3: _checkboxDataToMap(_earningIncomeBalance),
        q.level3TitleBalanceIssueItem4: _checkboxDataToMap(_helpingOthersBalance),
      }),
      q.level3TitleWorkplaceIssue: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
        q.level3TitleWorkplaceIssueItem1: _checkboxDataToMap(_moreAppreciatedAtWork),
        q.level3TitleWorkplaceIssueItem2: _checkboxDataToMap(_remainingAppreciatedAtWork),
      }),
      q.level3TitleLegacyIssue: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
        q.level3TitleLegacyIssueItem1: _checkboxDataToMap(_betterLegacies),
      }),
      q.level3TitleAnotherIssue: LinkedHashMap<String, Object>.from({
        textField: _anotherIssueText,
      }),
    }),
  });

  // Groups/teams perspective
  final groupData = LinkedHashMap<String, Object>.from({
    q.level2TitleGroup: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
      q.level3TitleGroupsProblematics:   LinkedHashMap<String, Object>.from({textField: _groupsProblemsText}),
      q.level3TitleSameProblem:          _segmentedDataToMap(_sameProblems),
      q.level3TitleHarmonyAtHome:        _segmentedDataToMap(_harmonyHome),
      q.level3TitleAppreciabilityAtWork: _segmentedDataToMap(_appreciabilityAtWork),
      q.level3TitleIncomeEarningAbility: _segmentedDataToMap(_earningAbility),
    }),
  });

  _enteredData.addAll({"individualPerspective": individualData, "groupPerspective": groupData});

  if (sessionDataDebug) {
    pu.printd('Session Data');
    pu.printd('Session Data: _enteredData');
    pu.printd('Session Data: $_enteredData');
    pu.printd('Session Data');
  }
}
