import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_preview_widget.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/1_context_analysis_title_declaration.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/2_context_analysis_keywords_declaration.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_questions_fields.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/4_dashboard_sessions_list_item.dart';
import 'package:journeyers/widgets/utility/process_widgets/new_process_button.dart';
import 'package:journeyers/widgets/utility/process_widgets/session_file_name_mobile_platforms.dart';
  
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

// ─── CA PROCESS FILING ───────────────────────────────────────────────────────────────
  // Method used to check that the new CA process button functions
  Future<void> checkNewCAProcessButtonFunctions(WidgetTester tester) async
  {
    // To avoid intermittent test failures
    await tester.pump(const Duration(seconds: 2)); 

    // Verifying the NewProcessButton present
    expect(
      find.byType(NewProcessButton),
      findsOneWidget,
      reason: 'NewProcessButton should be visible when CA session data is already saved.',
    );

    // Tapping NewProcessButton
    await tester.tap(find.byType(NewProcessButton));
    // pumpAndSettle waits for CAProcess (and its _loadDTO / initState async work)
    // to settle before searching for children widgets.
    await tester.pumpAndSettle();

    // Verifying CAProcess displayed
    expect(
      find.byType(CAProcess),
      findsOneWidget,
      reason: 'CAProcess should be visible after tapping NewProcessButton.',
    );
  }
 
  // Method used to enter a title in the CA process
  Future<void> enterCAProcessTitle (WidgetTester tester, String aTitle) async
  {
    // Searching the TextField inside CATitleDeclaration
    Finder titleTextField = find.descendant(
      of: find.byType(CATitleDeclaration),
      matching: find.byType(TextField),
    );

    expect(
      titleTextField,
      findsOneWidget,
      reason: 'A TextField should exist inside CATitleDeclaration.',
    );

    // Entering a title
    await tester.enterText(titleTextField, aTitle);
  }
  
  // Method used to enter keywords in the CA process
  Future<void> enterCAProcessKeywords (WidgetTester tester, List<String> keywordsList) async
  {
    // Searching the TextField inside CAKeywordsDeclaration
    Finder keywordsTextField = find.descendant(
      of: find.byType(CAKeywordsDeclaration),
      matching: find.byType(TextField),
    );

    for (var kw in keywordsList)
    {
      // Entering the keyword
      await tester.enterText(keywordsTextField, kw);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Necessary for the next keyword to be added
      await tester.tap(keywordsTextField);
      
      await tester.pumpAndSettle();
    }
  }      

  // Method used to fill a context analyis form.
  Future<void> fillCAForm
  (
    WidgetTester tester,
    List<bool> checkboxValues, List<String> checkboxTextFieldValues, String indivAnotherIssueStrValue, 
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
        await tester.enterText(textFieldFinder, checkboxTextFieldValues[index]);
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

  // Method used to enter new CA process data
  // 7 values are necessary in checkboxValues
  // 4 values are necessary in segmentedButtonValues
  Future<void> enterNewCAProcessData 
  ({
    required WidgetTester tester, 
    bool formToFill = true,
    required String title,
    required List<String> kwsList,
    List<bool> checkboxValues = const [false, false, false, false, false, false, false], List<String> checkboxTextFieldValues = const [], String indivAnotherIssueStrValue = "", 
    String groupProblemsToSolveStrValue = "", List<Set<String>> segmentedButtonValues = const [{}, {}, {}, {}], List<String> segmentedButtonTextFieldValues = const [],
    String fileNameWithoutExtension = ""
  }) async
  {
    // ── 1. CLICK TOWARD A NEW CA PROCESS ───────────────────────────────────────────────
    // ───────────────────────────────────────────────────────────────────────────────────
    // Verifying that the new process button functions
    await checkNewCAProcessButtonFunctions(tester);


    // ── 2. CA PROCESS FILLING ──────────────────────────────────────────────────────────
    // ───────────────────────────────────────────────────────────────────────────────────

    // ── TITLE SECTION ─────────────────────────────────────────────────────────────
    await enterCAProcessTitle(tester, title);

    // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
    await enterCAProcessKeywords(tester, kwsList);
    
    if (formToFill)
    {
      // ── FORM SECTION ─────────────────────────────────────────────────────────────
      await fillCAForm(tester, checkboxValues, checkboxTextFieldValues, indivAnotherIssueStrValue, 
      groupProblemsToSolveStrValue, segmentedButtonValues, segmentedButtonTextFieldValues);
    }

    // ── DATA SUBMISSION SECTION ─────────────────────────────────────────────────────────────        
    // Entering the file name and submitting data
    await enterFileNameAndSubmitDataOnMobile(tester: tester, fileNameWithoutExtension: fileNameWithoutExtension);
  }

  // Method used to add several times context analysis data
  // The method assumes all lists have the same number of elements
  Future<void> enterSeveralTimesNewCAProcessData
  ({
    required bool formToFill,
    required WidgetTester tester,
    required List<String> titlesList,
    required List<List<String>> kwsLists,
    required List<String> fileNamesWithoutExtensionList
  }) async
  {
    int listsLength = titlesList.length;
    for (var index = 0; index < listsLength; index++)
    {
      await enterNewCAProcessData
      (
        formToFill: false,
        tester: tester, 
        title: titlesList[index],
        kwsList: kwsLists[index],              
        fileNameWithoutExtension: fileNamesWithoutExtensionList[index]
      );
    }
  }

// ─── GPS PROCESS ───────────────────────────────────────────────────────────────
// Method used to check that the new GPS process button functions
  Future<void> checkNewGPSProcessButtonFunctions(WidgetTester tester) async
  {
    // Verifying the NewProcessButton present
    expect(
      find.byType(NewProcessButton),
      findsOneWidget,
      reason: 'NewProcessButton should be visible when GPS session data is already saved.',
    );

    // Tapping NewProcessButton
    await tester.tap(find.byType(NewProcessButton));
    await tester.pumpAndSettle();

    // Verifying GPSProcess displayed
    expect(
      find.byType(GPSProcess),
      findsOneWidget,
      reason: 'GPSProcess should be visible after tapping NewProcessButton.',
    );
  }

// Method used to enter a title in the GPS process
  Future<void> enterGPSProcessTitle (WidgetTester tester, String aTitle) async
  {
    // Searching the placeholder title
    var placeholderTitleFinder = find.text(gpsTitlePlaceholder);

    // Tapping on it
    await tester.tap(placeholderTitleFinder);
    await tester.pumpAndSettle();

    // Searching the text field
    var textFieldFinder = find.ancestor
    (
      of: find.text(gpsTitleTextFieldHint), 
      matching: find.byType(TextField)
    );

    expect(
      textFieldFinder,
      findsOneWidget,
    );

    // Entering the title
    await tester.enterText(textFieldFinder, aTitle);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

// Method used to enter keywords in the GPS process
  Future<void> enterGPSProcessKeywords (WidgetTester tester, List<String> keywordsList) async
  {
    // Searching the keywords declaration title
    var keywordsDeclarationTitleFinder = find.descendant
                                  (
                                    of: find.byType(GPSKeywordsDeclaration), 
                                    matching: find.text(keywordsDeclarationTitle)
                                  );

    // Tapping on it to open the overlay
    await tester.tap(keywordsDeclarationTitleFinder);
    // pumpAndSettle timed out
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2)); 

    // The overlay should have opened
    // Searching the text field
    var textfieldFinder = find.descendant
                          (
                            of: find.byType(StatefulBuilder), 
                            matching: find.byType(TextField)
                          );   

    for (var kw in keywordsList)
    {
      // Entering the keyword
      await tester.enterText(textfieldFinder, kw);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(seconds: 2)); 

      // Necessary for the next keyword to be added
      await tester.tap(textfieldFinder);         
    }

    // Searching the tooltip to close the overlay
    var closingIconFinder = find.byTooltip(closeKeywordsDeclarationTooltipLabel);

    // Closing the overlay
    await tester.tap(closingIconFinder);
    // pumpAndSettle timed out
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2)); 

    // Verifying the overlay absent
    expect
    (
      find.descendant
      (
        of: find.byType(GPSKeywordsDeclaration), 
        matching: find.byType(StatefulBuilder)
      )        , 
      findsNothing
    );
  }      

