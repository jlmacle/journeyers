// ignore: file_names
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_ca_questions_fields.dart";
import "package:journeyers/l10n/localized_ca_strings.dart";
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

            // Verifying the second title correct
            expect(secondExpansionTileTextWidget.data, lqf.level2TitleGroup);
          },
        ); 

        testWidgets("Individual and group tiles carry the correct sub-text",
          (tester) async
          {
            // Pumping the CAForm widget
            await pumpCAForm(tester);

            // Acccessing the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedCAStrings lca = .new(context);

            var localeLanguageCode = getLocaleLanguageCode(tester);

            var invitationToUnfoldExpansionTile = ""; 

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): { invitationToUnfoldExpansionTile = "Please click to toggle"; }
              case("fr"): { invitationToUnfoldExpansionTile = "Veuillez cliquer pour commencer"; }        
            }
            if (testingDebug) pu.printd("Testing Debug: invitationToUnfoldExpansionTile: $invitationToUnfoldExpansionTile"); 

            // Verifying that the first expansion tile subtext is correct 
            var firstUnfoldedExpansionTileSubTextFinder = find.descendant
                                                    (
                                                      // first expansion tile
                                                      of: find.byType(ExpansionTile).first, 
                                                      matching: find.byType(Text)
                                                    // second Text widget out of 2
                                                    ).last;
            Text firstUnfoldedExpansionTileSubTextWidget = tester.widget<Text>(firstUnfoldedExpansionTileSubTextFinder);
            
            // Verifying consistency between hard-coded string and localized string
            expect(invitationToUnfoldExpansionTile, lca.invitationToUnfoldExpansionTile);     

            // Verifying the first subtext correct
            expect(firstUnfoldedExpansionTileSubTextWidget.data, lca.invitationToUnfoldExpansionTile);

            // Verifying that the second expansion tile subtext is correct 
            var secondUnfoldedExpansionTileSubTextFinder = find.descendant
                                                    (
                                                      // second expansion tile
                                                      of: find.byType(ExpansionTile).last, 
                                                      matching: find.byType(Text)
                                                    // second Text widget out of 2
                                                    ).last;
            Text secondUnfoldedExpansionTileSubTextWidget = tester.widget<Text>(secondUnfoldedExpansionTileSubTextFinder);       
            
            // Verifying the second sub-text correct
            expect(secondUnfoldedExpansionTileSubTextWidget.data, lca.invitationToUnfoldExpansionTile);
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
            expect(tester.widget<Text>(customHeadingTextsFinders.at(2)).data, lqf.level3TitleBalanceIssue);
            expect(tester.widget<Text>(customHeadingTextsFinders.at(3)).data, lqf.level3TitleWorkplaceIssue);
            expect(tester.widget<Text>(customHeadingTextsFinders.at(4)).data, lqf.level3TitleLegacyIssue);
            expect(tester.widget<Text>(customHeadingTextsFinders.at(5)).data, lqf.level3TitleAnotherIssue);
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
          "Issue of another type = 1",
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
        testWidgets("Balance issue: all four item labels are correct and present after expansion",
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


            // Verifying the level 3 items present
            expect(tester.widget<Text>(textsFinder.at(3)).data, lqf.level3TitleBalanceIssueItem1);
            expect(tester.widget<Text>(textsFinder.at(4)).data, lqf.level3TitleBalanceIssueItem2);
            expect(tester.widget<Text>(textsFinder.at(5)).data, lqf.level3TitleBalanceIssueItem3);
            expect(tester.widget<Text>(textsFinder.at(6)).data, lqf.level3TitleBalanceIssueItem4);
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: WORKPLACE SECTION ───────────────────────────────────────
        testWidgets("Workplace issue: both item labels are correct and present after expansion",
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

            // Verifying consistency between hard-coded strings and localized strings
            expect(level3TitleWorkplaceIssueItem1, lqf.level3TitleWorkplaceIssueItem1);     
            expect(level3TitleWorkplaceIssueItem2, lqf.level3TitleWorkplaceIssueItem2);


            // Verifying the level 3 items present
            expect(tester.widget<Text>(textFinders.at(8)).data, lqf.level3TitleWorkplaceIssueItem1);
            expect(tester.widget<Text>(textFinders.at(9)).data, lqf.level3TitleWorkplaceIssueItem2);
          },
        );

        // ─── INDIVIDUAL PERSPECTIVE: LEGACY SECTION ───────────────────────────────────────
        testWidgets("Legacy issue: the item label is correct and present after expansion",
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

            var localeLanguageCode = getLocaleLanguageCode(tester);
            
            var level3TitleLegacyIssueItem1 = "";

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                level3TitleLegacyIssueItem1 = "To have a better legacy to leave to my children/others?";
              }
              case("fr"): 
              { 
                level3TitleLegacyIssueItem1 = "Avoir une histoire de vie de meilleure qualité à laisser à mes enfants/aux autres ?";
              }              
            }

            if (testingDebug) pu.printd("Testing Debug: data: $level3TitleLegacyIssueItem1");

            // Verifying consistency between hard-coded strings and localized strings
            expect(level3TitleLegacyIssueItem1, lqf.level3TitleLegacyIssueItem1);     

            // Verifying the level 3 item present
            expect(tester.widget<Text>(textFinders.at(11)).data, lqf.level3TitleLegacyIssueItem1);
          },
        );
      
        // ─── INDIVIDUAL PERSPECTIVE: ANOTHER ISSUE SECTION ───────────────────────────────────────
        testWidgets("Another issue: the hint text is correct and present after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);

            // Getting the localized strings
            final context = tester.element(find.byType(Scaffold));
            LocalizedCAStrings lca = .new(context);
            
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(context, tester);

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text)
            );

            var localeLanguageCode = getLocaleLanguageCode(tester);

            var caFormPleaseDevelopTextFieldHint = "";

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                caFormPleaseDevelopTextFieldHint = "Please develop.";
              }
              case("fr"): 
              { 
                caFormPleaseDevelopTextFieldHint = "Veuillez développer.";                
              }              
            }

            // Verifying consistency between hard-coded string and localized string
            expect(caFormPleaseDevelopTextFieldHint, lca.caFormPleaseDevelopTextFieldHint);

            // Verifying text hint text present 
            expect(tester.widget<Text>(textFinders.at(13)).data, lca.caFormPleaseDevelopTextFieldHint);
          },
        );
      

        // ─── INDIVIDUAL PERSPECTIVE: HINT TEXTS ───────────────────────────────────────
        testWidgets("Individual perspective: Checkboxes with text fields: the hint texts are correct and present after expansion",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);

            // Getting the localized strings
            final context = tester.element(find.byType(Scaffold));
            LocalizedCAStrings lca = .new(context);
            
            // Opening the individual perspective expansion tile
            await caOpenIndividualExpansionTile(context, tester);

            // Checking all checkboxes
            var checkboxesFinder = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Checkbox),
              skipOffstage: false                         
            );

            var totalCheckboxesFinders = checkboxesFinder.evaluate().length;
            if (testingDebug) pu.printd("Testing Debug: totalCheckboxesFinders: $totalCheckboxesFinders");
            
            for(var i = 0; i < checkboxesFinder.evaluate().length; i++)
            {
              await tester.scrollUntilVisible
              (
                checkboxesFinder.at(i), 
                45, 
                scrollable: find.descendant
                          (
                            of: find.byKey(const Key("context-analysis-process-scrollview")), 
                            matching: find.byType(Scrollable)
                          ).first,
              );   
              // pumpAndSettle timed out
              await tester.pump(const Duration(seconds: 2));
              await tester.tap(checkboxesFinder.at(i));
              await tester.pump(const Duration(seconds: 2));
            }

            // Searching the Text widgets for the first expansion tile
            var textFinders = find.descendant
            (
              of: find.byType(ExpansionTile)
                  .first, 
              matching: find.byType(Text),
              skipOffstage: false
            );
            
            var totalTextFinders = textFinders.evaluate().length;
            if (testingDebug) pu.printd("Testing Debug: totalTextFinders: $totalTextFinders");

            var localeLanguageCode = getLocaleLanguageCode(tester);

            var pastOutcomesHouseholdTextFieldHint = "";
            var pastOutcomesWorkplaceTextFieldHint = "";
            var helpingAndHouseholdTextFieldHint = "";
            var caFormPleaseDevelopTextFieldHint = "";

            switch(localeLanguageCode.toLowerCase())
            {
              case("en"): 
              { 
                pastOutcomesHouseholdTextFieldHint = "Please describe the past outcomes of the problem for the household, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the household.";
                pastOutcomesWorkplaceTextFieldHint = "Please describe the past outcomes of the problem for the workplace, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the workplace and for the household.";
                helpingAndHouseholdTextFieldHint = "Please develop the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others.";
                caFormPleaseDevelopTextFieldHint = "Please develop.";
              }
              case("fr"): 
              { 
                pastOutcomesHouseholdTextFieldHint = "Veuillez décrire les conséquences du problème, si des membres du foyer ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable aux membres du foyer.";
                pastOutcomesWorkplaceTextFieldHint  = "Veuillez décrire les conséquences du problème, si des membres du lieu de travail ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable aux collègues du lieu de travail et aux membres du foyer.";
                helpingAndHouseholdTextFieldHint = "Veuillez développer les raisons, et les impacts potentiels, d'un déséquilibre entre fidélité envers votre famille et considération envers les autres.";
                caFormPleaseDevelopTextFieldHint = "Veuillez développer.";                
              }              
            }

            if (testingDebug) pu.printd("Testing Debug: data: $pastOutcomesHouseholdTextFieldHint");
            if (testingDebug) pu.printd("Testing Debug: data: $pastOutcomesWorkplaceTextFieldHint");
            if (testingDebug) pu.printd("Testing Debug: data: $helpingAndHouseholdTextFieldHint");
            if (testingDebug) pu.printd("Testing Debug: data: $caFormPleaseDevelopTextFieldHint");

            // Verifying consistency between hard-coded strings and localized strings
            expect(pastOutcomesHouseholdTextFieldHint, lca.pastOutcomesHouseholdTextFieldHint);     
            expect(pastOutcomesWorkplaceTextFieldHint, lca.pastOutcomesWorkplaceTextFieldHint);     
            expect(helpingAndHouseholdTextFieldHint, lca.helpingAndHouseholdTextFieldHint);
            expect(caFormPleaseDevelopTextFieldHint, lca.caFormPleaseDevelopTextFieldHint);

            for(var i= 0; i < totalTextFinders; i++)
            {
              if (testingDebug) pu.printd("$i: ${tester.widget<Text>(textFinders.at(i)).data}");
            }

            // Verifying the hint texts present 
            expect(tester.widget<Text>(textFinders.at(4)).data, lca.pastOutcomesHouseholdTextFieldHint);
            expect(tester.widget<Text>(textFinders.at(7)).data, lca.pastOutcomesHouseholdTextFieldHint);
            expect(tester.widget<Text>(textFinders.at(10)).data, lca.pastOutcomesHouseholdTextFieldHint);           
            expect(tester.widget<Text>(textFinders.at(13)).data, lca.helpingAndHouseholdTextFieldHint);          
            expect(tester.widget<Text>(textFinders.at(17)).data, lca.pastOutcomesWorkplaceTextFieldHint);
            expect(tester.widget<Text>(textFinders.at(20)).data, lca.pastOutcomesWorkplaceTextFieldHint);           
            expect(tester.widget<Text>(textFinders.at(24)).data, lca.caFormPleaseDevelopTextFieldHint);          
            expect(tester.widget<Text>(textFinders.at(27)).data, lca.caFormPleaseDevelopTextFieldHint);
          },
        );
      
      }
    );    

    // ─── GROUP/TEAMS PERSPECTIVE ───────────────────────────────────────
    group("Form: Structure: Group/Teams perspective: \n",
      ()
      {    
        testWidgets("Expanding the tile with the group/teams perspective reveals the five correct level-3 section questions",
          (tester) async
          {
            // Pumping the widget within the CA process to allow for the tile expansion
            await pumpCAProcess(tester);      

            // Acccessing the localized strings
            var context = tester.element(find.byType(Scaffold).first);
            LocalizedCAQuestionsFields lqf = .new(context);      

            // Opening the group/team perspective expansion tile
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

            // Verifying consistency between hard-coded strings and localized strings
            expect(groupPerspectiveProblems, lqf.level3TitleGroupsProblematics);     
            expect(groupPerspectiveSameProblems, lqf.level3TitleSameProblem);
            expect(groupPerspectiveHarmonyHome, lqf.level3TitleHarmonyAtHome);
            expect(groupPerspectiveAppreciabilityWork, lqf.level3TitleAppreciabilityAtWork);
            expect(groupPerspectiveEarningAbility, lqf.level3TitleIncomeEarningAbility);

            // Verifying the level 3 titles present (skipping lca.invitationToUnfoldExpansionTile)
            expect(tester.widget<Text>(customHeadingTextsFinder.at(2)).data, lqf.level3TitleGroupsProblematics);
            expect(tester.widget<Text>(customHeadingTextsFinder.at(3)).data, lqf.level3TitleSameProblem);
            expect(tester.widget<Text>(customHeadingTextsFinder.at(4)).data, lqf.level3TitleHarmonyAtHome);
            expect(tester.widget<Text>(customHeadingTextsFinder.at(5)).data, lqf.level3TitleAppreciabilityAtWork);
            expect(tester.widget<Text>(customHeadingTextsFinder.at(6)).data, lqf.level3TitleIncomeEarningAbility);
          },
        );
      
        testWidgets("Expanding the tile with the group/teams perspective reveals the correct total number of text field only items: \n"
          "Problems the groups/teams are trying to solve = 1",
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