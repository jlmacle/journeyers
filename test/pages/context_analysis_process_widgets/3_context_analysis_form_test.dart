// ignore: file_names
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3_context_analysis_form.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart";
import "package:journeyers/utils/generic/dev/utility_classes_import.dart";
import "package:journeyers/widgets/custom/text/custom_heading.dart";

import "../../../integration_test/externalized_code/externalized_testing_code.dart";
import "../../_widget_testing_utils/widget_testing_utils.dart";

void main() 
{

  // ─── HELPER FUNCTIONS ───────────────────────────────────────

  // Method used to pump the CAForm widget
  Future<void> pumpCAForm(WidgetTester tester) async
  {
    return await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale(testingLocaleOption),
          home: Scaffold(
            body:  CAForm.fromDTO
            (
              dtoCAForm: DTOCAForm(),
              parentCallbackFunctionToRefreshTheCAPage: () {},
              parentCallbackFunctionToSetFocusabilityOfBottomBarItems: (_) {},
            )
          )
        )
    );
  }

  // Method used to pump the CAProcess widget
  Future<void> pumpCAProcess(WidgetTester tester) async
  {
    await tester.pumpWidget(
        MaterialApp
        (
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale(testingLocaleOption),
          home: Scaffold
          (
            body: CAProcess
            (
              caPageCallbackFunctionToRefreshThePage: (){},
              caPageCallbackFunctionToSetFocusabilityOfBottomBarItems: (_){},              
            )
          ),
        )
    );

    // Waiting to pass the circular indicator
    await tester.pump(const Duration(seconds: 2));

    return;
  }
  
  // Method used to find the Text widgets within the expansion tiles
  Finder getFinderForTextsWithinTheExpansionTiles()
  {
    return  
    find.descendant
    (
      of: find.byType(ExpansionTile), 
      matching: find.byType(Text)
    );
  }
  
  // ─── TESTS ───────────────────────────────────────

  group("CAForm Tests: \n", 
  () 
  {  
    group
    (
      "Form: Structure: Root structure: \n",
      ()
      {
        // "Two perspective expansion tiles are present"
        testWidgets
        (
          "Two perspective expansion tiles are present",
          (tester) async
          {
            // Pumping the CAForm widget
            await pumpCAForm(tester);

            // One tile for the individual perspective, one for the group/team perspective
            expect(find.byType(ExpansionTile), findsNWidgets(2));
          },
        );

        // "Individual and group tiles carry the correct heading text"
        testWidgets
        (
          "Individual and group tiles carry the correct heading text",
          (tester) async
          {
            // Pumping the CAForm widget
            await pumpCAForm(tester);

            var localeLanguageCode = getLocaleLanguageCode(tester);

            var individualPerspectiveQuestion = "";
            var groupPerspectiveQuestion = "";
            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                individualPerspectiveQuestion = "As an individual:\nWhat problem\nam I trying to solve?";
                groupPerspectiveQuestion = "As a member\nof groups/teams:\nWhat problem(s)\nare we trying to solve?";

              }
              case("fr"): 
              { 
                individualPerspectiveQuestion = "En tant qu'individu:\nQuel problème\ndois-je résoudre ?";
                groupPerspectiveQuestion = "En tant que membre\nde groupes/équipes:\nQuel(s) problème(s)\ndevons-nous résoudre ?";
              }              
            }

            // Verifying that the first expansion tile title is correct
            var firstExpansionTileTextFinder = getFinderForTextsWithinTheExpansionTiles().first;
            Text firstExpansionTileTextWidget = tester.widget<Text>(firstExpansionTileTextFinder);   
   
            expect(firstExpansionTileTextWidget.data, individualPerspectiveQuestion);

            // Verifying that the second expansion tile title is correct
            var secondExpansionTileTextFinder = getFinderForTextsWithinTheExpansionTiles().last;
            Text secondExpansionTileTextWidget = tester.widget<Text>(secondExpansionTileTextFinder);        
            expect(secondExpansionTileTextWidget.data, groupPerspectiveQuestion);
          },
        ); 

      });

    // ─── INDIVIDUAL PERSPECTIVE ───────────────────────────────────────
    // "Form: Structure: Individual perspective: \n"
    group
    (
      "Form: Structure: Individual perspective: \n",
      ()
      {
        // "Expanding the tile with the individual perspective reveals all four level-3 section questions"
        testWidgets
        (
          "Expanding the tile with the individual perspective reveals all four level-3 section questions",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
  
            // Opening the individual perspective expansion tile
              // Getting the build context
            final context = tester.element(find.byType(Scaffold));
            await caOpenIndividualExpansionTile(context, tester);           

            // Searching the custom headings text for the first expansion tile
            var customHeadingTextFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.descendant
              (
                of: find.byType(CustomHeading),
                matching: find.byType(Text)
              )
            );

            var localeLanguageCode = getLocaleLanguageCode(tester);
            
            var individualPerspectiveBalanceIssue = "";
            var individualPerspectiveWorkplaceIssue = "";
            var individualPerspectiveLegacyIssue = "";
            var individualPerspectiveAnotherIssue = "";
            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                individualPerspectiveBalanceIssue = "A Balance Issue?";
                individualPerspectiveWorkplaceIssue = "A Workplace Issue?";
                individualPerspectiveLegacyIssue = "A Legacy Issue?";
                individualPerspectiveAnotherIssue = "Is the issue\nof another type?";
              }
              case("fr"): 
              { 
                individualPerspectiveBalanceIssue = "Un problème d'équilibre ?";
                individualPerspectiveWorkplaceIssue = "Un problème au travail ?";
                individualPerspectiveLegacyIssue = "Un problème\navec mon histoire de vie ?";
                individualPerspectiveAnotherIssue = "Est-ce un autre type\nde problème ?";
              }              
            }

            if (testingDebug) pu.printd("Testing Debug: data: $individualPerspectiveBalanceIssue");
            if (testingDebug) pu.printd("Testing Debug: data: $individualPerspectiveWorkplaceIssue");
            if (testingDebug) pu.printd("Testing Debug: data: $individualPerspectiveLegacyIssue");
            if (testingDebug) pu.printd("Testing Debug: data: $individualPerspectiveAnotherIssue");


            // Verifying the level 3 titles present
            expect(tester.widget<Text>(customHeadingTextFinders.at(1)).data, individualPerspectiveBalanceIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(2)).data, individualPerspectiveWorkplaceIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(3)).data, individualPerspectiveLegacyIssue);
            expect(tester.widget<Text>(customHeadingTextFinders.at(4)).data, individualPerspectiveAnotherIssue);
          },
        );      
      
        // "Expanding the tile with the individual perspective reveals the correct total number of checkbox items: \n"
        // "4 balance + 2 workplace + 1 legacy = 7"
        testWidgets
        (
          "Expanding the tile with the individual perspective reveals the correct total number of checkbox items: \n"
          "4 balance + 2 workplace + 1 legacy = 7",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
              // Getting the build context
            final context = tester.element(find.byType(Scaffold));
            await caOpenIndividualExpansionTile(context, tester);

            // Getting the first expansion tile
            var individualExpansionTileFinder =  find.byType(ExpansionTile).first;

            // Searching 7 custom checkbox widgets
            expect
            (
              find.descendant(of: individualExpansionTileFinder, matching: find.byType(CACheckboxWithSanitizedAndPaddedTextField)), 
              findsNWidgets(7)
            );
          },
        );
      
        // "Expanding the tile with the individual perspective reveals the correct total number of text field only items: \n"
        // "1 issue of another type = 1"
        testWidgets
        (
          "Expanding the tile with the individual perspective reveals the correct total number of text field only items: \n"
          "1 issue of another type = 1",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
              // Getting the build context
            final context = tester.element(find.byType(Scaffold));
            await caOpenIndividualExpansionTile(context, tester);

            // Getting the first expansion tile
            var individualExpansionTileFinder =  find.byType(ExpansionTile).first;

            // Searching 1 custom text field widget
            expect
            (
              find.descendant(of: individualExpansionTileFinder, matching: find.byType(CATextFieldSanitizedAndPadded)), 
              findsNWidgets(1)
            );
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: BALANCE SECTION ───────────────────────────────────────
        // "Balance issue: all four item labels are correct after expansion",
        testWidgets
        (          
          "Balance issue: all four item labels are correct after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
              // Getting the build context
            final context = tester.element(find.byType(Scaffold));
            await caOpenIndividualExpansionTile(context, tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );


            var localeLanguageCode = getLocaleLanguageCode(tester);

            var level3TitleBalanceIssueItem1 = "";
            var level3TitleBalanceIssueItem2 = "";
            var level3TitleBalanceIssueItem3 = "";
            var level3TitleBalanceIssueItem4 = "";
            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                level3TitleBalanceIssueItem1 = "To balance studies and household life?";
                level3TitleBalanceIssueItem2 = "To balance accessing income and household life?";
                level3TitleBalanceIssueItem3 = "To balance earning an income and household life?";
                level3TitleBalanceIssueItem4 = "To balance helping others and household life?";
              }
              case("fr"): 
              { 
                level3TitleBalanceIssueItem1 = "Équilibre entre les études et la vie de famille ?";
                level3TitleBalanceIssueItem2 = "Équilibre entre l'accès à l'emploi et la vie de famille ?";
                level3TitleBalanceIssueItem3 = "Équilibre entre maintenir un revenu et la vie de famille ?";
                level3TitleBalanceIssueItem4 = "Équilibre entre aider les autres et la vie de famille ?";
              }              
            }

            if (testingDebug) pu.printd("Testing Debug: data: $level3TitleBalanceIssueItem1");
            if (testingDebug) pu.printd("Testing Debug: data: $level3TitleBalanceIssueItem2");
            if (testingDebug) pu.printd("Testing Debug: data: $level3TitleBalanceIssueItem3");
            if (testingDebug) pu.printd("Testing Debug: data: $level3TitleBalanceIssueItem4");

            // Verifying the level 3 titles present
            expect(tester.widget<Text>(textFinders.at(2)).data, level3TitleBalanceIssueItem1);
            expect(tester.widget<Text>(textFinders.at(3)).data, level3TitleBalanceIssueItem2);
            expect(tester.widget<Text>(textFinders.at(4)).data, level3TitleBalanceIssueItem3);
            expect(tester.widget<Text>(textFinders.at(5)).data, level3TitleBalanceIssueItem4);
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: WORKPLACE SECTION ───────────────────────────────────────
        // "Workplace issue: both item labels are correct after expansion",
        testWidgets
        (
          
          "Workplace issue: both item labels are correct after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
              // Getting the build context
            final context = tester.element(find.byType(Scaffold));
            await caOpenIndividualExpansionTile(context, tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            

            var localeLanguageCode = getLocaleLanguageCode(tester);

            var level3TitleWorkplaceIssueItem1 = "";
            var level3TitleWorkplaceIssueItem2 = "";
            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                level3TitleWorkplaceIssueItem1 = "To solve a need to be more appreciated at work?";
                level3TitleWorkplaceIssueItem2 = "To solve a need to remain appreciated at work?";
              }
              case("fr"): 
              { 
                level3TitleWorkplaceIssueItem1 = "Le besoin d'être plus apprécié(e) au travail ?";
                level3TitleWorkplaceIssueItem2 = "Le besoin de rester apprécié(e) au travail ?";              
              }
            }

            if (testingDebug) pu.printd("Testing Debug: data: $level3TitleWorkplaceIssueItem1");
            if (testingDebug) pu.printd("Testing Debug: data: $level3TitleWorkplaceIssueItem2");



            // Verifying the level 3 titles present
            expect(tester.widget<Text>(textFinders.at(7)).data, level3TitleWorkplaceIssueItem1);
            expect(tester.widget<Text>(textFinders.at(8)).data, level3TitleWorkplaceIssueItem2);
          },
        );

        // ─── INDIVIDUAL PERSPECTIVE: LEGACY SECTION ───────────────────────────────────────
        // "Legacy issue: the item label is present after expansion",
        testWidgets
        (          
          "Legacy issue: the item label is present after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
              // Getting the build context
            final context = tester.element(find.byType(Scaffold));
            await caOpenIndividualExpansionTile(context, tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            var localeLanguageCode = getLocaleLanguageCode(tester);
           
            var individualPerspectiveBetterLegacy = "";

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                individualPerspectiveBetterLegacy = "To have a better legacy to leave to my children/others?";
              }
              case("fr"): 
              { 
                individualPerspectiveBetterLegacy = "Avoir une histoire de vie de meilleure qualité à laisser à mes enfants/aux autres ?";                
              }              
            }

            // Verifying the level 3 title present
            expect(tester.widget<Text>(textFinders.at(10)).data, individualPerspectiveBetterLegacy);
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: ANOTHER ISSUE SECTION ───────────────────────────────────────
        // "Another issue: the hint text is present after expansion",
        testWidgets
        (          
          "Another issue: the hint text is present after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
              // Getting the build context
            final context = tester.element(find.byType(Scaffold));
            await caOpenIndividualExpansionTile(context, tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            

            var localeLanguageCode = getLocaleLanguageCode(tester);

            var caProcessPleaseDevelopTextFieldHint = "";

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                caProcessPleaseDevelopTextFieldHint = "Please develop.";
              }
              case("fr"): 
              { 
                caProcessPleaseDevelopTextFieldHint = "Veuillez développer.";                
              }              
            }

            // Verifying the level 3 title present
            expect(tester.widget<Text>(textFinders.at(12)).data, caProcessPleaseDevelopTextFieldHint);
          },
        );
      
      }
    );    

    // ─── GROUP/TEAMS PERSPECTIVE ───────────────────────────────────────
    // "Form: Structure: Group/Teams perspective: \n"
    group
    (
      "Form: Structure: Group/Teams perspective: \n",
      ()
      {
        // "Expanding the tile with the group/teams perspective reveals all five level-3 questions",
        testWidgets
        (
          "Expanding the tile with the group/teams perspective reveals all five level-3 questions",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);            

            // Opening the group/team perspective expansion tile
            var context = tester.element(find.byType(Scaffold));
            await caOpenGroupExpansionTile(context, tester);

            // Searching the custom headings text for the second expansion tile
            var customHeadingTextFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .last, 
              matching: find.descendant
              (
                of: find.byType(CustomHeading),
                matching: find.byType(Text)
              )
            );


            var localeLanguageCode = getLocaleLanguageCode(tester);

            var groupPerspectiveProblems = "";
            var groupPerspectiveSameProblems = "";
            var groupPerspectiveHarmonyHome = "";
            var groupPerspectiveAppreciabilityWork = "";
            var groupPerspectiveEarningAbility = "";

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                groupPerspectiveProblems = "What problem(s)\nare my groups/teams\ntrying to solve?";
                groupPerspectiveSameProblems = "Am I trying to solve the same problem(s) as my groups/teams?";
                groupPerspectiveHarmonyHome = "Is entering the group problem-solving process consistent with harmony at home?";
                groupPerspectiveAppreciabilityWork = "Is entering the group problem-solving process consistent with appreciability at work?";
                groupPerspectiveEarningAbility = "Is entering the group problem-solving process consistent with my income earning ability?";
              }
              case("fr"): 
              { 
                groupPerspectiveProblems = "Quel(s) problème(s)\nnos groupes/équipes\nessayent de résoudre ?";
                groupPerspectiveSameProblems = "Est-ce que j'essaie de résoudre les mêmes problèmes que mes groupes/équipes ?";
                groupPerspectiveHarmonyHome = "Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec l'harmonie dans le foyer ?";
                groupPerspectiveAppreciabilityWork = "Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec rester apprécié au travail ?";
                groupPerspectiveEarningAbility = "Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec ma capacité à générer un revenu ?";
              }              
            }

            if (testingDebug) pu.printd("Testing Debug: data: $groupPerspectiveProblems");
            if (testingDebug) pu.printd("Testing Debug: data: $groupPerspectiveSameProblems");
            if (testingDebug) pu.printd("Testing Debug: data: $groupPerspectiveHarmonyHome");
            if (testingDebug) pu.printd("Testing Debug: data: $groupPerspectiveAppreciabilityWork");
            if (testingDebug) pu.printd("Testing Debug: data: $groupPerspectiveEarningAbility");

            // Verifying the level 3 titles present
            expect(tester.widget<Text>(customHeadingTextFinders.at(1)).data, groupPerspectiveProblems);
            expect(tester.widget<Text>(customHeadingTextFinders.at(2)).data, groupPerspectiveSameProblems);
            expect(tester.widget<Text>(customHeadingTextFinders.at(3)).data, groupPerspectiveHarmonyHome);
            expect(tester.widget<Text>(customHeadingTextFinders.at(4)).data, groupPerspectiveAppreciabilityWork);
            expect(tester.widget<Text>(customHeadingTextFinders.at(5)).data, groupPerspectiveEarningAbility);
          },
        );
      
        // "Expanding the tile with the group/teams perspective reveals the correct total number of text field only items: \n"
        // "1 problems the groups/teams are trying to solve = 1"
        testWidgets
        (
          "Expanding the tile with the group/teams perspective reveals the correct total number of text field only items: \n"
          "1 problems the groups/teams are trying to solve = 1",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the group/team perspective expansion tile
            var context = tester.element(find.byType(Scaffold));
            await caOpenGroupExpansionTile(context, tester);

            // Getting the second expansion tile
            var groupExpansionTileFinder =  find.byType(ExpansionTile).last;

            // Searching 1 custom text field widget
            expect
            (
              find.descendant(of: groupExpansionTileFinder, matching: find.byType(CATextFieldSanitizedAndPadded)), 
              findsNWidgets(1)
            );
          },
        );
      
        // "Expanding the tile with the group/teams perspective reveals the correct total number of segmented button items: \n"
        // "4"
        testWidgets
        (
          "Expanding the tile with the group/teams perspective reveals the correct total number of segmented button items: \n"
          "4",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the group/team perspective expansion tile
            var context = tester.element(find.byType(Scaffold));
            await caOpenGroupExpansionTile(context, tester);

            // Getting the second expansion tile
            var groupExpansionTileFinder =  find.byType(ExpansionTile).last;

            // Searching 4 custom segmented button widgets
            expect
            (
              find.descendant(of: groupExpansionTileFinder, matching: find.byType(CASegmentedButtonWithSanitizedAndPaddedTextField)), 
              findsNWidgets(4)
            );
          },
        );
      
      }
    ); 

    group("Form: Start values: \n", 
    () 
    { 
        // "At start, when the tile with the individual perspective is unfolded, all checkboxes are unchecked"
        testWidgets("At start, when the tile with the individual perspective is unfolded, all checkboxes are unchecked", 
        (WidgetTester tester) async {

          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the individual perspective expansion tile
            // Getting the build context
          final context = tester.element(find.byType(Scaffold));
          await caOpenIndividualExpansionTile(context, tester);   

          // Searching the checkboxes present in the sub-tree
          var checkboxFinder = find.descendant
          (
            of: find.byType(ExpansionTile)
                .first, 
            matching: find.byType(Checkbox)                            
          );

          // Verifying all checkboxes unchecked
          for(var checkboxElement in checkboxFinder.evaluate())
          {
            Checkbox checkboxWidget = checkboxElement.widget as Checkbox;
            expect(checkboxWidget.value, false);
          }
            
        }
        );
    
        // "At start, when the tile with the group/teams perspective is unfolded, no selection is present in the segmented buttons"
        testWidgets("At start, when the tile with the group/teams perspective is unfolded, no selection is present in the segmented buttons", 
        (WidgetTester tester) async {

          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);
          
          // Opening the group/teams perspective expansion tile
          var context = tester.element(find.byType(Scaffold));          
          await caOpenGroupExpansionTile(context, tester);   

          // Searching the segmented buttons present in the sub-tree
          var segButtonFinder = find.descendant
          (
            of: find.byType(ExpansionTile)
                .last, 
            matching: find.byType(SegmentedButton)                            
          );

          // Verifying all segmented buttons without selection
          for(var segButtonElement in segButtonFinder.evaluate())
          {
            SegmentedButton segButtonWidget = segButtonElement.widget as SegmentedButton;
            expect(segButtonWidget.selected, {});
          }     
        }
        );
 
    });      
  });

     
}