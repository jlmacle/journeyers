// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";


void main() 
{
  Future<void> pumpGPSProcess(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPSProcess
          (
            dtoGPSFormWhenEdition: null,
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
            sessionTitleTfec: TextEditingController(),
          ),
        ),
      ),
    );
  }

  group("GPSProcess Tests: \n", 
  () 
  {  
    group("Participants Tests: \n", 
    () 
    {      
      // "Participants can be added" (failing as a widget test)
      // testWidgets("Participants can be added", 
      // (WidgetTester tester) async 
      // {
      //   var name1 = "Bob";
      //   var name2 = "Alice";
      //   List<String> names = [name1, name2];
      //   var list1 = "list1";

      //   // Pumping the widget
      //   await pumpGPSProcess(tester);
      //   // pumpAndSettle timed out
      //   // await tester.pumpAndSettle();
      //   await tester.pump(const Duration(seconds: 10));

      //   // Adding the participants
      //   List< Map<String,List<String>> > listNamesParticipantsNamesMapList =
      //   [
      //     {list1:names},
      //   ];
      //   await addParticipantsListsFromGPSprocessPage(tester: tester, listNamesParticipantsNamesMapList: listNamesParticipantsNamesMapList);
      // });    
    });
            
    
      // "Stakeholder identifiers can be edited"
      // to be updated
      

      // "Stakeholder identifiers can be deleted: single deletion"
      // to be updated
      
      // "Stakeholder identifiers can be deleted: bulk deletion"
      // to be updated

      // "Stakeholder identifiers' colors can be changed from green, to orange, to red, to green by tapping"
      // to be updated
  });

  group("Session Title Tests: \n", 
  () 
  {  
    // "A title can be added by clicking on the placeholder title"
    testWidgets("A title can be added by clicking on the placeholder title", 
    (WidgetTester tester) async 
    {
      var aTitle = "aTitle";

      // Pumping the widget
      await pumpGPSProblemToSolveDeclaration(tester);

      // Searching the placeholder title
      var placeholderTitleFinder = find.text(gpsProcessTitlePlaceholder);

      // Tapping
      await tester.tap(placeholderTitleFinder);
      await tester.pumpAndSettle();

      // Searching the text field
      var textFieldFinder = find.ancestor
      (
        of: find.text(gpsProcessTitleTextFieldHint), 
        matching: find.byType(TextField)
      );

      // Entering a title
      await tester.enterText(textFieldFinder, aTitle);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verifying the placeholder title absent
      expect(find.text(gpsProcessTitlePlaceholder), findsNothing);

      // Verifying the title present
      expect(find.text(aTitle), findsOne);
    }
    );
  
    // "A title can be added by clicking on the edit emoji"
    testWidgets("A title can be added by clicking on the edit emoji", 
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
        of: find.text(gpsProcessTitleTextFieldHint), 
        matching: find.byType(TextField)
      );

      // Entering a title
      await tester.enterText(textFieldFinder, aTitle);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verifying the placeholder title absent
      expect(find.text(gpsProcessTitlePlaceholder), findsNothing);

      // Verifying the title present
      expect(find.text(aTitle), findsOne);
    }
    );
  
  
  });

  // todo: to understand why not passing anymore
  group("Checklist Tests: \n", 
  () 
  {  
    // // "The checklist turns to green when checked, and the rectangle goes from orange to transparent"
    // testWidgets("The checklist turns to green when checked, and the rectangle goes from orange to transparent", 
    // (WidgetTester tester) async 
    // {
    //   // Pumping the widget
    //   await pumpGPSChecklist(tester);

    //   // Verifying the default rectangle color is orange
    //   await testChecklistTitleBorderColor(tester, rectangleColor);

    //   // Searching the checklist
    //   var checklistFinder = find.byType(GPSChecklist);

    //   // Tapping the checklist
    //   await tester.tap(checklistFinder);
    //   await tester.pumpAndSettle();

    //   // Searching the checkbox list tiles in the checklist
    //   var checkboxListTilesFinder = find.descendant
    //   (
    //     of: find.byType(ListView), 
    //     matching: find.byType(CheckboxListTile)
    //   );

    //   var totalCheckboxListTilesFinder = checkboxListTilesFinder.evaluate().length;
    //   if (testingDebug) pu.printd("Testing Debug: totalCheckboxListTilesFinder: $totalCheckboxListTilesFinder");

    //   // Verifying their color after tapping them 
    //   for (var index = 0; index < totalCheckboxListTilesFinder; index++)
    //   {
    //     Finder checkboxListTileFinder = checkboxListTilesFinder.at(index);
    //     await tester.ensureVisible(checkboxListTileFinder);
    //     await tester.tap(checkboxListTileFinder);
    //     await tester.pumpAndSettle();

    //     CheckboxListTile checklistItemWidget = tester.widget<CheckboxListTile>(checkboxListTileFinder);
    //     Color activeColor = checklistItemWidget.activeColor!;

    //     expect (activeColor, checklistItemCheckedColor);        
    //   }

    //   // Searching to close the overlay
    //   var closeChecklistFinder = find.byTooltip(closeChecklistTooltipLabel);
    //   await tester.tap(closeChecklistFinder);
    //   await tester.pump(const Duration(seconds: 15));
    //   await tester.pumpAndSettle();
      
    //   // Verifying the rectangle color is transparent
    //   await testChecklistTitleBorderColor(tester, Colors.transparent);
    // });
  });

  group("List of Keywords Tests: \n", 
  () 
  { 
    // "A keyword can be added"
    testWidgets("A keyword can be added", 
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
      await tester.pump(const Duration(seconds: 2)); 

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
      await tester.pump(const Duration(seconds: 2)); 

      // Verifying the keyword present
      expect(find.text(aKw), findsOne);

      // Searching the tooltip to close the overlay
      var closingIcon = find.byTooltip(closeGPSKeywordsDeclarationTooltipLabel);

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


  group("List of Ideas Tests: \n", 
  () 
  { 
    // "50 ideas added are found in the list of ideas"
    testWidgets("50 ideas added are found in the list of ideas", 
    (WidgetTester tester) async 
    {
      var someText = "someText";

      // Pumping the widget
      await pumpGPSProcess(tester);

      // Searching the text field used to add ideas
      var newIdeaTextFieldFinder = find.ancestor
      (
        of: find.text(newIdeaTextFieldHint), 
        matching: find.byType(TextField)
      );

      for (var i = 0; i < 50; i++)
      {
        // Adding some text
        await tester.enterText(newIdeaTextFieldFinder,"$someText$i");
        await tester.testTextInput.receiveAction(TextInputAction.done);
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));        

        // Verifying the text present
        var textFinder = find.descendant
        (
          of: find.byType(GPSIdeasList), 
          matching: find.text("$someText$i")
        );
        expect(textFinder.evaluate().length, 1);
      }

      // Verifying the placeholder text absent
      expect(find.text(ideasListPlaceholder), findsNothing);
    });

  });

}