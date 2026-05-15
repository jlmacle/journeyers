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
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/widgets/utility/dashboard_const_strings.dart';
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
  // Method used to check that the new process button functions
  Future<void> checkNewCAProcessButtonFunctions(WidgetTester tester) async
  {
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

  // Method used to enter a file name and to submit the CA process data on mobile device
  // (Assuming an already selected path to the user session data folder)
  Future<void> enterFileNameAndSubmitCADataOnMobile({required WidgetTester tester, required String fileNameWithoutExtension}) async
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
  
  // Method used to enter new CA process data
  // 7 values are necessary in checkboxValues
  // 4 values are necessary in segmentedButtonValues
  Future<void> enterNewCAProcessData 
  ({
    required WidgetTester tester, 
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
    
    // ── FORM SECTION ─────────────────────────────────────────────────────────────
    await fillCAForm(tester, checkboxValues, checkboxTextFieldValues, indivAnotherIssueStrValue, 
    groupProblemsToSolveStrValue, segmentedButtonValues, segmentedButtonTextFieldValues);

    // ── DATA SUBMISSION SECTION ─────────────────────────────────────────────────────────────        
    // Entering the file name and submitting data
    await enterFileNameAndSubmitCADataOnMobile(tester: tester, fileNameWithoutExtension: fileNameWithoutExtension);
  }

  // ─── DASHBOARD TESTING ───────────────────────────────────────────────────────────────

  // Method used to search a title and keywords on the dashboard
  Future<void> searchTitleAndKeywords({required String title, required List<String> kws}) async
  {
    // Searching for the title
    expect(find.text(title), findsOne);

    // Searching for the keywords
    for (var kw in kws)
    {
      expect(find.text(kw), findsOne);
    }

  }

  // Method used to find a sessions list item by title
  Future<Finder> getSessionListItemFinderByTitle(WidgetTester tester, String title) async 
  {
    Finder sessionListItemFinder = find.text(title);
    return sessionListItemFinder;
  }

  // ─── PREVIEW TESTING ───────────────────────────────────────────────────────────────

  // Serialises a segmented-button selection to a slash-separated string.
  String _segmentedButtonToString(Set<String> values) => values.join('/');

  // Method used to test a preview.
  Future<void> testPreview
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