// Method used to enter ideas
  Future<void> enterIdeas
  (
    WidgetTester tester,
    List<String> ideasList
  ) async
  {
    // Searching the text field used to add ideas
    var newSolutionTextFieldFinder = find.ancestor
    (
      of: find.text(newIdeaTextFieldHint), 
      matching: find.byType(TextField)
    );

    // Adding the ideas
    for (var idea in ideasList)
    {
      await tester.enterText(newSolutionTextFieldFinder, idea);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // pumpAndSettle timed out
      // await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));  

      await tester.tap(newSolutionTextFieldFinder); 
    }
      
  }

// Method used to enter new GPS process data
Future<void> enterNewGPSProcessData 
({
  required WidgetTester tester, 
  required String title,
  required List<String> kwsList,
  required List<String> ideasList,
  required String fileNameWithoutExtension
}) async
{
  // ── 1. CLICK TOWARD A NEW GPS PROCESS ───────────────────────────────────────────────
  // ───────────────────────────────────────────────────────────────────────────────────
  // Verifying that the new process button functions
  await checkNewGPSProcessButtonFunctions(tester);


  // ── 2. GPS PROCESS FILLING ──────────────────────────────────────────────────────────
  // ───────────────────────────────────────────────────────────────────────────────────

  // ── TITLE SECTION ─────────────────────────────────────────────────────────────
  await enterGPSProcessTitle(tester, title);

  // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
  await enterGPSProcessKeywords(tester, kwsList);
  
  // ── SOLUTIONS SECTION ─────────────────────────────────────────────────────────────
  await enterIdeas(tester, ideasList);
  
  // ── DATA SUBMISSION SECTION ─────────────────────────────────────────────────────────────        
  // Entering the file name and submitting data
  await enterFileNameAndSubmitDataOnMobile(tester: tester, fileNameWithoutExtension: fileNameWithoutExtension);
}

  // Method used to add several times group problem-solving data
  // The method assumes all lists have the same number of elements
  Future<void> enterSeveralTimesNewGPSProcessData
  ({
    required WidgetTester tester,
    required List<String> titlesList,
    required List<List<String>> kwsLists,
    required List<List<String>> ideasList,
    required List<String> fileNamesWithoutExtensionList
  }) async
  {
    int listsLength = titlesList.length;
    for (var index = 0; index < listsLength; index++)
    {
      await enterNewGPSProcessData 
      (
        tester: tester, 
        title: titlesList[index],
        kwsList: kwsLists[index], 
        ideasList: ideasList[index],
        fileNameWithoutExtension: fileNamesWithoutExtensionList[index]
      );
    }
  }

