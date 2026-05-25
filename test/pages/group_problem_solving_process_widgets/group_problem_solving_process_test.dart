// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/2_group_problem_solving_group_moods.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_solutions_list.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

import '../../helper_functions/externalized_testing_code.dart';

void main() 
{
  Future<void> pumpGPSProcess(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPSProcess
          (
            parentCallbackFunctionToRefreshTheGPSPage: () {},
          ),
        ),
      ),
    );
  }

  Future<void> pumpGPSChecklist(WidgetTester tester) async
  {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GPSChecklist(),
        ),
      ),
    );
  }

  Future<void> pumpGPSProblemToSolveDeclaration(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPSProblemToSolveDeclaration
          (
            onSessionSelected:(_) {},
            previousSessions: const [],
            problemTitleController: TextEditingController(),
          ),
        ),
      ),
    );
  }

  group('GPSProcess Tests: \n', 
  () 
  {  
    group("Stakeholder identifiers: \n", 
    () 
    {      
      // 'Stakeholder identifiers can be added'
      testWidgets('Stakeholder identifiers can be added', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSProcess(tester);

        // Finding the add emoji    
        var emojiFinder = find.text(addEmoji);

        // Adding identifiers
        for (var i = 1; i <= 3; i++)
        {
          // Tapping to add
          await tester.tap(emojiFinder);
          // pumpAndSettle timed out
          // await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));
          // Verifying present
          expect(find.byType(IdentifierWidget), findsNWidgets(i));
        }

      });          
    
      // 'Stakeholder identifiers can be edited'
      testWidgets('Stakeholder identifiers can be edited', 
      (WidgetTester tester) async 
      {
        var someText = "someText";

        // Pumping the widget
        await pumpGPSProcess(tester);

        // Adding an identifier
        var identifierWidgetFinder = await addIdentifier(tester);

        // Entering edit mode
        await enterEditMode(tester);
        
        // Tapping the identifier for edition
        await tester.tap(identifierWidgetFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));

        // Searching the text field
        var textFieldFinder = find.descendant
        (
          of: find.byType(AlertDialog), 
          matching: find.byType(TextField)
        );

        var totalTextField = textFieldFinder.evaluate().length;
        if (testingDebug) pu.printd('Testing Debug: totalTextField: $totalTextField');

        //Entering some text
        await tester.enterText(textFieldFinder, someText);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));

        // Verifying the alert dialog absent
        expect(find.byType(AlertDialog), findsNothing);

        // Verifying the text present in the identifier
        expect
        (
          find.descendant
          (
            of: find.byType(IdentifierWidget), 
            matching: find.text(someText)
          ),
          findsOne
        );
      });    
    });

      // 'Stakeholder identifiers can be deleted: single deletion'
      testWidgets('Stakeholder identifiers can be deleted: single deletion', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSProcess(tester);

        //  Adding an identifier
        var identifierWidgetFinder = await addIdentifier(tester);     

        // Entering edit mode
        await enterEditMode(tester);

        // Searching single deletion mode
        var singleDeletionFinder = find.descendant
                        (
                          of: find.byType(ElevatedButton),
                          matching: find.text(singleDeletionLabel)
                        );
        // Tapping single deletion mode
        await tester.tap(singleDeletionFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));

        // Searching the delete icon on the identifier
        var deleteFinder = find.descendant
        (
          of: identifierWidgetFinder, 
          matching: find.byType(Icon)
        );

        // Tapping the delete icon
        await tester.tap(deleteFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));

        // Verifying the identifier absent
        expect
        (
          find.byType(IdentifierWidget), findsNothing
        );

      });          
   
      // 'Stakeholder identifiers can be deleted: bulk deletion'
      testWidgets('Stakeholder identifiers can be deleted: bulk deletion', 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSProcess(tester);

        //  Adding two identifiers
        await addIdentifier(tester); 
        await addIdentifier(tester);     

        // Entering edit mode
        await enterEditMode(tester);

        // Searching bulk deletion mode
        var bulkDeletionFinder = find.descendant
                        (
                          of: find.byType(ElevatedButton),
                          matching: find.text(bulkDeletionLabel)
                        );
        // Tapping bulk deletion mode
        await tester.tap(bulkDeletionFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));   

        // Verifying the identifiers absent
        expect
        (
          find.byType(IdentifierWidget), findsNothing
        );

      });          
   
      // "Stakeholder identifiers' colors can be changed from green, to orange, to red, to green by tapping"
      testWidgets("Stakeholder identifiers' colors can be changed from green, to orange, to red, to green by tapping", 
      (WidgetTester tester) async 
      {
        // Pumping the widget
        await pumpGPSProcess(tester);

        //  Adding an identifier
        var identifierFinder = await addIdentifier(tester); 
   
        // Tapping the identifier
        await tester.tap(identifierFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2)); 

        // Verifying the color
        await testIdentifierColor(tester, orange);

        // Tapping the identifier
        await tester.tap(identifierFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2)); 

        // Verifying the color
        await testIdentifierColor(tester, red);

        // Tapping the identifier
        await tester.tap(identifierFinder);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2)); 

        // Verifying the color
        await testIdentifierColor(tester, greenShade900);
      });         
   
  });

  group('Session Title Tests: \n', 
  () 
  {  
    // 'A title can be added by clicking on the placeholder title'
    testWidgets('A title can be added by clicking on the placeholder title', 
    (WidgetTester tester) async 
    {
      var aTitle = "aTitle";

      // Pumping the widget
      await pumpGPSProblemToSolveDeclaration(tester);

      // Searching the placeholder title
      var placeholderTitleFinder = find.text(gpsTitlePlaceholder);

      // Tapping
      await tester.tap(placeholderTitleFinder);
      await tester.pumpAndSettle();

      // Searching the text field
      var textFieldFinder = find.ancestor
      (
        of: find.text(gpsTitleTextFieldHint), 
        matching: find.byType(TextField)
      );

      // Entering a title
      await tester.enterText(textFieldFinder, aTitle);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verifying the placeholder title absent
      expect(find.text(gpsTitlePlaceholder), findsNothing);

      // Verifying the title present
      expect(find.text(aTitle), findsOne);
    }
    );
  
    // 'A title can be added by clicking on the edit emoji'
    testWidgets('A title can be added by clicking on the edit emoji', 
    (WidgetTester tester) async 
    {
      var aTitle = "aTitle";

      // Pumping the widget
      await pumpGPSProblemToSolveDeclaration(tester);

      // Searching the edit emoji
      var editEmojiFinder = find.descendant
      (
        of: find.byType(GPSProblemToSolveDeclaration),
        matching: find.text(editEmoji)
      );

      // Tapping
      await tester.tap(editEmojiFinder);
      await tester.pumpAndSettle();

      // Searching the text field
      var textFieldFinder = find.ancestor
      (
        of: find.text(gpsTitleTextFieldHint), 
        matching: find.byType(TextField)
      );

      // Entering a title
      await tester.enterText(textFieldFinder, aTitle);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verifying the placeholder title absent
      expect(find.text(gpsTitlePlaceholder), findsNothing);

      // Verifying the title present
      expect(find.text(aTitle), findsOne);
    }
    );
  
  
  });

  group('Checklist Tests: \n', 
  () 
  {  
    // 'The checklist turns to green when checked, and the rectangle goes from orange to transparent'
    testWidgets('The checklist turns to green when checked, and the rectangle goes from orange to transparent', 
    (WidgetTester tester) async 
    {
      // Pumping the widget
      await pumpGPSChecklist(tester);

      // Verifying the default rectangle color is orange
      await testChecklistTitleBorderColor(tester, rectangleColor);

      // Finding the checklist
      var checklistFinder = find.byType(GPSChecklist);

      // Tapping the checklist
      await tester.tap(checklistFinder);
      await tester.pumpAndSettle();

      // Searching the checkbox list tiles in the checklist
      var checkboxListTilesFinder = find.descendant
      (
        of: find.byType(ListView), 
        matching: find.byType(CheckboxListTile)
      );

      var totalCheckboxListTilesFinder = checkboxListTilesFinder.evaluate().length;
      if (testingDebug) pu.printd('Testing Debug: totalCheckboxListTilesFinder: $totalCheckboxListTilesFinder');

      // Verifying their color after tapping them 
      for (var index = 0; index < totalCheckboxListTilesFinder; index++)
      {
        Finder checkboxListTileFinder = checkboxListTilesFinder.at(index);
        await tester.ensureVisible(checkboxListTileFinder);
        await tester.tap(checkboxListTileFinder);
        await tester.pumpAndSettle();

        CheckboxListTile checklistItemWidget = tester.widget<CheckboxListTile>(checkboxListTileFinder);
        Color activeColor = checklistItemWidget.activeColor!;

        expect (activeColor, checklistItemCheckedColor);        
      }

      // Searching to close the overlay
      var closeChecklistFinder = find.byTooltip(closeChecklistTooltipLabel);
      await tester.tap(closeChecklistFinder);
      await tester.pumpAndSettle();

      // Verifying the rectangle color is transparent
      await testChecklistTitleBorderColor(tester, Colors.transparent);
    });
  });

  group('List of Keywords Tests: \n', 
  () 
  { 
    // 'A keyword can be added'
    testWidgets('A keyword can be added', 
    (WidgetTester tester) async 
    {
      var aKw = "kw";

      // Pumping the widget
      await pumpGPSProcess(tester);

      // Searching the keywords declaration title
      var keywordsDeclarationTitleFinder = find.descendant
                                    (
                                      of: find.byType(GPSKeywordsDeclaration), 
                                      matching: find.text(keywordsDeclarationTitle)
                                    );

      // Tapping on it
      await tester.tap(keywordsDeclarationTitleFinder);
      // pumpAndSettle timed out
      // await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1)); 

      // Verifying the keyword absent
      expect(find.text(aKw), findsNothing);

      // Searching the text field
      var textfieldFinder = find.descendant
                            (
                              of: find.byType(StatefulBuilder), 
                              matching: find.byType(TextField)
                            );
      
      // Entering the keyword
      await tester.enterText(textfieldFinder, aKw);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // pumpAndSettle timed out
      // await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1)); 

      // Verifying the keyword present
      expect(find.text(aKw), findsOne);

      // Searching the tooltip to close the overlay
      var closingIcon = find.byTooltip(closeKeywordsDeclarationTooltipLabel);

      // Closing the overlay
      await tester.tap(closingIcon);
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

      // Verifying the GPS process present
      expect(find.byType(GPSProcess), findsOne);

    });
  }
  );


  group('List of Solutions Tests: \n', 
  () 
  { 
    // '50 solutions added are found in the list of solutions'
    testWidgets('50 solutions added are found in the list of solutions', 
    (WidgetTester tester) async 
    {
      var someText = "someText";

      // Pumping the widget
      await pumpGPSProcess(tester);

      // Searching the text field used to add solutions
      var newSolutionTextFieldFinder = find.ancestor
      (
        of: find.text(newSolutionTextFieldHint), 
        matching: find.byType(TextField)
      );

      for (var i = 0; i < 50; i++)
      {
        // Adding some text
        await tester.enterText(newSolutionTextFieldFinder,"$someText$i");
        await tester.testTextInput.receiveAction(TextInputAction.done);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));        

        // Verifying the text present
        var textFinder = find.descendant
        (
          of: find.byType(GPSSolutionsList), 
          matching: find.text("$someText$i")
        );
        expect(textFinder.evaluate().length, 1);
      }

      // Verifying the placeholder text absent
      expect(find.text(solutionsListPlaceholder), findsNothing);
    });

  });

}