import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/pages/context_analysis/context_analysis_preview_widget.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/1_context_analysis_title_declaration.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/2_context_analysis_keywords_declaration.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/_context_analysis_questions_fields.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/dashboard_const_strings.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/4_dashboard_sessions_list_item.dart";
import "package:journeyers/widgets/utility/lists/tmp_participants_widgets/participants_dashboard/list_dashboard_const_strings.dart";
import "package:journeyers/widgets/utility/lists/new_text_list_or_loading_page_externalized_strings.dart";
import "package:journeyers/widgets/utility/process/new_process_button.dart";
import "package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart";
  
// Labels of the level 2 and 3 titles
final q = CAQuestionsFields();

// ─── CA  ───────────────────────────────────────────────────────────────
// ───────────────────────────────────────────────────────────────────────

// ─── EXPANSION TILES ───────────────────────────────────────────────────────────────
  // Method used to open the expansion tile with the individual perspective
  Future<void> caOpenIndividualExpansionTile(WidgetTester tester) async
  {
    var tileFinder = find.text(q.level2TitleIndividual);
    await tester.ensureVisible(tileFinder);

    // Opening the individual perspective expansion tile
    await tester.tap(tileFinder);

    // pumpAndSettle timed out exception if pumpAndSettle is used
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
  }

  // Method used to open the expansion tile with the group/team perspective
  Future<void> caOpenGroupExpansionTile(WidgetTester tester) async
  {
    var tileFinder = find.text(q.level2TitleGroup);
    await tester.ensureVisible(tileFinder);

    // Opening the group/team perspective expansion tile
    await tester.tap(tileFinder);

    // Waiting for the expansion tile to be unfolded before searching descendants
    // pumpAndSettle timed out exception if pumpAndSettle is used
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
  }

// ─── CA PROCESS FILING ───────────────────────────────────────────────────────────────
  // Method used to check that the new CA process button functions
  Future<void> caCheckNewProcessButtonFunctions(WidgetTester tester) async
  {
    // To avoid intermittent test failures
    await tester.pump(const Duration(seconds: 2)); 

    // Verifying the NewProcessButton present
    expect(
      find.byType(NewProcessButton),
      findsOneWidget,
      reason: "NewProcessButton should be visible when CA session data is already saved.",
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
      reason: "CAProcess should be visible after tapping NewProcessButton.",
    );
  }
 
  // Method used to enter a title in the CA process
  Future<void> caEnterProcessTitle (WidgetTester tester, String aTitle) async
  {
    // Searching the TextField inside CATitleDeclaration
    Finder titleTextField = find.descendant(
      of: find.byType(CATitleDeclaration),
      matching: find.byType(TextField),
    );

    expect(
      titleTextField,
      findsOneWidget,
      reason: "A TextField should exist inside CATitleDeclaration.",
    );

    // Entering a title
    await tester.enterText(titleTextField, aTitle);
  }
  
  // Method used to enter keywords in the CA process
  Future<void> caEnterProcessKeywords (WidgetTester tester, List<String> keywordsList) async
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
  Future<void> caFillForm
  (
    WidgetTester tester,
    List<bool> checkboxValues, List<String> checkboxTextFieldValues, String indivAnotherIssueStrValue, 
    String groupProblemsToSolveStrValue, List<Set<String>> segmentedButtonValues, List<String> segmentedButtonTextFieldValues
  ) async
  {
    // ── FORM SECTION : Individual perspective ─────────────────────────────────────────────────────────────
    // Opening the individual perspective expansion tile
    await caOpenIndividualExpansionTile(tester);  

    // 1. Searching for all custom checkboxes
    var checkboxFinder = find.descendant(
      of: find.byType(ExpansionTile).first, 
      matching: find.byType(CACheckboxWithSanitizedAndPaddedTextField),
    );

    // Getting the total number of custom checkboxes
    int totalCheckboxes = checkboxFinder.evaluate().length;
    if (testingDebug) pu.printd("Testing Debug: Number of custom checkboxes: $totalCheckboxes");

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

        // Searching the text field related to the current checkbox
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
    await caOpenGroupExpansionTile(tester); 
    
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
    if (testingDebug) pu.printd("Testing Debug: Number of custom segmented buttons: $totalSegmentedButtons");

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
          // Searching the specific segment by its text label
          var optionFinder = find.descendant(
            of: currentSegButton,
            matching: find.text(optionToSelect),
          );

          await tester.ensureVisible(optionFinder);
          await tester.tap(optionFinder);
          await tester.pump();
        }

        // Searching the text field related to the current checkbox
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
  Future<void> caEnterNewProcessDataOnMobile 
  ({
    required WidgetTester tester, 
    bool formToFill = true,
    required String title,
    required List<String> kwsList,
    List<bool> checkboxValues = const [false, false, false, false, false, false, false], List<String> checkboxTextFieldValues = const [], String indivAnotherIssueStrValue = "", 
    String groupProblemsToSolveStrValue = "", List<Set<String>> segmentedButtonValues = const [{}, {}, {}, {}], List<String> segmentedButtonTextFieldValues = const [],
    required String fileNameWithoutExtension
  }) async
  {
    // ── 1. CLICK TOWARD A NEW CA PROCESS ───────────────────────────────────────────────
    // ───────────────────────────────────────────────────────────────────────────────────
    // Verifying that the new process button functions
    await caCheckNewProcessButtonFunctions(tester);


    // ── 2. CA PROCESS FILLING ──────────────────────────────────────────────────────────
    // ───────────────────────────────────────────────────────────────────────────────────

    // ── TITLE SECTION ─────────────────────────────────────────────────────────────
    await caEnterProcessTitle(tester, title);

    // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
    await caEnterProcessKeywords(tester, kwsList);
    
    if (formToFill)
    {
      // ── FORM SECTION ─────────────────────────────────────────────────────────────
      await caFillForm(tester, checkboxValues, checkboxTextFieldValues, indivAnotherIssueStrValue, 
      groupProblemsToSolveStrValue, segmentedButtonValues, segmentedButtonTextFieldValues);
    }

    // ── DATA SUBMISSION SECTION ─────────────────────────────────────────────────────────────        
    // Entering the file name and submitting data
    await dashboardEnterFileNameAndSubmitDataOnMobile(tester: tester, fileNameWithoutExtension: fileNameWithoutExtension);
  }

  // Method used to add several times context analysis data
  // The method assumes all lists have the same number of elements
  Future<void> caEnterSeveralTimesNewProcessData
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
      await caEnterNewProcessDataOnMobile
      (
        formToFill: false,
        tester: tester, 
        title: titlesList[index],
        kwsList: kwsLists[index],              
        fileNameWithoutExtension: fileNamesWithoutExtensionList[index]
      );
    }
  }