// Method used to add an identifier
 Future<Finder> addIdentifier(WidgetTester tester) async
 {
  // Finding the add emoji    
  var emojiFinder = find.text(addEmoji);
  // Tapping to add an identifier
  await tester.tap(emojiFinder);
  // pumpAndSettle timed out
  // await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2));
  // Verifying the identifier present
  var identifierWidgetFinder = find.byType(IdentifierWidget);

  return identifierWidgetFinder;

 }

// Method used to test the color of an identifier
Future<void> testIdentifierColor(WidgetTester tester, Color color) async
{
  // Searching the container
  var containerFinder = find.descendant
  (
    of: find.byType(IdentifierWidget), 
    matching: find.byType(Container)
  );

  var totalContainers = containerFinder.evaluate().length;
  if (testingDebug) pu.printd('Testing Debug: totalContainers: $totalContainers');

  Container container = tester.widget<Container>(containerFinder);
  var boxDecoration = container.decoration as BoxDecoration;
  var border = boxDecoration.border as Border;

  // Verifying the default circle color
  expect(
    border.top.color,
    color,
  );

  expect(
    border.bottom.color,
    color,
  );

  expect(
    border.right.color,
    color,
  );

  expect(
    border.left.color,
    color,
  );
}

// Method used to enter edit mode
Future<void> enterEditMode(WidgetTester tester) async
{
  // Searching the edit button
  var editButtonFinder = find.descendant
                        (
                          of: find.byType(ElevatedButton),
                          matching: find.text(editEmoji)
                        );
  
  var totalButton = editButtonFinder.evaluate().length;
  if (testingDebug) pu.printd('Testing Debug: totalButton: $totalButton');

  // Tapping the edit button
  await tester.tap(editButtonFinder);
  // pumpAndSettle timed out
  // await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2));
}

