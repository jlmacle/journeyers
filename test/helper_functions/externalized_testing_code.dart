import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_preview_widget.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_questions_fields.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/dashboard_const_strings.dart';
  
// Labels of the level 2 and 3 titles
final q = CAQuestionsFields();

// ─── EXPANSION TILES ───────────────────────────────────────────────────────────────

// Method used to open the expansion tile with the individual perspective
Future<void> openIndividualExpansionTile(WidgetTester tester) async
  {
    var tileFinder = find.text(q.level2TitleIndividual);
    await tester.ensureVisible(tileFinder);

    // Opening the individual perspective expansion tile
    await tester.tap(tileFinder);

    // Waiting for the expansion tile to be unfolded before searching descendants
    await tester.pump(const Duration(seconds: 2));

    // pumpAndSettle timed out exception if pumpAndSettle is used
    // await tester.pumpAndSettle();
  }

  // Method used to open the expansion tile with the group/team perspective
  Future<void> openGroupExpansionTile(WidgetTester tester) async
  {
    var tileFinder = find.text(q.level2TitleGroup);
    await tester.ensureVisible(tileFinder);

    // Opening the group/team perspective expansion tile
    await tester.tap(tileFinder);

    // Waiting for the expansion tile to be unfolded before searching descendants
    await tester.pump(const Duration(seconds: 2));

    // pumpAndSettle timed out exception if pumpAndSettle is used
    // await tester.pumpAndSettle();
  }

  // ─── FORM FILING ───────────────────────────────────────────────────────────────
  
  // Method used to fill a context analyis form.
  Future<void> fillCAForm
  (
    WidgetTester tester,
    List<bool> checkboxValues, List<String> checkboxTextFielValues, String indivAnotherIssueStrValue, 
    String groupProblemsToSolveStrValue, List<Set<String>> segmentedButtonValues, List<String> segmentedButtonTextFieldValues
  ) async
  {
    // ── FORM SECTION : Individual perspective ─────────────────────────────────────────────────────────────
    // Opening the individual perspective expansion tile
    await openIndividualExpansionTile(tester);  

    // 1. Searching for all custom checkboxes
    var checkboxFinder = find.descendant(
      of: find.byType(ExpansionTile).first, 
      matching: find.byType(CACheckboxWithSanitizedAndPaddedTextField),
    );

    // Getting the total number of custom checkboxes
    int totalCheckboxes = checkboxFinder.evaluate().length;
    if (testingDebug) pu.printd("Number of custom checkboxes: $totalCheckboxes");

    // Adding text to every text field under a custom checkbox
    for (int index = 0; index < totalCheckboxes; index++) 
    {
      // Searching the custom checkboxes by index
      var currentCheckbox = find.descendant(
        of: find.byType(ExpansionTile).first,
        matching: find.byType(CACheckboxWithSanitizedAndPaddedTextField),
      ).at(index);

      // if checkbox value is true, tapping the checkbox, and entering the text, if any.
      if (checkboxValues[index] == true)
      {
        await tester.ensureVisible(currentCheckbox);
        await tester.tap(currentCheckbox);
        await tester.pump();

        // Finding the text field related to the current checkbox
        var textFieldFinder = find.descendant(
          of: currentCheckbox, 
          matching: find.byType(TextField),
        );

        // Adding text        
        await tester.enterText(textFieldFinder, checkboxTextFielValues[index]);
        await tester.pumpAndSettle();
      }
    }

    // 2. Searching for the text field only
    var indivTextFieldOnlyFinder = find.descendant(
        of: find.byType(ExpansionTile).first,
        matching: find.byType(CATextFieldSanitizedAndPadded)
      // Getting the last one
      ).last;

    // Adding text in the text field
    await tester.ensureVisible(indivTextFieldOnlyFinder);
    await tester.enterText(indivTextFieldOnlyFinder, indivAnotherIssueStrValue);
    await tester.pumpAndSettle();
        
    // ── FORM SECTION : Group/Teams perspective ─────────────────────────────────────────────────────────────
    
    // Opening the group/teams perspective expansion tile
    await openGroupExpansionTile(tester); 
    
    // 1. Searching for the text field only
    var groupTextFieldOnlyFinder = find.descendant(
        of: find.byType(ExpansionTile).last,
        matching: find.byType(CATextFieldSanitizedAndPadded)
      // Getting the first one
      ).first;

    // Adding text in the text field
    await tester.ensureVisible(groupTextFieldOnlyFinder);
    await tester.enterText(groupTextFieldOnlyFinder, groupProblemsToSolveStrValue);

    // 2. Searching for all custom segmented buttons
    var segmentedButtonsFinder = find.descendant(
      of: find.byType(ExpansionTile).last, 
      matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField),
    );

    // Getting the total number of custom segmented buttons
    int totalSegmentedButtons = segmentedButtonsFinder.evaluate().length;
    if (testingDebug) pu.printd("Number of custom segmented buttons: $totalSegmentedButtons");

     for (int index = 0; index < totalSegmentedButtons; index++) 
    {
      // Searching the custom segmented buttons by index
      var currentSegButton = find.descendant(
        of: find.byType(ExpansionTile).last,
        matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField)
      ).at(index);

      // if a selection exists in the segmented button, tapping the segmented button, and entering the text, if any.
      if (segmentedButtonValues[index].isNotEmpty)
      {
        // Looping through each string in the Set for this specific SegmentedButton
        for (String optionToSelect in segmentedButtonValues[index]) {
          // Finding the specific segment by its text label
          var optionFinder = find.descendant(
            of: currentSegButton,
            matching: find.text(optionToSelect),
          );

          await tester.ensureVisible(optionFinder);
          await tester.tap(optionFinder);
          await tester.pump();
        }

        // Finding the text field related to the current checkbox
        var textFieldFinder = find.descendant(
          of: currentSegButton, 
          matching: find.byType(TextField)
        );

        // Adding text        
        await tester.enterText(textFieldFinder, segmentedButtonTextFieldValues[index]);
        await tester.pumpAndSettle();
      }    
    }
  }

  // Method used to test a preview.
  Future<void> testPreview
  (
    WidgetTester tester,
    List<bool> checkboxValues, List<String> checkboxTextFielValues, String indivAnotherIssueStrValue, 
    String groupProblemsToSolveStrValue, List<Set<String>> segmentedButtonValues, List<String> segmentedButtonTextFieldValues
  ) async
  {
    // Opening the preview
    var previewFinder = find.byTooltip(previewTooltipLabel);
    await tester.tap(previewFinder);
    await tester.pump();

    
    // To complete

    // ── PREVIEW : Group/Teams perspective ─────────────────────────────────────────────────────────────



  }