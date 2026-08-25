// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/dev/test_utils.dart";


void main() 
{
  
  Future<void> pumpGPSProcess(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(testingLocaleOption),
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

  Future<void> pumpGPSProblemToSolveDeclaration(WidgetTester tester) async
  {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(testingLocaleOption),
        home: Scaffold(
          body: GPSProblemToSolveDeclaration
          (
            onSessionSelected:(_) {},
            caPreviousSessions: const [],
            onTitleModified: () {},
            sessionTitleTec: TextEditingController(),
            onTitleTapped: () {},
            onTextFieldLosingFocus: () {},
          ),
        ),
      ),
    );
  }

  
  group("GPSProcess Tests: \n", 
  () 
  {  
    group("Title Tests: \n", 
    () 
    {  
      testWidgets("A title can be added by clicking on the placeholder title", 
      (WidgetTester tester) async 
      {
        var aTitle = "aTitle";

        // Pumping the widget
        await pumpGPSProblemToSolveDeclaration(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Searching the placeholder title 
        var placeholderTitleFinder = find.text(lgps.gpsDefaultProcessSessionTitle);

        // Tapping
        await tester.tap(placeholderTitleFinder);
        await tester.pumpAndSettle();

        // Searching the text field
        var textFieldFinder = find.ancestor
        (
          of: find.text(lgps.gpsProcessTitleTextFieldHint), 
          matching: find.byType(TextField)
        );

        // Entering a title
        await tester.enterText(textFieldFinder, aTitle);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Verifying the placeholder title absent
        expect(find.text(lgps.gpsDefaultProcessSessionTitle), findsNothing);

        // Verifying the title present
        expect(find.text(aTitle), findsOne);
      }
      );
  
      testWidgets("A title can be added by clicking on the edit emoji", 
      (WidgetTester tester) async 
      {
        var aTitle = "aTitle";

        // Pumping the widget
        await pumpGPSProblemToSolveDeclaration(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

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
          of: find.text(lgps.gpsProcessTitleTextFieldHint), 
          matching: find.byType(TextField)
        );

        // Entering a title
        await tester.enterText(textFieldFinder, aTitle);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Verifying the placeholder title absent
        expect(find.text(lgps.gpsDefaultProcessSessionTitle), findsNothing);

        // Verifying the title present
        expect(find.text(aTitle), findsOne);
      }
      );
  
    });

  
    group("Participants Identifiers Tests: \n", 
    () 
    {      
      // Tested at integration level:
      // - Addition
      // - Edition
      // - Deletion (single/bulk)
      

      // "Stakeholder identifiers' colors can be changed from green, to orange, to red, to green by tapping"
      // todo

      });
    

    group("Checklist Tests: \n", 
    () 
    {     
      // Tested at integration level:   
      // "The checklist turns to green when checked, and the rectangle goes from orange to transparent"
      
    });

    group("Keywords Tests: \n", 
    () 
    { 
      // Tested at integration level:
      // - Addition
      // - Deletion

    });
  
    group("List of Ideas Tests: \n", 
    () 
    { 
      // Tested at integration level:
      // - Addition
      // - Edition
      // - Single deletion

      testWidgets("[Bulk deletion] 50 ideas added are found in the list of ideas, and can be bulk deleted", 
      (WidgetTester tester) async 
      {
        var someText = "someText";

        // Pumping the widget
        await pumpGPSProcess(tester);

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings? lgps = .new(context); 

        // Searching the text field used to add ideas
        var newIdeaTextFieldFinder = find.ancestor
        (
          of: find.text(lgps.newIdeaTextFieldHint), 
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
        expect(find.text(lgps.ideasListPlaceholder), findsNothing);

        // Opening the overlay
        await tester.tap(find.text(lgps.ideasListTitle));
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));  

        var checkboxesFinder = find.byType(Checkbox, skipOffstage: false);
        
        // Tapping the first 2 checkboxes
        await tester.tap(checkboxesFinder.at(0));
        // pumpAndSettle timed out
        // await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2)); 
        await tester.tap(checkboxesFinder.at(1));
        await tester.pump(const Duration(seconds: 2)); 

        if (testingDebug) printTextData(tester);

        // Finding the bulk deletion
        var ideasListBulkDeletionTextFinder = find.text("${lgps.ideasListBulkDeletionText} (2)");
        await tester.tap(ideasListBulkDeletionTextFinder);
        await tester.pump(const Duration(seconds: 2)); 

        // Verifying absence by keys
        expect(find.text("someText0"), findsNothing);
        expect(find.text("someText1"), findsNothing);
      });

    });
  });
}