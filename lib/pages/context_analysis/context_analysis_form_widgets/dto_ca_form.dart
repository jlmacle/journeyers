
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
  var studiesBalance              = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between accessing income and household life.
  var accessingIncomeBalance      = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between earning income and household life.
  var earningIncomeBalance        = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the balance between helping others and household life.
  var helpingOthersBalance        = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the need to be more appreciated at work.
  var moreAppreciatedAtWork       = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to need to remain appreciated at work.
  var remainingAppreciatedAtWork  = DTOCheckboxWithTextField();

  /// The DTOCheckboxWithTextField instance for the question related to the legacies we leave to our children/others.
  var betterLegacies              = DTOCheckboxWithTextField();

  // The String for the question related to an issue of another type.
  String anotherIssueStr = '';
  // ─── FIELDS: INDIVIDUAL PERSPECTIVE : end ───────────────────────────────────────


  // ─── FIELDS: GROUP PERSPECTIVE : beginning ───────────────────────────────────────
  // The String for the question related to an issue of another type.
  String groupsProblemsStr = '';

  /// The DTOSegmentedButtonWithTextField instance for the question related to solving the same problem(s) as our groups/teams.
  var sameProblems                = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with harmony at home.
  var harmonyHome                 = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with appreciability at work.
  var appreciabilityAtWork        = DTOSegmentedButtonWithTextField();

  /// The DTOSegmentedButtonWithTextField instance for the question related to a group problem-solving process consistent with our income earning ability.
  var earningAbility              = DTOSegmentedButtonWithTextField();
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
  /// Method used to gather into a LinkedHashMap the form data.
  final CAFormQuestions q = CAFormQuestions();

  Future<LinkedHashMap<String, Object> > dataStructureBuilding() async {
  final LinkedHashMap<String, Object> enteredData = LinkedHashMap<String, Object>.from({});

  // Individual perspective
  final individualData = LinkedHashMap<String, Object>.from
  ({
      q.level2TitleIndividual: 
      LinkedHashMap<String, LinkedHashMap<String, Object>>.from
      ({
        q.level3TitleBalanceIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          q.level3TitleBalanceIssueItem1: _checkboxDataToMap(studiesBalance),
          q.level3TitleBalanceIssueItem2: _checkboxDataToMap(accessingIncomeBalance),
          q.level3TitleBalanceIssueItem3: _checkboxDataToMap(earningIncomeBalance),
          q.level3TitleBalanceIssueItem4: _checkboxDataToMap(helpingOthersBalance),
        }),

        q.level3TitleWorkplaceIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          q.level3TitleWorkplaceIssueItem1: _checkboxDataToMap(moreAppreciatedAtWork),
          q.level3TitleWorkplaceIssueItem2: _checkboxDataToMap(remainingAppreciatedAtWork),
        }),

        q.level3TitleLegacyIssue: 
        LinkedHashMap<String, LinkedHashMap<String, Object>>.from
        ({
          q.level3TitleLegacyIssueItem1: _checkboxDataToMap(betterLegacies),
        }),
        
        q.level3TitleAnotherIssue: LinkedHashMap<String, Object>.from
        ({
          textField: anotherIssueStr,
        }),
      }),
    });

    // Groups/teams perspective
  final groupData = LinkedHashMap<String, Object>.from
    ({
      q.level2TitleGroup: 
      LinkedHashMap<String, LinkedHashMap<String, Object>>.from
      ({
        q.level3TitleGroupsProblematics: LinkedHashMap<String, Object>.from({textField: groupsProblemsStr}),

        q.level3TitleSameProblem:          _segmentedDataToMap(sameProblems),

        q.level3TitleHarmonyAtHome:        _segmentedDataToMap(harmonyHome),

        q.level3TitleAppreciabilityAtWork: _segmentedDataToMap(appreciabilityAtWork),

        q.level3TitleIncomeEarningAbility: _segmentedDataToMap(earningAbility),
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