// Method used to test the color of the checklist title border
Future<void> testChecklistTitleBorderColor(WidgetTester tester, Color color) async
{
  // Searching the container
  var containerFinder = find.descendant
  (
    of: find.byType(GPSChecklist), 
    matching: find.byType(Container)
  );

  var totalContainers = containerFinder.evaluate().length;
  if (testingDebug) pu.printd('Testing Debug: totalContainers: $totalContainers');

  Container container = tester.widget<Container>(containerFinder);
  var boxDecoration = container.decoration as BoxDecoration;
  var border = boxDecoration.border as Border;

  // Verifying the color
  expect(
    border.top.color,
    color,
  );

  expect(
    border.bottom.color,
    color,
  );

  expect(
    border.right.color,
    color,
  );

  expect(
    border.left.color,
    color,
  );
}

// ─── MULTI-CONTEXT HELPER FUNCTION ───────────────────────────────────────────────────────────────

// Method used to enter a file name and to submit the CA process data on mobile device
// (Assuming an already selected path to the user session data folder)
Future<void> enterFileNameAndSubmitDataOnMobile({required WidgetTester tester, required String fileNameWithoutExtension}) async
{
  Finder fileNameWidgetFinder =  find.byType(SessionFileNameMobilePlatforms);

  // Path to folder already declared 
  // Scrolling to make the text field visible for small screens
  await tester.ensureVisible(fileNameWidgetFinder);

  // Entering a file name
  await tester.enterText(fileNameWidgetFinder, fileNameWithoutExtension);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();  
}  

// ─── DASHBOARD TESTING ───────────────────────────────────────────────────────────────
  // Method used to search a title and keywords on the dashboard
  Future<void> searchTitleAndKeywords({required String title, required List<String> kws, String? titleSuffix}) async
  {
    if (titleSuffix != null) title = "$title$titleSuffix";
    // Searching for the title
    expect(find.text(title), findsOne);

    // Searching for the keywords
    for (var kw in kws)
    {
      expect(find.text(kw), findsOne);
    }

  }

  // Method used to get the finder of a sessions list item by title
  Future<Finder> getSessionListItemFinderByTitle({required WidgetTester tester, required String title, String? titleSuffix}) async 
  {
    if (titleSuffix != null) title = "$title$titleSuffix";
    Finder sessionListItemFinder = find.text(title);
    return sessionListItemFinder;
  }

  // Method used to get the finder of the sessions titles
  Future<Finder> getAllSessionsTitles(WidgetTester tester) async
  {
    var titlesFinder = find.byWidgetPredicate
    (
      (widget) 
      {
        if (widget.key is ValueKey<String>) {
          return (widget.key as ValueKey<String>).value.contains('session-title-');
        }
        return false;
      }
    );  

    return titlesFinder;
  }

  // Method used to get the finder of a keyword FilterChip
  Future<Finder> getKwFilterChip(WidgetTester tester, String kw) async
  {
    var filterChipFinder = find.byWidgetPredicate
    (
      (widget) 
      {
        if (widget is FilterChip) {
          final label = widget.label;
          if (label is Text) {
            return (label.data ?? '').contains(kw);
          }
        }
        return false;
      }      
    );  

    return filterChipFinder;
  }
  

