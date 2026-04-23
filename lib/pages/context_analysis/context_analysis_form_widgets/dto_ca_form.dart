
import 'dart:collection';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_const_strings_and_ints.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/context_analysis_form_questions.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_custom_checkbox_with_text_field.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_widgets/dto_custom_segmented_button_with_text_field.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';

/// {@category Context analysis}
/// A DTO for the context analysis form widget.
class DTOCaForm 
{
  // ─── FIELDS: INDIVIDUAL PERSPECTIVE : beginning ───────────────────────────────────────
  /// The DTOCheckboxWithTextField instance for the question related to the balance between studies and household life.
  var indivBalanceStudiesHousehold              = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between accessing income and household life.
  var indivBalanceAccessingIncomeHousehold      = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between earning income and household life.
  var indivBalanceEarningIncomeHousehold        = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between helping others and household life.
  var indivBalanceHelpingOthersHouseholds        = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the need to be more appreciated at work.
  var indivAtWorkMoreAppreciated       = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to need to remain appreciated at work.
  var indivAtWorkRemainingAppreciated  = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the legacies we leave to our children/others.
  var indivBetterLegacies              = DTOCheckboxWithTextField();

  /// The String for the question related to an issue of another type.
  String indivAnotherIssueStr = '';
  // ─── FIELDS: INDIVIDUAL PERSPECTIVE : end ───────────────────────────────────────


  // ─── FIELDS: GROUP PERSPECTIVE : beginning ───────────────────────────────────────
  /// The String for the question related to the problems that the group/teams are trying to solve.
  String groupProblemsToSolveStr = '';

  /// The DTOSegmentedButtonWithTextField instance for the question related to solving the same problem(s) as our groups/teams.
  var groupSameProblemsToSolve                = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with harmony at home.
  var groupHarmonyHome                 = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with appreciability at work.
  var groupAppreciabilityAtWork        = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with our income earning ability.
  var groupEarningAbility              = DTOSegmentedButtonWithTextField();
  // ─── FIELDS: GROUP PERSPECTIVE : end ───────────────────────────────────────

  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : HELPER METHODS: beginning ───────────────────────────────────────
  // Converts a [DTOCheckboxWithTextField] to the standard [LinkedHashMap] wire format.
  // The text value is omitted (left empty) when the checkbox is unchecked.
  LinkedHashMap<String, String> _checkboxDataToMap(DTOCheckboxWithTextField f) =>
      LinkedHashMap<String, String>.from({
        checkbox:  '${f.checked}',
        textField: f.checked ? f.text : '',
      });

  // Converts a [DTOSegmentedButtonWithTextField] to the standard [LinkedHashMap] wire format.
  // Both values are omitted (left empty) when nothing is selected.
  LinkedHashMap<String, String> _segmentedDataToMap(DTOSegmentedButtonWithTextField f) =>
      LinkedHashMap<String, String>.from({
        segmentedButton: f.selection.isNotEmpty ? _segmentedToString(f.selection) : '',
        textField:       f.selection.isNotEmpty ? f.text : '',
        });

  // Serialises a segmented-button selection to a slash-separated string.
  String _segmentedToString(Set<String> values) => values.join('/');
  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : HELPER METHODS: beginning ───────────────────────────────────────

  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : beginning ───────────────────────────────────────
  final CAFormQuestions _q = CAFormQuestions();

  /// Method used to gather the form data into a LinkedHashMap.
  Future<LinkedHashMap<String, Object> > dataStructureBuilding() async {
  final LinkedHashMap<String, Object> enteredData = LinkedHashMap<String, Object>.from({});

  // Individual perspective
  final individualData = LinkedHashMap<String, Object>.from
  ({
      _q.level2TitleIndividual: 
      LinkedHashMap<String, LinkedHashMap<String, Object>>.from
      ({
        _q.level3TitleBalanceIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          _q.level3TitleBalanceIssueItem1: _checkboxDataToMap(indivBalanceStudiesHousehold),
          _q.level3TitleBalanceIssueItem2: _checkboxDataToMap(indivBalanceAccessingIncomeHousehold),
          _q.level3TitleBalanceIssueItem3: _checkboxDataToMap(indivBalanceEarningIncomeHousehold),
          _q.level3TitleBalanceIssueItem4: _checkboxDataToMap(indivBalanceHelpingOthersHouseholds),
        }),

        _q.level3TitleWorkplaceIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          _q.level3TitleWorkplaceIssueItem1: _checkboxDataToMap(indivAtWorkMoreAppreciated),
          _q.level3TitleWorkplaceIssueItem2: _checkboxDataToMap(indivAtWorkRemainingAppreciated),
        }),

        _q.level3TitleLegacyIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          _q.level3TitleLegacyIssueItem1: _checkboxDataToMap(indivBetterLegacies),
        }),
        
        _q.level3TitleAnotherIssue: LinkedHashMap<String, Object>.from
        ({
          textField: indivAnotherIssueStr,
        }),
      }),
    });

    // Groups/teams perspective
  final groupData = LinkedHashMap<String, Object>.from
    ({
      _q.level2TitleGroup: 
      LinkedHashMap<String, LinkedHashMap<String, Object>>.from
      ({
        _q.level3TitleGroupsProblematics: LinkedHashMap<String, Object>.from({textField: groupProblemsToSolveStr}),

        _q.level3TitleSameProblem:          _segmentedDataToMap(groupSameProblemsToSolve),

        _q.level3TitleHarmonyAtHome:        _segmentedDataToMap(groupHarmonyHome),

        _q.level3TitleAppreciabilityAtWork: _segmentedDataToMap(groupAppreciabilityAtWork),

        _q.level3TitleIncomeEarningAbility: _segmentedDataToMap(groupEarningAbility),
      }),
    });

    enteredData.addAll({"individualPerspective": individualData, "groupPerspective": groupData});

    if (sessionDataDebug) {
      pu.printd('Session Data');
      pu.printd('Session Data: enteredData');
      pu.printd('Session Data: $enteredData');
      pu.printd('Session Data');
    }

    return enteredData;
  }
  // ─── DATA STRUCTURE BUILDING : LINKEDHASHMAP : end ───────────────────────────────────────
}