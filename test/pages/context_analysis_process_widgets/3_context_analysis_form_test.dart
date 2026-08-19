// ignore: file_names
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_ca_questions_fields.dart";
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
  
  // ─── TESTS ───────────────────────────────────────

  group("CAForm Tests: \n", 
  () 
  {  
    group("Form: Structure: Root structure: \n",
      ()
      {
        testWidgets("Two perspective expansion tiles are present",
          (tester) async
          {
            // Pumping the CAForm widget
            await pumpCAForm(tester);

            // One tile for the individual perspective, one for the group/team perspective
            expect(find.byType(ExpansionTile), findsNWidgets(2));
          },
        );

        testWidgets("Individual and group tiles carry the correct heading text",
          (tester) async
          {
            // Pumping the CAForm widget
            await pumpCAForm(tester);

            // Acccessing the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedCAQuestionsFields lqf = .new(context);

            var localeLanguageCode = getLocaleLanguageCode(tester);
            if (testingDebug) pu.printd("Testing Debug: operatingSystem: ${Platform.operatingSystem}");
            if (testingDebug) pu.printd("Testing Debug: localeLanguageCode: $localeLanguageCode");

            var level2TitleIndividual = ""; 
            var level2TitleGroup = ""; 

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): { level2TitleIndividual = "As an individual:\nWhat problem\nam I trying to solve?"; }
              case("fr"): { level2TitleIndividual = "En tant qu'individu:\nQuel problème\ndois-je résoudre ?"; }        
            }
            if (testingDebug) pu.printd("Testing Debug: hintText: $level2TitleIndividual"); 

            // Verifying that the first expansion tile title is correct 
            var firstExpansionTileQuestionFinder = find.descendant
                                                    (
                                                      // first expansion tile
                                                      of: find.byType(ExpansionTile).first, 
                                                      matching: find.byType(Text)
                                                    // first Text widget out of 2
                                                    ).first;
            Text firstExpansionTileTextWidget = tester.widget<Text>(firstExpansionTileQuestionFinder.first);
            
            // Verifying consistency between hard-coded string and localized string
            expect(level2TitleIndividual, lqf.level2TitleIndividual);     

            // Verifying the first title correct
            expect(firstExpansionTileTextWidget.data, lqf.level2TitleIndividual);

            // Verifying that the second expansion tile title is correct 
            var secondExpansionTileQuestionFinder = find.descendant
                                                    (
                                                      // second expansion tile
                                                      of: find.byType(ExpansionTile).last, 
                                                      matching: find.byType(Text)
                                                    // first Text widget out of 2
                                                    ).first;
            Text secondExpansionTileTextWidget = tester.widget<Text>(secondExpansionTileQuestionFinder.first);        
            
            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): { level2TitleGroup = "As a member\nof groups/teams:\nWhat problem(s)\nare we trying to solve?"; }
              case("fr"): { level2TitleGroup = "En tant que membre\nde groupes/équipes:\nQuel(s) problème(s)\ndevons-nous résoudre ?"; }        
            }
            if (testingDebug) pu.printd("Testing Debug: hintText: $level2TitleGroup"); 

            // Verifying consistency between hard-coded string and localized string
            expect(level2TitleGroup, lqf.level2TitleGroup);     

            expect(secondExpansionTileTextWidget.data, lqf.level2TitleGroup);
          },
        ); 

      });

    // ─── INDIVIDUAL PERSPECTIVE ───────────────────────────────────────
    group("Form: Structure: Individual perspective: \n",
      ()
      {
        testWidgets("Expanding the tile with the individual perspective reveals the four correct level-3 section questions",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);

            // Getting the localized strings
            final context = tester.element(find.byType(Scaffold));
            LocalizedCAQuestionsFields lqf = .new(context); 

            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(context, tester);           

            // Searching the custom headings texts for the first expansion tile
            var customHeadingTextsFinders = find.descendant
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

            
            // Verifying consistency between hard-coded strings and localized strings
            expect(individualPerspectiveBalanceIssue, lqf.level3TitleBalanceIssue);     
            expect(individualPerspectiveWorkplaceIssue, lqf.level3TitleWorkplaceIssue);
            expect(individualPerspectiveLegacyIssue, lqf.level3TitleLegacyIssue);
            expect(individualPerspectiveAnotherIssue, lqf.level3TitleAnotherIssue);


            // Verifying the level 3 titles present (skipping lca.invitationToUnfoldExpansionTile)
            expect(tester.widget<Text>(customHeadingTextsFinders.at(2)).data, individualPerspectiveBalanceIssue);
            expect(tester.widget<Text>(customHeadingTextsFinders.at(3)).data, individualPerspectiveWorkplaceIssue);
            expect(tester.widget<Text>(customHeadingTextsFinders.at(4)).data, individualPerspectiveLegacyIssue);
            expect(tester.widget<Text>(customHeadingTextsFinders.at(5)).data, individualPerspectiveAnotherIssue);
          },
        );      
      
        testWidgets("Expanding the tile with the individual perspective reveals the correct total number of checkbox items: \n"
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
      
        testWidgets("Expanding the tile with the individual perspective reveals the correct total number of text field only items: \n"
          "1: issue of another type = 1",
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
        testWidgets("Balance issue: all four item labels are correct after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);
            
            // Opening the individual perspective expansion tile
              // Getting the build context
            final context = tester.element(find.byType(Scaffold));
            await caOpenIndividualExpansionTile(context, tester);

            // Searching the Text widgets for the first expansion tile
            var textsFinder = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            // Getting the localized strings
            LocalizedCAQuestionsFields lqf = .new(context); 

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

            // Verifying consistency between hard-coded strings and localized strings
            expect(level3TitleBalanceIssueItem1, lqf.level3TitleBalanceIssueItem1);     
            expect(level3TitleBalanceIssueItem2, lqf.level3TitleBalanceIssueItem2);
            expect(level3TitleBalanceIssueItem3, lqf.level3TitleBalanceIssueItem3);
            expect(level3TitleBalanceIssueItem4, lqf.level3TitleBalanceIssueItem4);


            // Verifying the level 3 titles present (skipping lca.invitationToUnfoldExpansionTile)
            expect(tester.widget<Text>(textsFinder.at(3)).data, lqf.level3TitleBalanceIssueItem1);
            expect(tester.widget<Text>(textsFinder.at(4)).data, lqf.level3TitleBalanceIssueItem2);
            expect(tester.widget<Text>(textsFinder.at(5)).data, lqf.level3TitleBalanceIssueItem3);
            expect(tester.widget<Text>(textsFinder.at(6)).data, lqf.level3TitleBalanceIssueItem4);
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: WORKPLACE SECTION ───────────────────────────────────────
        testWidgets("Workplace issue: both item labels are correct after expansion",
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

            // Getting the localized strings
            LocalizedCAQuestionsFields lqf = .new(context);

            // Verifying the level 3 titles present (skipping lca.invitationToUnfoldExpansionTile)
            expect(tester.widget<Text>(textFinders.at(8)).data, lqf.level3TitleWorkplaceIssueItem1);
            expect(tester.widget<Text>(textFinders.at(9)).data, lqf.level3TitleWorkplaceIssueItem2);
          },
        );

        // ─── INDIVIDUAL PERSPECTIVE: LEGACY SECTION ───────────────────────────────────────
        testWidgets("Legacy issue: the item label is present after expansion",
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

            // Getting the localized strings
            LocalizedCAQuestionsFields lqf = .new(context);

            // Verifying the level 3 title present (skipping lca.invitationToUnfoldExpansionTile)
            expect(tester.widget<Text>(textFinders.at(11)).data, lqf.level3TitleLegacyIssueItem1);
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: ANOTHER ISSUE SECTION ───────────────────────────────────────
        testWidgets("Another issue: the hint text is present after expansion",
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

            // Verifying the level 3 title present (skipping lca.invitationToUnfoldExpansionTile)
            expect(tester.widget<Text>(textFinders.at(13)).data, caProcessPleaseDevelopTextFieldHint);
          },
        );
      
      }
    );    

    // ─── GROUP/TEAMS PERSPECTIVE ───────────────────────────────────────
    group("Form: Structure: Group/Teams perspective: \n",
      ()
      {    
        testWidgets("Expanding the tile with the group/teams perspective reveals all five level-3 questions",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);            

            // Opening the group/team perspective expansion tile
            var context = tester.element(find.byType(Scaffold));
            await caOpenGroupExpansionTile(context, tester);

            // Searching the custom headings text for the second expansion tile
            var customHeadingTextsFinder = find.descendant
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

            // Verifying the level 3 titles present (skipping lca.invitationToUnfoldExpansionTile)
            expect(tester.widget<Text>(customHeadingTextsFinder.at(2)).data, groupPerspectiveProblems);
            expect(tester.widget<Text>(customHeadingTextsFinder.at(3)).data, groupPerspectiveSameProblems);
            expect(tester.widget<Text>(customHeadingTextsFinder.at(4)).data, groupPerspectiveHarmonyHome);
            expect(tester.widget<Text>(customHeadingTextsFinder.at(5)).data, groupPerspectiveAppreciabilityWork);
            expect(tester.widget<Text>(customHeadingTextsFinder.at(6)).data, groupPerspectiveEarningAbility);
          },
        );
      
        testWidgets("Expanding the tile with the group/teams perspective reveals the correct total number of text field only items: \n"
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
      
        testWidgets("Expanding the tile with the group/teams perspective reveals the correct total number of segmented button items: \n"
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