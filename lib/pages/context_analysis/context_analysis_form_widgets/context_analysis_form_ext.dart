part of 'context_analysis_form.dart';

// ─── Local Data Classes ───────────────────────────────────────────────────────

/// Pairs a checkbox state with its associated text field content.
class _CheckboxField {
  bool checked;
  String text;
  _CheckboxField() : checked = false, text = '';
}

/// Pairs a segmented-button selection with its associated text field content.
class _SegmentedField {
  Set<String> selection;
  String text;
  _SegmentedField() : selection = {}, text = '';
}

// ─── Heading Keys ─────────────────────────────────────────────────────────────

final GlobalKey<CustomHeadingState> _balanceIssueHeadingKey   = GlobalKey();
final GlobalKey<CustomHeadingState> _workplaceIssueHeadingKey = GlobalKey();
final GlobalKey<CustomHeadingState> _legacyIssueHeadingKey    = GlobalKey();
final GlobalKey<CustomHeadingState> _anotherIssueHeadingKey   = GlobalKey();

// ─── Form Questions ───────────────────────────────────────────────────────────

final ContextAnalysisFormQuestions q = ContextAnalysisFormQuestions();

// ─── Form State: Individual Perspective ──────────────────────────────────────

// Balance issue
final _studiesBalance         = _CheckboxField();
final _accessingIncomeBalance = _CheckboxField();
final _earningIncomeBalance   = _CheckboxField();
final _helpingOthersBalance   = _CheckboxField();

// Workplace issue
final _moreAppreciatedAtWork      = _CheckboxField();
final _remainingAppreciatedAtWork = _CheckboxField();

// Legacy issue
final _betterLegacies = _CheckboxField();

// Another issue (text field only)
String _anotherIssueText = '';

// ─── Form State: Groups/Teams Perspective ─────────────────────────────────────

String _groupsProblemsText = '';

final _sameProblems         = _SegmentedField();
final _harmonyHome          = _SegmentedField();
final _appreciabilityAtWork = _SegmentedField();
final _earningAbility       = _SegmentedField();

// ─── Callbacks: Individual Perspective ───────────────────────────────────────

void _onBalanceCheckbox(_CheckboxField field, bool? value) {
  field.checked = value!;
  _balanceIssueHeadingKey.currentState
      ?.switchCustomHeadingDecorationIfCheckboxChecked();
}

void _onWorkplaceCheckbox(_CheckboxField field, bool? value) {
  field.checked = value!;
  _workplaceIssueHeadingKey.currentState
      ?.switchCustomHeadingDecorationIfCheckboxChecked();
}

void _onLegacyCheckbox(_CheckboxField field, bool? value) {
  field.checked = value!;
  _legacyIssueHeadingKey.currentState
      ?.switchCustomHeadingDecorationIfCheckboxChecked();
}

void _onAnotherIssueText(String value) {
  _anotherIssueText = value;
  _anotherIssueHeadingKey.currentState
      ?.switchCustomHeadingDecorationIfTextFieldUsed(value);
}

// ─── Callbacks: Groups/Teams Perspective ─────────────────────────────────────

void _onSegmentedButton(_SegmentedField field, Set<String>? values) =>
    field.selection = values ?? {};

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Serialises a segmented-button selection to a slash-separated string.
String _segmentedToString(Set<String> values) => values.join('/');

/// Converts a [_CheckboxField] to the standard LinkedHashMap wire format.
/// The text value is omitted (left empty) when the checkbox is unchecked.
LinkedHashMap<String, String> _checkboxFieldToMap(_CheckboxField f) =>
    LinkedHashMap<String, String>.from({
      checkbox:  '${f.checked}',
      textField: f.checked ? f.text : '',
    });

/// Converts a [_SegmentedField] to the standard LinkedHashMap wire format.
/// Both values are omitted (left empty) when nothing is selected.
LinkedHashMap<String, String> _segmentedFieldToMap(_SegmentedField f) =>
    LinkedHashMap<String, String>.from({
      segmentedButton: f.selection.isNotEmpty ? _segmentedToString(f.selection) : '',
      textField:       f.selection.isNotEmpty ? f.text : '',
    });

// ─── Data Structure Building ──────────────────────────────────────────────────

List<LinkedHashMap<String, Object>> _enteredData = [];

Future<void> dataStructureBuilding() async {
  // Individual perspective
  final individualData = LinkedHashMap<String, Object>.from({
    q.level2TitleIndividual: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
      q.level3TitleBalanceIssue: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
        q.level3TitleBalanceIssueItem1: _checkboxFieldToMap(_studiesBalance),
        q.level3TitleBalanceIssueItem2: _checkboxFieldToMap(_accessingIncomeBalance),
        q.level3TitleBalanceIssueItem3: _checkboxFieldToMap(_earningIncomeBalance),
        q.level3TitleBalanceIssueItem4: _checkboxFieldToMap(_helpingOthersBalance),
      }),
      q.level3TitleWorkplaceIssue: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
        q.level3TitleWorkplaceIssueItem1: _checkboxFieldToMap(_moreAppreciatedAtWork),
        q.level3TitleWorkplaceIssueItem2: _checkboxFieldToMap(_remainingAppreciatedAtWork),
      }),
      q.level3TitleLegacyIssue: LinkedHashMap<String, LinkedHashMap<String, Object>>.from({
        q.level3TitleLegacyIssueItem1: _checkboxFieldToMap(_betterLegacies),
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
      q.level3TitleSameProblem:          _segmentedFieldToMap(_sameProblems),
      q.level3TitleHarmonyAtHome:        _segmentedFieldToMap(_harmonyHome),
      q.level3TitleAppreciabilityAtWork: _segmentedFieldToMap(_appreciabilityAtWork),
      q.level3TitleIncomeEarningAbility: _segmentedFieldToMap(_earningAbility),
    }),
  });

  _enteredData = [individualData, groupData];

  if (sessionDataDebug) {
    pu.printd('Session Data');
    pu.printd('Session Data: _enteredData');
    pu.printd('Session Data: $_enteredData');
    pu.printd('Session Data');
  }
}