// ─── PREVIEW TESTING ───────────────────────────────────────────────────────────────

  // Serialises a segmented-button selection to a slash-separated string.
  String _segmentedButtonToString(Set<String> values) => values.join('/');

  // Method used to test a CA preview.
  Future<void> testCAPreview
  ({
    required WidgetTester tester, 
    List<String> individualStringValues = const ["", "", "", "", "", "", "", ""], 
    List<Set<String>> segmentedButtonValues = const [{}, {}, {}, {}, {}], 
    List<String> groupStringValues = const ["", "", "", "", ""]
  }) async
  {

    if (testingDebug) pu.printd("Individual perspective values: $individualStringValues");
    if (testingDebug) pu.printd("Group/teams perspective values: $groupStringValues");

    // The total number of expansion tile for the individual perspective
    int totalIndivExpansionTiles = 0;
    // Data with the form questions
    CAQuestionsFields q = .new();

    // Opening the preview
    var previewFinder = find.byTooltip(previewTooltipLabel);
    await tester.tap(previewFinder);
    await tester.pump(const Duration(seconds: 2));

    //Searching for the expansion tiles
    var  expansionTilesFinder = find.descendant
    (
      of: find.byType(CAPreviewWidget), 
      matching: find.byType(ExpansionTile)
    );

    // Getting the total number of expansion tiles
    int totalExpansionTiles = expansionTilesFinder.evaluate().length;
    if (testingDebug) pu.printd("Number of expansion tiles: $totalExpansionTiles");
    // Should be 9: 4 for the individual perspective, 5 for the group/teams perspective

    // Expansion tile indexes for the individual perspective
    var indivIndexes = List.generate(4, (i)=> i);
    // Expansion tile indexes for the group/teams perspective
    var groupIndexes = List.generate(5, (i)=> i+4);

    if (testingDebug) pu.printd("Expansion tile indexes for the individual perspective: $indivIndexes");
    if (testingDebug) pu.printd("Expansion tile indexes for the group/teams perspective: $groupIndexes");
    
    // To have the index of the data for each perspective
    // Reset for the group/teams perspective
    int previewListTileDataIndex = -1;

    // Accessing the expansion tiles by index
    for (int expansionTileIndex = 0; expansionTileIndex < totalExpansionTiles; expansionTileIndex++) 
    {  
      // Searching the expansion tile by index
      var currentExpansionTileFinder = find.descendant(
        of: find.byType(CAPreviewWidget),
        matching: find.byType(ExpansionTile),
      ).at(expansionTileIndex);

      // Getting the expansion tile title
      ExpansionTile expansionTileWidget = tester.widget<ExpansionTile>(currentExpansionTileFinder);
      Text expansionTileTitleWidget = expansionTileWidget.title as Text;
      String expansionTileTitle = expansionTileTitleWidget.data!;
      if (testingDebug) pu.printd("\n Expansion tile title: $expansionTileTitle");
      
      // Getting all the list tiles for the expansion tile
      var listTilesFinder = find.descendant
      (
        of: currentExpansionTileFinder, 
        matching: find.byType(ListTile)
      );

      // Getting the total number of list tiles for this expansion tile
      int totalListTiles = listTilesFinder.evaluate().length;
      if (testingDebug) {
        pu.printd("Number of list tiles for: $expansionTileTitle: $totalListTiles. \n"
                  "(The expansion tile is included. The first index is skipped.)");
      }

      if (q.level3TitlesIndividual.contains(expansionTileTitle)) 
      {        
        totalIndivExpansionTiles++;
      }
      
      // Accessing each list tile by index 
      // Index starting at 1 to skip the expansion tile
      for (int listTileIndex = 1; listTileIndex < totalListTiles; listTileIndex++) 
      {  
        // No expansion tile if the checkbox is not checked
        // Resetting at the first group/teams expansion tile
        if ( expansionTileIndex == totalIndivExpansionTiles ) 
        { 
          if (testingDebug) {pu.printd("Resetting previewListTileDataIndex at expansionTileIndex: $expansionTileIndex");}
          previewListTileDataIndex = 0; 
        }
        else {previewListTileDataIndex++;}

        // Searching the tiles by index
        var currentListTile = find.descendant(
          of: currentExpansionTileFinder, 
          matching: find.byType(ListTile)
        ).at(listTileIndex);
        
        // Getting the list tile title
        ListTile listTileWidget = tester.widget<ListTile>(currentListTile);
        Text listTileTitleWidget = listTileWidget.title as Text;
        String listTileTitle = listTileTitleWidget.data!;
        if (testingDebug) pu.printd("List tiles title for: $expansionTileTitle: $listTileTitle");
        if (testingDebug) pu.printd("expansionTileIndex: $expansionTileIndex, listTileIndex: $listTileIndex");

        // Testing if the expansion tile is related to the individual perspective
        if (q.level3TitlesIndividual.contains(expansionTileTitle))
        {
          // The last individual perspective expansion tile is for a text field only data
          // For a text field only, the notes are in the title
          if (expansionTileTitle == q.level3TitleAnotherIssue  && listTileIndex == 1)
          {
            expect(listTileTitle, "Notes: ${individualStringValues[previewListTileDataIndex]}");
          }
          // Otherwise the notes are in the subtitle, for the individual perspective
          else {
            // Getting the list tile subtitle
            Text listTileSubTitleWidget = listTileWidget.subtitle as Text;
            String listTileSubTitle = listTileSubTitleWidget.data!;
            if (testingDebug) pu.printd("List tiles subtitle for $expansionTileTitle: $listTileSubTitle");
            
            expect(listTileSubTitle, "Notes: ${individualStringValues[previewListTileDataIndex]}");
          }          

        }
        // Group/teams expansion tiles
        else
        {
          // The first group/teams perspective expansion tile is for a text field only data
          // For a text field only, the notes are in the title
          if (expansionTileTitle == q.level3TitleGroupsProblematics  && listTileIndex == 1)
          {
            expect(listTileTitle, "Notes: ${groupStringValues[previewListTileDataIndex]}");
          }
          // Otherwise the notes are in the title with the segmented button answers
          else{
            var segButtonValue = segmentedButtonValues[previewListTileDataIndex-1];
             
            if(segButtonValue.isNotEmpty)
            {
              var segButtonAnswersWithNotes = "Answer(s): ${_segmentedButtonToString(segButtonValue)}\n"
                                            "Notes: ${groupStringValues[previewListTileDataIndex]}";
              expect(listTileTitle, segButtonAnswersWithNotes);
            }
            else
            {
              expect(listTileTitle,  "Notes: ");
            }
          }             
        }
      }
    }  
  }

  // Method used to test a GPS preview.
  Future<void> testGPSPreview
  ({
    required WidgetTester tester, 
    required String title,
    required List<String> ideasList
  }) async
  {
    // Searching the preview tooltip for the session
    var listItemFinder = find.ancestor
                        (
                          of: find.text("$title$gpsTitleSuffix"), 
                          matching: find.byType(SessionsListItem)
                        );

    var previewTooltipFinder = find.descendant
    (
      of: listItemFinder,       
      matching: find.byTooltip(previewTooltipLabel)
    );

    // Opening the preview
    await tester.tap(previewTooltipFinder);
    await tester.pumpAndSettle();

    // Searching for the title
    var titleInAppBarFinder = find.descendant
    (
      of: find.byType(AppBar), 
      matching: find.text(title)
    );

    // Verifying the title present
    expect (titleInAppBarFinder, findsOne);

    // TODO: To finish. Code valuable as is.
    // Verifying the ideas present
    for (var idea in ideasList)
    {
      expect(find.text(idea), findsOne);
    }
  }