// ─── CA PREVIEW ───────────────────────────────────────────────────────────────
  // Method used to test a CA preview.
  Future<void> caTestPreview
  ({
    required WidgetTester tester, 
    required String title,
    List<String> individualStringValues = const ["", "", "", "", "", "", "", ""], 
    List<Set<String>> segmentedButtonValues = const [{}, {}, {}, {}, {}], 
    List<String> groupStringValues = const ["", "", "", "", ""]
  }) async
  {

    if (testingDebug) pu.printd("Testing Debug: Preview: Individual perspective values: $individualStringValues");
    if (testingDebug) pu.printd("Testing Debug: Preview: Group/teams perspective values: $groupStringValues");

    // The total number of expansion tile for the individual perspective
    int totalIndivExpansionTiles = 0;
    // Data with the form questions
    CAQuestionsFields q = .new();

    // Opening the preview
    var previewFinder = find.byTooltip(previewTooltipLabel);
    await tester.tap(previewFinder);
    await tester.pumpAndSettle();

    //Searching for the expansion tiles
    var  expansionTilesFinder = find.descendant
    (
      of: find.byType(CAPreview), 
      matching: find.byType(ExpansionTile)
    );

    // Getting the total number of expansion tiles
    int totalExpansionTiles = expansionTilesFinder.evaluate().length;
    if (testingDebug) pu.printd("Testing Debug: Number of expansion tiles: $totalExpansionTiles");
    // Should be 9: 4 for the individual perspective, 5 for the group/teams perspective

    // Expansion tile indexes for the individual perspective
    var indivIndexes = List.generate(4, (i)=> i);
    // Expansion tile indexes for the group/teams perspective
    var groupIndexes = List.generate(5, (i)=> i+4);

    if (testingDebug) pu.printd("Testing Debug: Expansion tile indexes for the individual perspective: $indivIndexes");
    if (testingDebug) pu.printd("Testing Debug: Expansion tile indexes for the group/teams perspective: $groupIndexes");
    
    // To have the index of the data for each perspective
    // Reset for the group/teams perspective
    int previewListTileDataIndex = -1;

    // Accessing the expansion tiles by index
    for (int expansionTileIndex = 0; expansionTileIndex < totalExpansionTiles; expansionTileIndex++) 
    {  
      // Searching the expansion tile by index
      var currentExpansionTileFinder = find.descendant(
        of: find.byType(CAPreview),
        matching: find.byType(ExpansionTile),
      ).at(expansionTileIndex);

      // Getting the expansion tile title
      ExpansionTile expansionTileWidget = tester.widget<ExpansionTile>(currentExpansionTileFinder);
      Text expansionTileTitleWidget = expansionTileWidget.title as Text;
      String expansionTileTitle = expansionTileTitleWidget.data!;
      if (testingDebug) pu.printd("Testing Debug: \n Expansion tile title: $expansionTileTitle");
      
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
        if (testingDebug) pu.printd("Testing Debug: List tiles title for: $expansionTileTitle: $listTileTitle");
        if (testingDebug) pu.printd("Testing Debug: expansionTileIndex: $expansionTileIndex, listTileIndex: $listTileIndex");

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
            if (testingDebug) pu.printd("Testing Debug: List tiles subtitle for $expansionTileTitle: $listTileSubTitle");
            
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

// ─── GPS ──────────────────────────────────────────────────────────────
// ──────────────────────────────────────────────────────────────────────────────

// ─── GPS PROCESS FILING ───────────────────────────────────────────────────────────────
  // Method used to check that the new GPS process button functions
  Future<void> gpsCheckNewProcessButtonFunctions(WidgetTester tester) async
  {
    // Verifying the NewProcessButton present
    expect(
      find.byType(NewProcessButton),
      findsOneWidget,
      reason: "NewProcessButton should be visible when GPS session data is already saved.",
    );

    // Tapping NewProcessButton
    await tester.tap(find.byType(NewProcessButton));
    await tester.pumpAndSettle();

    // Verifying GPSProcess displayed
    expect(
      find.byType(GPSProcess),
      findsOneWidget,
      reason: "GPSProcess should be visible after tapping NewProcessButton.",
    );
  }

  // Method used to test the color of an identifier
  Future<void> gpsTestIdentifierColor(WidgetTester tester, Color color) async
  {
    // Searching the container
    var containerFinder = find.descendant
    (
      of: find.byType(IdentifierWidget), 
      matching: find.byType(Container)
    );

    var totalContainers = containerFinder.evaluate().length;
    if (testingDebug) pu.printd("Testing Debug: totalContainers: $totalContainers");

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

  // Method used to test the color of the checklist title border
  Future<void> gpsTestChecklistTitleBorderColor(WidgetTester tester, Color color) async
  {
    // Searching the container
    var containerFinder = find.descendant
    (
      of: find.byType(GPSChecklist), 
      matching: find.byType(Container)
    );

    var totalContainers = containerFinder.evaluate().length;
    if (testingDebug) pu.printd("Testing Debug: totalContainers: $totalContainers");

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

  // Method used to enter a title in the GPS process
  Future<void> gpsEnterProcessTitle (WidgetTester tester, String aTitle) async
  {
    // Searching the placeholder title
    var placeholderTitleFinder = find.text(gpsProcessTitlePlaceholder);

    // Tapping on it
    await tester.tap(placeholderTitleFinder);
    await tester.pumpAndSettle();

    // Searching the text field
    var textFieldFinder = find.ancestor
    (
      of: find.text(gpsProcessTitleTextFieldHint), 
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
  Future<void> gpsEnterProcessKeywords (WidgetTester tester, List<String> keywordsList) async
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
      await tester.pumpAndSettle();
      // await tester.pump(const Duration(seconds: 2)); 

      // Necessary for the next keyword to be added
      await tester.tap(textfieldFinder);         
    }

    // Searching the tooltip to close the overlay
    var closingIconFinder = find.byTooltip(closeGPSKeywordsDeclarationTooltipLabel);

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
  Future<void> gpsEnterIdeas
  (
    WidgetTester tester,
    List<String> ideasList
  ) async
  {
    // Searching the text field used to add ideas
    var newIdeaTextFieldFinder = find.ancestor
    (
      of: find.text(newIdeaTextFieldHint), 
      matching: find.byType(TextField)
    );

    // Adding the ideas
    for (var idea in ideasList)
    {
      await tester.enterText(newIdeaTextFieldFinder, idea);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // pumpAndSettle timed out
      // await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));  

      await tester.tap(newIdeaTextFieldFinder); 
    }
      
  }

  // Method used to enter new GPS process data
  Future<void> gpsEnterNewProcessDataOnMobile 
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
    await gpsCheckNewProcessButtonFunctions(tester);


    // ── 2. GPS PROCESS FILLING ──────────────────────────────────────────────────────────
    // ───────────────────────────────────────────────────────────────────────────────────

    // ── TITLE SECTION ─────────────────────────────────────────────────────────────
    await gpsEnterProcessTitle(tester, title);

    // ── KEYWORDS SECTION ─────────────────────────────────────────────────────────────
    await gpsEnterProcessKeywords(tester, kwsList);
    
    // ── SOLUTIONS SECTION ─────────────────────────────────────────────────────────────
    await gpsEnterIdeas(tester, ideasList);
    
    // ── DATA SUBMISSION SECTION ─────────────────────────────────────────────────────────────        
    // Entering the file name and submitting data
    await dashboardEnterFileNameAndSubmitDataOnMobile(tester: tester, fileNameWithoutExtension: fileNameWithoutExtension);
  }

  // Method used to add several times group problem-solving data
  // The method assumes all lists have the same number of elements
  Future<void> gpsEnterSeveralTimesNewProcessData
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
      await gpsEnterNewProcessDataOnMobile 
      (
        tester: tester, 
        title: titlesList[index],
        kwsList: kwsLists[index], 
        ideasList: ideasList[index],
        fileNameWithoutExtension: fileNamesWithoutExtensionList[index]
      );
    }
  }

// ─── GPS PREVIEW ───────────────────────────────────────────────────────────────
  // Method used to test a GPS preview.
  Future<void> gpsTestPreview
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
      var titleFinder = find.textContaining(title);
        // Verifying the title present
      expect (titleFinder, findsNWidgets(2));

      // Searching for the date
      dateForTestingIndex = 0;
      expect(find.textContaining(datesForTestingList[0]), findsNWidgets(2));
        
      // Verifying the ideas present
      for (var idea in ideasList)
      {
        expect(find.text(idea), findsOne);
      }
    }

// ─── GPS: GOING FROM PAGE TO PAGE/OVERLAY ───────────────────────────────────────────────────────────────

  // Method used to go from the home page to the GPS process page
  Future<void> gpsFromHomePageToProcessPage(WidgetTester tester) async
  {
    
    // ── CLICKING TO DISPLAY THE GPS PAGE  ──────────────────────────────────────
    // ────────────────────────────────────────────────────────────────────────────
    var bottomItemGPSFinder = find.byKey(const Key("homepage-bottom-navigation-bar-item-gps"));
    await tester.tap(bottomItemGPSFinder);
    await tester.pumpAndSettle();

    // Verifying the GPS page present
    expect(find.byType(GPSPage), findsOne);

    // ── STARTING A NEW GPS PROCESS ────────────────────────────────────
    // ───────────────────────────────────────────────────────────────────────────

    // Clicking on the GPS new process button
    await gpsCheckNewProcessButtonFunctions(tester);

    // Searching the placeholder title
    var placeholderTitleFinder = find.text(gpsProcessTitlePlaceholder);
    expect(placeholderTitleFinder, findsOne);
  }

  // Method used to go from the GPS page to the GPS process page
  Future<void> gpsFromGPSPageToProcessPage(WidgetTester tester) async
  {
    // Clicking on the GPS new process button
    await gpsCheckNewProcessButtonFunctions(tester);

    // Searching the placeholder title
    var placeholderTitleFinder = find.text(gpsProcessTitlePlaceholder);
    expect(placeholderTitleFinder, findsOne);
  }

  // Method used to go from the GPS process page to the participants lists options page
  Future<void> gpsFromProcessPageToparticipantsListsOptionsPage(WidgetTester tester) async
  {
    // Searching the add emoji    
    var addEmojiFinder = find.text(addEmoji);

    // Verifying the add emoji present
    expect(addEmojiFinder, findsOne);

    // Tapping to reach the page with the loading/new group options
    await tester.tap(addEmojiFinder);
    // pumpAndSettle timed out
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
  }

  // Method used to go from the GPS process page to new list page
  Future<void> gpsFromProcessPageToNewParticipantsListPage(WidgetTester tester) async
  {
    // Searching the add emoji    
    var addEmojiFinder = find.text(addEmoji);

    // Verifying the add emoji present
    expect(addEmojiFinder, findsOne);

    // Tapping to reach the page with the loading/new group options
    await tester.tap(addEmojiFinder);

    // pumpAndSettle timed out
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    // Verifying the options page present
    var optionsPageFinder = find.text(participantsListsSubTitle);
    expect(optionsPageFinder, findsOne);

    // Searching the new group button
    var newParticipantsGroupFinder = find.text(newParticipantsGroupOptionLabel);
    await tester.ensureVisible(newParticipantsGroupFinder);
    expect(newParticipantsGroupFinder, findsOne);

    // Tapping on it
    await tester.tap(newParticipantsGroupFinder);
    await tester.pumpAndSettle();
    // await tester.pump(const Duration(seconds: 2));
  }

  // Method used to go from GPS process page to list loading dashboard
  Future<void> gpsFromProcessPageToListLoadingDashboard(WidgetTester tester) async
  {
    // Searching the add emoji    
    var addEmojiFinder = find.text(addEmoji);

    // Verifying the add emoji present
    expect(addEmojiFinder, findsOne);

    // Tapping to reach the page with the loading/new group options
    await tester.tap(addEmojiFinder);
    // pumpAndSettle timed out
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    // Verifying the options page present
    var optionsPageFinder = find.text(participantsListsSubTitle);
    expect(optionsPageFinder, findsOne);

    // Searching the list loading option button
    var loadingAListOptionFinder = find.text(loadingAListOptionLabel);
    await tester.ensureVisible(loadingAListOptionFinder);
    expect(loadingAListOptionFinder, findsOne);

    // Tapping on it
    await tester.tap(loadingAListOptionFinder);
    await tester.pumpAndSettle();

    // Verifying the lists dashboard title present
    var ParticipantsDashboardTitleFinder = find.text(listsDashboardTitle);
    expect(ParticipantsDashboardTitleFinder, findsOne);
  }

  // Method used to go from the GPS process page to the ideas overlay
  Future<void> gpsFromProcessPageToIdeasOverlay(WidgetTester tester) async
  {
    // ── CLICKING ON THE IDEAS LIST TITLE  ───────────────────────────────────
    // ────────────────────────────────────────────────────────────────────────
    var ideasListTitleFinder = find.text(ideasListTitle);
    await tester.tap(ideasListTitleFinder);
    await tester.pumpAndSettle();

    // ── OVERLAY  ───────────────────────────────────
    // ───────────────────────────────────────────────
    // Verifying the overlay present
    expect(find.byKey(const Key("ideaOverlayField")), findsOne);
  }


// ─── GPS: ADDING PARTICIPANTS ───────────────────────────────────────────────────────────────
  // Method used to add participants
  Future<void> gpsFromProcessPageAddParticipantsAndKeywords
  (
    WidgetTester tester, List<String> participantsNames, List<dynamic> keywords
  ) async
  { 
    // Loading the new list page from the GPS process page
    await gpsFromProcessPageToNewParticipantsListPage(tester);

    if (keywords.isNotEmpty)
    {
      // Searching for the keywords declaration title
      var keywordsTitleFinder = find.text(keywordsDeclarationTitle);
      await tester.tap(keywordsTitleFinder);
      await tester.pumpAndSettle();

      // Searching for the new keyword text field
      var newKeywordTextFieldFinder = find.byKey(const Key("kwsFieldNewList"));
      await tester.ensureVisible(newKeywordTextFieldFinder); 
      expect(newKeywordTextFieldFinder, findsOne);
      await tester.pumpAndSettle(); 
      await tester.tap(newKeywordTextFieldFinder);
      await tester.pumpAndSettle();  

      // Adding the keywords
      for (var keyword in keywords)
      {   
        // Adding the keyword
        await tester.enterText(newKeywordTextFieldFinder, keyword);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        // Necessary for the next keyword to be added
        await tester.tap(newKeywordTextFieldFinder);
        await tester.pumpAndSettle();
      }

      // Closing the overlay
      var closeKeywordsDeclarationTooltipLabelFinder = find.byTooltip(closeGPSKeywordsDeclarationTooltipLabel);
      await tester.tap(closeKeywordsDeclarationTooltipLabelFinder);
      await tester.pumpAndSettle();
    }
    
    // Searching for the new participant text field
    // Searching by placeholder text is not robust enough
    var newParticipantTextFieldFinder = find.byKey(const Key("participantNameField"));
    expect(newParticipantTextFieldFinder, findsOne);
    await tester.ensureVisible(newParticipantTextFieldFinder); 
    await tester.pumpAndSettle(); 
    await tester.tap(newParticipantTextFieldFinder);
    await tester.pumpAndSettle();

    // Adding the names
    for (var name in participantsNames)
    {   
      // Adding the name
      await tester.enterText(newParticipantTextFieldFinder, name);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      // Necessary for the next name to be added
      await tester.tap(newParticipantTextFieldFinder);
    }
  }

  // Method used to add participants lists
  // [
  //   {listName1:{"names":[name1,name2],"keywords":[kw1, kw2]}},
  //   {listName2:{"names":[name3,name4],"keywords":[kw3, kw4]}}
  // ];
  Future<void> gpsFromProcessPageAddParticipantsListsAndVerifyListLoaded
  ({
    required WidgetTester tester, 
    required List< Map<String,Map<String, dynamic>> > listDataMapsList
  }) async
  {
    for (var map in listDataMapsList)
    {
      List<String> names = (map.values.first)["names"];
      List<dynamic> keywords = (map.values.first)["keywords"];

      await gpsFromProcessPageAddParticipantsAndKeywords(tester, names, keywords);

      // Verifying the names present
      for (var name in names)
      {
        expect(find.text(name), findsOne);    
      }      

      // Searching the "Save" icon
      var saveListIconFinder = find.byIcon(Icons.save_outlined);
      // await tester.pump(const Duration(seconds: 3));
      expect(saveListIconFinder, findsOne);

      // Tapping on it
      await tester.tap(saveListIconFinder);
      await tester.pumpAndSettle();

      // Searching the text field to add the list name
      var listNameSavingTextFieldFinder = find.byKey(const Key("saveListField"));
      expect(listNameSavingTextFieldFinder, findsOne);

      // Adding the list name
      var listName = map.keys.first;
      await tester.ensureVisible(listNameSavingTextFieldFinder);
      await tester.tap(listNameSavingTextFieldFinder);
      await tester.enterText(listNameSavingTextFieldFinder, listName);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Waiting on the "list saved" snackbar
      await tester.pump(const Duration(seconds: 3));

      // Verifying the names on the GPS process page

      // Verifying the GPS process page present
      expect(find.text(checkListTitle), findsOne);

      // Verifying the names present
      for (var name in names)
      {
        expect(find.text(name), findsOne);    
      } 
    }
  }

// ─── GPS: ADDING IDEAS ───────────────────────────────────────────────────────────────
  // Method used to add an idea using the overlay
  Future<void> gpsFromOverlayAddIdea(WidgetTester tester, String idea) async
  {
    // Searching the text field used to add ideas
    var newIdeaTextFieldFinder = find.byKey(const Key("ideaOverlayField"));
    // Adding the idea
    await tester.ensureVisible(newIdeaTextFieldFinder);
    await tester.tap(newIdeaTextFieldFinder);
    await tester.pumpAndSettle(); 
    await tester.enterText(newIdeaTextFieldFinder, idea);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    // pumpAndSettle timed out
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));  
  }

