// ignore: file_names
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_page.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";

void main() 
{
  Future<void> pumpGPSPage(WidgetTester tester) async
  {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(testingLocaleOption),
        home: 
        Scaffold
        (
          body: GPSPage ()
        )
      )
    );
  }

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

  Future<void> pumpGPSChecklist(WidgetTester tester) async
  {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(testingLocaleOption),
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
      // to be updated

      });
    });

    // todo: to understand why not passing anymore
    group("Checklist Tests: \n", 
    () 
    {        
      // testWidgets("The checklist turns to green when checked, and the rectangle goes from orange to transparent", 
      // (WidgetTester tester) async 
      // {

      //   // Pumping the widget
      //   await pumpGPSChecklist(tester);
      //   await tester.pumpAndSettle();

      //   // Accessing the localized data
      //   var context = tester.element(find.byType(Scaffold).first);
      //   LocalizedGPSStrings lgps = .new(context);

      //   // Verifying the default rectangle color is orange
      //   await gpsTestChecklistTitleBorderColor(tester, rectangleColor);

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

      //     expect (activeColor, checkboxCheckedColor);        
      //   }

      //   // Searching to close the overlay
      //   var closeChecklistFinder = find.byTooltip(lgps.closeChecklistTooltipLabel);
      //   await tester.tap(closeChecklistFinder);
      //   await tester.pump(const Duration(seconds: 15));
      //   await tester.pumpAndSettle();
        
      //   // Verifying the rectangle color is transparent
      //   await gpsTestChecklistTitleBorderColor(tester, Colors.transparent);
      // });
    
    });

    group("Keywords Tests: \n", 
    () 
    { 
  
      // "A keyword can be added"
      
        // RenderFlex issue on small phone.
        // Wasn't able to reporoduce the issue manually.
        // Tested in the integration tests
      });
  
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
      });

    });

}