// ─── GPS: MISC. ───────────────────────────────────────────────────────────────
  // Method used to get the finder of a new list text items
  Future<Finder> gpsGetNewListTextItems(WidgetTester tester) async
  {
    var listItemsFinder = find.byWidgetPredicate
              (
                (widget) 
                {
                  if (widget.key is ValueKey<String>) {
                    return (widget.key as ValueKey<String>).value.contains("editable-deletable-text-item-");
                  }
                  return false;
                }
              );  
    return listItemsFinder;
  }

  // Method used to get the finder of the participants containers
  Future<Finder> gpsGetParticipantsContainersOnListDashboard(WidgetTester tester) async
  {
    var participantsContainersFinder = find.byWidgetPredicate
    (
      (widget) 
      {
        if (widget.key is ValueKey<String>) {
          return (widget.key as ValueKey<String>).value.contains("session-participants-container-");
        }
        return false;
      }
    );  

    return participantsContainersFinder;
  } 

  

// ─── DASHBOARD TESTING ───────────────────────────────────────────────────────────────

  // Method used to enter edit mode
  Future<void> dashboardEnterEditMode(WidgetTester tester) async
  {
    // Searching the edit button
    var editButtonFinder = find.descendant
                          (
                            of: find.byType(ElevatedButton),
                            matching: find.text(editEmoji)
                          );
    
    var totalButton = editButtonFinder.evaluate().length;
    if (testingDebug) pu.printd("Testing Debug: totalButton: $totalButton");

    // Tapping the edit button
    await tester.tap(editButtonFinder);
    // pumpAndSettle timed out
    // await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
  }

  // Method used to enter a file name and to submit the CA process data on mobile device
  // (Assuming an already selected path to the user session data folder)
  Future<void> dashboardEnterFileNameAndSubmitDataOnMobile({required WidgetTester tester, required String fileNameWithoutExtension}) async
  {
    Finder fileNameWidgetFinder =  find.byType(SessionFileNameOnMobilePlatforms);

    // Path to folder already declared 
    // Scrolling to make the text field visible for small screens
    await tester.ensureVisible(fileNameWidgetFinder);
    await tester.pumpAndSettle();

    // Entering a file name
    await tester.enterText(fileNameWidgetFinder, fileNameWithoutExtension);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();  
  }  


  // Method used to search a title and keywords on the dashboard
  Future<void> dashboardSearchTitleAndKeywords({required String title, required List<String> kws, String? titleSuffix}) async
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

  // Method used to get the finder of the keywords
  Future<Finder> dashboardGetKeywordsOnDashboard(WidgetTester tester) async
  {
    var participantsContainersFinder = find.byWidgetPredicate
    (
      (widget) 
      {
        if (widget.key is ValueKey<String>) {
          return (widget.key as ValueKey<String>).value.contains("session-keywords-");
        }
        return false;
      }
    );  

    return participantsContainersFinder;
  } 

  // Method used to get the finder of a sessions list item by title
  Future<Finder> dashboardGetSessionListItemFinderByTitle({required WidgetTester tester, required String title, String? titleSuffix}) async 
  {
    if (titleSuffix != null) title = "$title$titleSuffix";
    Finder sessionListItemFinder = find.text(title);
    return sessionListItemFinder;
  }

  // Method used to get the finder of the sessions titles
  Future<Finder> dashboardGetAllSessionsTitles(WidgetTester tester) async
  {
    var titlesFinder = find.byWidgetPredicate
    (
      (widget) 
      {
        if (widget.key is ValueKey<String>) {
          return (widget.key as ValueKey<String>).value.contains("session-title-");
        }
        return false;
      }
    );  

    return titlesFinder;
  }

  // Method used to get the finder of a keyword FilterChip
  Future<Finder> dashboardGetKwFilterChip(WidgetTester tester, String kw) async
    {
      var filterChipFinder = find.byWidgetPredicate
      (
        (widget) 
        {
          if (widget is FilterChip) {
            final label = widget.label;
            if (label is Text) {
              return (label.data ?? "").contains(kw);
            }
          }
          return false;
        }      
      );  

      return filterChipFinder;
    }
  

// ─── MISC. ───────────────────────────────────────────────────────────────

  // Serialises a segmented-button selection to a slash-separated string.
  String _segmentedButtonToString(Set<String> values) => values.join("/");

  /// Method used to scroll up the screen (-200 as default delta value to go up the list).
  /// The method assumes that the first descendant is the right one.
  Future<int> scrollListUpScrollableByFirstDescendant({required WidgetTester tester, required Finder listFinder, required elementToReachFinder , double delta = -200}) async
  {
  if (testingDebug) pu.printd("Testing Debug: scrollListUpScreen");

  var scrollablesFinder = find.descendant
  (
    of: listFinder,
    matching: find.byType(Scrollable),
  );

  if (testingDebug) pu.printd("Testing Debug: Scrollable count: ${scrollablesFinder.evaluate().length}");

  await tester.scrollUntilVisible
  (
    elementToReachFinder, 
    -200 , // getting back up the list
    scrollable: scrollablesFinder.first
  );
  return await tester.pumpAndSettle(); 
}

   