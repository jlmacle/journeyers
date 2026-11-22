// ignore: file_names

import "package:flutter_test/flutter_test.dart";
import "package:material_ui/material_ui.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_ca_form_questions.dart";
import "package:journeyers/l10n/localized_ca_other_strings.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3_context_analysis_form.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3a_context_analysis_custom_checkbox_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3b_context_analysis_custom_segmented_button_with_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/3c_context_analysis_custom_text_field_sanitized_and_padded.dart";
import "package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart";
import "package:journeyers/utils/generic/testing/test_utils.dart";
import "package:journeyers/widgets/custom/text/custom_heading.dart";

import "../../../integration_test/externalized_code/externalized_testing_code.dart";

void main() {
  // ─── HELPER FUNCTIONS ───────────────────────────────────────

  // Method used to pump the CAForm widget
  Future<void> pumpCAForm(WidgetTester tester) async {
    return await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(testingLocaleOption),
        home: Scaffold(
          body: CAForm.fromDTO(
            dtoCAForm: DTOCAForm(),
            parentCallbackFunctionToRefreshTheCAPage: () {},
            parentCallbackFunctionToSetFocusabilityOfBottomBarItems: (_) {},
          ),
        ),
      ),
    );
  }

  // Method used to pump the CAProcess widget
  Future<void> pumpCAProcess(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(testingLocaleOption),
        theme: appTheme,
        home: Scaffold(
          body: CAProcess(
            caPageCallbackFunctionToRefreshThePage: () {},
            caPageCallbackFunctionToSetFocusabilityOfBottomBarItems: (_) {},
          ),
        ),
      ),
    );

    // Waiting to pass the circular indicator
    await tester.pump(const Duration(seconds: 2));

    return;
  }

  // ─── TESTS ───────────────────────────────────────

  group("CAForm Tests: \n", () {
    group("Form: Structure: Root structure: \n", () {
      testWidgets("Two perspective expansion tiles are present", (
        tester,
      ) async {
        // Pumping the CAForm widget
        await pumpCAForm(tester);

        // One tile for the individual perspective, one for the group/team perspective
        expect(find.byType(ExpansionTile), findsNWidgets(2));
      });

      testWidgets("Individual and group tiles carry the correct heading text", (
        tester,
      ) async {
        // Pumping the CAForm widget
        await pumpCAForm(tester);

        // Acccessing the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedCAFormQuestions lfq = .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "level2TitleIndividual",
          expectedTexts: {"en":"As an individual:\nWhat problem\nam I trying to solve?", "fr":"En tant qu'individu:\nQuel problème\ndois-je résoudre ?"}, 
          onScreenValue: lfq.level2TitleIndividual,          
        );

        // Verifying that the first expansion tile title is correct
        var firstExpansionTileQuestionFinder = find
            .descendant(
              // first expansion tile
              of: find.byType(ExpansionTile).first,
              matching: find.byType(Text),
              // first Text widget out of 2
            )
            .first;
        Text firstExpansionTileTextWidget = tester.widget<Text>(
          firstExpansionTileQuestionFinder.first,
        );
        expect(firstExpansionTileTextWidget.data, lfq.level2TitleIndividual);

        // Verifying the correct string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "level2TitleGroup",
          expectedTexts: {"en":"As a member\nof groups/teams:\nWhat problem(s)\nare we trying to solve?", "fr":"En tant que membre\nde groupes/équipes:\nQuel(s) problème(s)\ndevons-nous résoudre ?"}, 
          onScreenValue: lfq.level2TitleGroup,          
        );

        // Verifying that the second expansion tile title is correct
        var secondExpansionTileQuestionFinder = find
            .descendant(
              // second expansion tile
              of: find.byType(ExpansionTile).last,
              matching: find.byType(Text),
              // first Text widget out of 2
            )
            .first;
        Text secondExpansionTileTextWidget = tester.widget<Text>(
          secondExpansionTileQuestionFinder.first,
        );
        expect(secondExpansionTileTextWidget.data, lfq.level2TitleGroup);
        
      });

      testWidgets("Individual and group tiles carry the correct sub-text", (
        tester,
      ) async {
        // Pumping the CAForm widget
        await pumpCAForm(tester);

        // Acccessing the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedCAOtherStrings los= .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "invitationToUnfoldExpansionTile",
          expectedTexts: {"en":"Please click to toggle", "fr":"Veuillez cliquer pour commencer"}, 
          onScreenValue: los.invitationToUnfoldExpansionTile,          
        );   

        // Verifying that the first expansion tile subtext is correct
        var firstUnfoldedExpansionTileSubTextFinder = find
            .descendant(
              // first expansion tile
              of: find.byType(ExpansionTile).first,
              matching: find.byType(Text),
              // second Text widget out of 2
            )
            .last;
        Text firstUnfoldedExpansionTileSubTextWidget = tester.widget<Text>(
          firstUnfoldedExpansionTileSubTextFinder,
        );



        // Verifying the first subtext correct
        expect(
          firstUnfoldedExpansionTileSubTextWidget.data,
          los.invitationToUnfoldExpansionTile,
        );

        // Verifying that the second expansion tile subtext is correct
        var secondUnfoldedExpansionTileSubTextFinder = find
            .descendant(
              // second expansion tile
              of: find.byType(ExpansionTile).last,
              matching: find.byType(Text),
              // second Text widget out of 2
            )
            .last;
        Text secondUnfoldedExpansionTileSubTextWidget = tester.widget<Text>(
          secondUnfoldedExpansionTileSubTextFinder,
        );

        // Verifying the second sub-text correct
        expect(
          secondUnfoldedExpansionTileSubTextWidget.data,
          los.invitationToUnfoldExpansionTile,
        );
      });
    });

    // ─── INDIVIDUAL PERSPECTIVE ───────────────────────────────────────
    group("Form: Structure: Individual perspective: \n", () {
      testWidgets(
        "Expanding the tile with the individual perspective reveals the four correct level-3 section questions",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Getting the localized strings
          final context = tester.element(find.byType(Scaffold));
          LocalizedCAFormQuestions lfq = .new(context);

          // Opening the individual perspective expansion tile
          await caOpenIndividualExpansionTile(context, tester);

          // Searching the custom headings texts for the first expansion tile
          var customHeadingTextsFinders = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.descendant(
              of: find.byType(CustomHeading),
              matching: find.byType(Text),
            ),
          );

          // Verifying the correct localized strings present
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "individualPerspectiveBalanceIssue",
            expectedTexts: {"en":"A Balance Issue?", "fr":"Un problème d'équilibre ?"}, 
            onScreenValue: lfq.level3TitleBalanceIssue,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "individualPerspectiveWorkplaceIssue",
            expectedTexts: {"en":"A Workplace Issue?", "fr":"Un problème au travail ?"}, 
            onScreenValue: lfq.level3TitleWorkplaceIssue,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "individualPerspectiveLegacyIssue",
            expectedTexts: {"en":"A Legacy Issue?", "fr":"Un problème\navec mon histoire de vie ?"}, 
            onScreenValue: lfq.level3TitleLegacyIssue,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "individualPerspectiveAnotherIssue",
            expectedTexts: {"en":"Is the issue\nof another type?", "fr":"Est-ce un autre type\nde problème ?"}, 
            onScreenValue: lfq.level3TitleAnotherIssue,          
          );
 
          // Verifying the level 3 titles present (skipping los.invitationToUnfoldExpansionTile)
          expect(
            tester.widget<Text>(customHeadingTextsFinders.at(2)).data,
            lfq.level3TitleBalanceIssue,
          );
          expect(
            tester.widget<Text>(customHeadingTextsFinders.at(3)).data,
            lfq.level3TitleWorkplaceIssue,
          );
          expect(
            tester.widget<Text>(customHeadingTextsFinders.at(4)).data,
            lfq.level3TitleLegacyIssue,
          );
          expect(
            tester.widget<Text>(customHeadingTextsFinders.at(5)).data,
            lfq.level3TitleAnotherIssue,
          );
        },
      );

      testWidgets(
        "Expanding the tile with the individual perspective reveals the correct total number of checkbox items: \n"
        "4 balance + 2 workplace + 1 legacy = 7",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the individual perspective expansion tile
          // Getting the build context
          final context = tester.element(find.byType(Scaffold));
          await caOpenIndividualExpansionTile(context, tester);

          // Getting the first expansion tile
          var individualExpansionTileFinder = find.byType(ExpansionTile).first;

          // Searching 7 custom checkbox widgets
          expect(
            find.descendant(
              of: individualExpansionTileFinder,
              matching: find.byType(CACheckboxWithSanitizedAndPaddedTextField),
            ),
            findsNWidgets(7),
          );
        },
      );

      testWidgets(
        "Expanding the tile with the individual perspective reveals the correct total number of text field only items: \n"
        "Issue of another type = 1",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the individual perspective expansion tile
          // Getting the build context
          final context = tester.element(find.byType(Scaffold));
          await caOpenIndividualExpansionTile(context, tester);

          // Getting the first expansion tile
          var individualExpansionTileFinder = find.byType(ExpansionTile).first;

          // Searching 1 custom text field widget
          expect(
            find.descendant(
              of: individualExpansionTileFinder,
              matching: find.byType(CATextFieldSanitizedAndPadded),
            ),
            findsNWidgets(1),
          );
        },
      );

      // ─── INDIVIDUAL PERSPECTIVE: BALANCE SECTION ───────────────────────────────────────
      testWidgets(
        "Balance issue: all four item labels are correct and present after expansion",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the individual perspective expansion tile
          // Getting the build context
          final context = tester.element(find.byType(Scaffold));
          await caOpenIndividualExpansionTile(context, tester);

          // Searching the Text widgets for the first expansion tile
          var textsFinder = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Text),
          );

          // Getting the localized strings
          LocalizedCAFormQuestions lfq = .new(context);

          // Verifying the correct localized strings present
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "level3TitleBalanceIssueItem1",
            expectedTexts: {"en":"To balance studies and household life?", "fr":"Équilibre entre les études et la vie de famille ?"}, 
            onScreenValue: lfq.level3TitleBalanceIssueItem1,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "level3TitleBalanceIssueItem2",
            expectedTexts: {"en":"To balance accessing income and household life?", "fr":"Équilibre entre l'accès à l'emploi et la vie de famille ?"}, 
            onScreenValue: lfq.level3TitleBalanceIssueItem2,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "level3TitleBalanceIssueItem3",
            expectedTexts: {"en":"To balance earning an income and household life?", "fr":"Équilibre entre maintenir un revenu et la vie de famille ?"}, 
            onScreenValue: lfq.level3TitleBalanceIssueItem3,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "level3TitleBalanceIssueItem4",
            expectedTexts: {"en":"To balance helping others and household life?", "fr":"Équilibre entre aider les autres et la vie de famille ?"}, 
            onScreenValue: lfq.level3TitleBalanceIssueItem4,          
          );


          // Verifying the level 3 items present
          expect(
            tester.widget<Text>(textsFinder.at(3)).data,
            lfq.level3TitleBalanceIssueItem1,
          );
          expect(
            tester.widget<Text>(textsFinder.at(4)).data,
            lfq.level3TitleBalanceIssueItem2,
          );
          expect(
            tester.widget<Text>(textsFinder.at(5)).data,
            lfq.level3TitleBalanceIssueItem3,
          );
          expect(
            tester.widget<Text>(textsFinder.at(6)).data,
            lfq.level3TitleBalanceIssueItem4,
          );
        },
      );

      // ─── INDIVIDUAL PERSPECTIVE: WORKPLACE SECTION ───────────────────────────────────────
      testWidgets(
        "Workplace issue: both item labels are correct and present after expansion",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the individual perspective expansion tile
          // Getting the build context
          final context = tester.element(find.byType(Scaffold));
          await caOpenIndividualExpansionTile(context, tester);

          // Searching the Text widgets for the first expansion tile
          var textFinders = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Text),
          );

          // Getting the localized strings
          LocalizedCAFormQuestions lfq = .new(context);

          // Verifying the correct localized strings present
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "level3TitleWorkplaceIssueItem1",
            expectedTexts: {"en":"To solve a need to be more appreciated at work?", "fr":"Le besoin d'être plus apprécié(e) au travail ?"}, 
            onScreenValue: lfq.level3TitleWorkplaceIssueItem1,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "level3TitleWorkplaceIssueItem2",
            expectedTexts: {"en":"To solve a need to remain appreciated at work?", "fr":"Le besoin de rester apprécié(e) au travail ?"}, 
            onScreenValue: lfq.level3TitleWorkplaceIssueItem2,          
          );

          // Verifying the level 3 items present
          expect(
            tester.widget<Text>(textFinders.at(8)).data,
            lfq.level3TitleWorkplaceIssueItem1,
          );
          expect(
            tester.widget<Text>(textFinders.at(9)).data,
            lfq.level3TitleWorkplaceIssueItem2,
          );
        },
      );

      // ─── INDIVIDUAL PERSPECTIVE: LEGACY SECTION ───────────────────────────────────────
      testWidgets(
        "Legacy issue: the item label is correct and present after expansion",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the individual perspective expansion tile
          // Getting the build context
          final context = tester.element(find.byType(Scaffold));
          await caOpenIndividualExpansionTile(context, tester);

          // Searching the Text widgets for the first expansion tile
          var textFinders = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Text),
          );

          // Getting the localized strings
          LocalizedCAFormQuestions lfq = .new(context);

          // Verifying the correct localized string present
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "level3TitleLegacyIssueItem1",
            expectedTexts: {"en":"To have a better legacy to leave to my children/others?", "fr":"Avoir une histoire de vie de meilleure qualité à laisser à mes enfants/aux autres ?"}, 
            onScreenValue: lfq.level3TitleLegacyIssueItem1,          
          );

          // Verifying the level 3 item present
          expect(
            tester.widget<Text>(textFinders.at(11)).data,
            lfq.level3TitleLegacyIssueItem1,
          );
        },
      );

      // ─── INDIVIDUAL PERSPECTIVE: ANOTHER ISSUE SECTION ───────────────────────────────────────
      testWidgets(
        "Another issue: the hint text is correct and present after expansion",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Getting the localized strings
          final context = tester.element(find.byType(Scaffold));
          LocalizedCAOtherStrings los= .new(context);

          // Opening the individual perspective expansion tile
          await caOpenIndividualExpansionTile(context, tester);

          // Searching the Text widgets for the first expansion tile
          var textFinders = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Text),
          );


          // Verifying the correct localized string present
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "caFormPleaseDevelopTextFieldHint",
            expectedTexts: {"en":"Please develop.", "fr":"Veuillez développer."}, 
            onScreenValue: los.caFormPleaseDevelopTextFieldHint,          
          );

          // Verifying text hint text present
          expect(
            tester.widget<Text>(textFinders.at(13)).data,
            los.caFormPleaseDevelopTextFieldHint,
          );
        },
      );

      // ─── INDIVIDUAL PERSPECTIVE: HINT TEXTS ───────────────────────────────────────
      testWidgets(
        "Individual perspective: Checkboxes with text fields: the hint texts are correct and present after expansion",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Getting the localized strings
          final context = tester.element(find.byType(Scaffold));
          LocalizedCAOtherStrings los= .new(context);

          // Opening the individual perspective expansion tile
          await caOpenIndividualExpansionTile(context, tester);

          // Checking all checkboxes
          var checkboxesFinder = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Checkbox),
            skipOffstage: false,
          );

          var totalCheckboxesFinders = checkboxesFinder.evaluate().length;
          logt("totalCheckboxesFinders", totalCheckboxesFinders);
          for (var i = 0; i < checkboxesFinder.evaluate().length; i++) {
            await tester.scrollUntilVisible(
              checkboxesFinder.at(i),
              45,
              scrollable: find
                  .descendant(
                    of: find.byKey(
                      const Key("context-analysis-process-scrollview"),
                    ),
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            // pumpAndSettle timed out
            await tester.pump(const Duration(seconds: 2));
            await tester.tap(checkboxesFinder.at(i));
            await tester.pump(const Duration(seconds: 2));
          }

          // Searching the Text widgets for the first expansion tile
          var textFinders = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Text),
            skipOffstage: false,
          );

          var totalTextFinders = textFinders.evaluate().length;
          logt("totalTextFinders", totalTextFinders);

          // Verifying the correct localized strings present
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "pastOutcomesHouseholdTextFieldHint",
            expectedTexts: {"en":"Please describe the past outcomes of the problem for the household, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the household.", "fr":"Veuillez décrire les conséquences du problème, si des membres du foyer ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable aux membres du foyer."}, 
            onScreenValue: los.pastOutcomesHouseholdTextFieldHint,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "pastOutcomesWorkplaceTextFieldHint",
            expectedTexts: {"en":"Please describe the past outcomes of the problem for the workplace, if some seem to have been out of their comfort zone for too long, and the more desirable outcomes for the workplace and for the household. Please identify any competence or efficiency issues.", "fr":"Veuillez décrire les conséquences du problème, si des membres du lieu de travail ont été en dehors de leur zone de confort pendant trop longtemps, et une situation de vie qui serait plus favorable aux collègues du lieu de travail et aux membres du foyer. Veuillez identifier les problèmes de compétence et d'efficacité."}, 
            onScreenValue: los.pastOutcomesWorkplaceTextFieldHint,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "helpingAndHouseholdTextFieldHint",
            expectedTexts: {"en":"Please develop the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others.", "fr":"Veuillez développer les raisons, et les impacts potentiels, d'un déséquilibre entre fidélité envers votre famille et considération envers les autres."}, 
            onScreenValue: los.helpingAndHouseholdTextFieldHint,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "caFormPleaseDevelopTextFieldHint",
            expectedTexts: {"en":"Please develop.", "fr":"Veuillez développer."}, 
            onScreenValue: los.caFormPleaseDevelopTextFieldHint,          
          );

          // Verifying the hint texts present
          expect(
            tester.widget<Text>(textFinders.at(4)).data,
            los.pastOutcomesHouseholdTextFieldHint,
          );
          expect(
            tester.widget<Text>(textFinders.at(7)).data,
            los.pastOutcomesHouseholdTextFieldHint,
          );
          expect(
            tester.widget<Text>(textFinders.at(10)).data,
            los.pastOutcomesHouseholdTextFieldHint,
          );
          expect(
            tester.widget<Text>(textFinders.at(13)).data,
            los.helpingAndHouseholdTextFieldHint,
          );
          expect(
            tester.widget<Text>(textFinders.at(17)).data,
            los.pastOutcomesWorkplaceTextFieldHint,
          );
          expect(
            tester.widget<Text>(textFinders.at(20)).data,
            los.pastOutcomesWorkplaceTextFieldHint,
          );
          expect(
            tester.widget<Text>(textFinders.at(24)).data,
            los.caFormPleaseDevelopTextFieldHint,
          );
          expect(
            tester.widget<Text>(textFinders.at(27)).data,
            los.caFormPleaseDevelopTextFieldHint,
          );
        },
      );
    });

    // ─── GROUP/TEAMS PERSPECTIVE ───────────────────────────────────────
    group("Form: Structure: Group/Teams perspective: \n", () {
      testWidgets(
        "Expanding the tile with the group/teams perspective reveals the five correct level-3 section questions",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Acccessing the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedCAFormQuestions lfq = .new(context);

          // Opening the group/team perspective expansion tile
          await caOpenGroupExpansionTile(context, tester);

          // Searching the custom headings text for the second expansion tile
          var customHeadingTextsFinder = find.descendant(
            of: find.byType(ExpansionTile).last,
            matching: find.descendant(
              of: find.byType(CustomHeading),
              matching: find.byType(Text),
            ),
          );

          // Verifying the correct localized strings present
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "groupPerspectiveProblematics",
            expectedTexts: {"en":"What problem(s)\nare my groups/teams\ntrying to solve?", "fr":"Quel(s) problème(s)\nnos groupes/équipes\nessayent de résoudre ?"}, 
            onScreenValue: lfq.level3TitleGroupsProblematics,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "groupPerspectiveSameProblems",
            expectedTexts: {"en":"Am I trying to solve the same problem(s) as my groups/teams?", "fr":"Est-ce que j'essaie de résoudre les mêmes problèmes que mes groupes/équipes ?"}, 
            onScreenValue: lfq.level3TitleSameProblem,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "groupPerspectiveHarmonyHome",
            expectedTexts: {"en":"Is entering the group problem-solving process consistent with harmony at home?", "fr":"Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec l'harmonie dans le foyer ?"}, 
            onScreenValue: lfq.level3TitleHarmonyAtHome,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "groupPerspectiveAppreciabilityWork",
            expectedTexts: {"en":"Is entering the group problem-solving process consistent with appreciability at work?", "fr":"Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec rester apprécié(e) au travail ?"}, 
            onScreenValue: lfq.level3TitleAppreciabilityAtWork,          
          );
          verifyLocalizedStringAsExpected
          (
            tester: tester, 
            label: "groupPerspectiveEarningAbility",
            expectedTexts: {"en":"Is entering the group problem-solving process consistent with my income earning ability?", "fr":"Est-ce que participer à ce processus de résolution de problème en groupe est cohérent avec ma capacité à générer un revenu ?"}, 
            onScreenValue: lfq.level3TitleIncomeEarningAbility,          
          );

          // Verifying the level 3 titles present (skipping los.invitationToUnfoldExpansionTile)
          expect(
            tester.widget<Text>(customHeadingTextsFinder.at(2)).data,
            lfq.level3TitleGroupsProblematics,
          );
          expect(
            tester.widget<Text>(customHeadingTextsFinder.at(3)).data,
            lfq.level3TitleSameProblem,
          );
          expect(
            tester.widget<Text>(customHeadingTextsFinder.at(4)).data,
            lfq.level3TitleHarmonyAtHome,
          );
          expect(
            tester.widget<Text>(customHeadingTextsFinder.at(5)).data,
            lfq.level3TitleAppreciabilityAtWork,
          );
          expect(
            tester.widget<Text>(customHeadingTextsFinder.at(6)).data,
            lfq.level3TitleIncomeEarningAbility,
          );
        },
      );

      testWidgets(
        "Expanding the tile with the group/teams perspective reveals the correct total number of text field only items: \n"
        "Problems the groups/teams are trying to solve = 1",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the group/team perspective expansion tile
          var context = tester.element(find.byType(Scaffold));
          await caOpenGroupExpansionTile(context, tester);

          // Getting the second expansion tile
          var groupExpansionTileFinder = find.byType(ExpansionTile).last;

          // Searching 1 custom text field widget
          expect(
            find.descendant(
              of: groupExpansionTileFinder,
              matching: find.byType(CATextFieldSanitizedAndPadded),
            ),
            findsNWidgets(1),
          );
        },
      );

      testWidgets(
        "Expanding the tile with the group/teams perspective reveals the correct total number of segmented button items: \n"
        "4",
        (tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the group/team perspective expansion tile
          var context = tester.element(find.byType(Scaffold));
          await caOpenGroupExpansionTile(context, tester);

          // Getting the second expansion tile
          var groupExpansionTileFinder = find.byType(ExpansionTile).last;

          // Searching 4 custom segmented button widgets
          expect(
            find.descendant(
              of: groupExpansionTileFinder,
              matching: find.byType(
                CASegmentedButtonWithSanitizedAndPaddedTextField,
              ),
            ),
            findsNWidgets(4),
          );
        },
      );
    });

    group("Form: Start values: \n", () {
      testWidgets(
        "At start, when the tile with the individual perspective is unfolded, all checkboxes are unchecked",
        (WidgetTester tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the individual perspective expansion tile
          // Getting the build context
          final context = tester.element(find.byType(Scaffold));
          await caOpenIndividualExpansionTile(context, tester);

          // Searching the checkboxes present in the sub-tree
          var checkboxFinder = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Checkbox),
          );

          // Verifying all checkboxes unchecked
          for (var checkboxElement in checkboxFinder.evaluate()) {
            Checkbox checkboxWidget = checkboxElement.widget as Checkbox;
            expect(checkboxWidget.value, false);
          }
        },
      );

      testWidgets(
        "At start, when the tile with the group/teams perspective is unfolded, no selection is present in the segmented buttons",
        (WidgetTester tester) async {
          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Opening the group/teams perspective expansion tile
          var context = tester.element(find.byType(Scaffold));
          await caOpenGroupExpansionTile(context, tester);

          // Searching the segmented buttons present in the sub-tree
          var segButtonFinder = find.descendant(
            of: find.byType(ExpansionTile).last,
            matching: find.byType(SegmentedButton),
          );

          // Verifying all segmented buttons without selection
          for (var segButtonElement in segButtonFinder.evaluate()) {
            SegmentedButton segButtonWidget =
                segButtonElement.widget as SegmentedButton;
            expect(segButtonWidget.selected, {});
          }
        },
      );
    });

    group("Formatting: Individual perspective", () {
      testWidgets(
        "The balance section question is underlined if and only if an item of the section, at least, is checked, without impact on the other sections",
        (WidgetTester tester) async {
          bool isUnderlined = true;
          bool isNotUnderlined = false;

          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Acccessing the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedCAFormQuestions lfq = .new(context);

          // Expanding the expansion tile
          await caOpenIndividualExpansionTile(context, tester);

          // Searching for the Texts
          var indivTextsFinder = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Text),
            skipOffstage: false,
          );

          // ─── VERIFYING THE FORMATTING ───────────────────────────────────────

          // ─── 1. AT START ───────────────────────────────────────
          // Balance elements: title + items
          var listAllBalanceTextsNotUnderlined = List.filled(
            5,
            isNotUnderlined,
          );
          var listAllBalanceTextsValues = [];
          logt("Verifying all balance elements not underlined");
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 4,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 5,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );

          expect(listAllBalanceTextsValues, listAllBalanceTextsNotUnderlined);

          // Workplace elements: title + items
          var listAllWorkplaceTextsNotUnderlined = List.filled(
            3,
            isNotUnderlined,
          );
          var listAllWorkplaceTextsValues = [];
          logt("Verifying all workplace elements not underlined");
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );

          expect(
            listAllWorkplaceTextsValues,
            listAllWorkplaceTextsNotUnderlined,
          );

          // Legacy elements: title + items
          var listAllLegacyTextsNotUnderlined = List.filled(2, isNotUnderlined);
          var listAllLegacyTextsValues = [];
          logt("Verifying all legacy elements not underlined");
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );

          expect(listAllLegacyTextsValues, listAllLegacyTextsNotUnderlined);

          // ─── 2. FIRST BALANCE ITEM CHECKED ───────────────────────────────────────
          // Clicking on the first balance item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleBalanceIssueItem1,
          );
          // Verifying the formatting for the balance issue
          var expectedAllBalanceTextsFormatting = [
            isUnderlined,
            isUnderlined,
            ...List.filled(3, isNotUnderlined),
          ];
          listAllBalanceTextsValues = [];

          logt(
            "\n\nVerifying the balance section question and the first checkbox checked",
          );

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          // hint text + extra text
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          expect(listAllBalanceTextsValues, expectedAllBalanceTextsFormatting);

          // SEARCHING FOR SIDE EFFECTS ON THE WORKPLACE AND LEGACY PARTS
          // Verifying the formatting for the workplace issue
          var expectedAllWorkplaceTextsFormatting = List.filled(
            3,
            isNotUnderlined,
          );
          listAllWorkplaceTextsValues = [];

          logt("Verifying all workplace elements not underlined");

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );
          expect(
            listAllWorkplaceTextsValues,
            expectedAllWorkplaceTextsFormatting,
          );

          // Verifying the formatting for the legacy issue
          var expectedAllLegacyTextsFormatting = List.filled(
            2,
            isNotUnderlined,
          );
          listAllLegacyTextsValues = [];

          logt("Verifying all legacy elements not underlined");

          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 12,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 13,
            ),
          );

          expect(listAllLegacyTextsValues, expectedAllLegacyTextsFormatting);

          // ─── 3. SECOND BALANCE ITEM CHECKED ───────────────────────────────────────

          // Clicking on the second balance item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleBalanceIssueItem2,
          );
          // Verifying the formatting
          expectedAllBalanceTextsFormatting = [
            isUnderlined,
            isUnderlined,
            isUnderlined,
            ...List.filled(2, isNotUnderlined),
          ];
          listAllBalanceTextsValues = [];

          logt(
            "\n\nVerifying the section question, the first and second checkbox checked",
          );

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          // hint text + extra text
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );
          // hint text + extra text
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          expect(listAllBalanceTextsValues, expectedAllBalanceTextsFormatting);

          // ─── 4. SECOND BALANCE ITEM UNCHECKED ───────────────────────────────────────
          // Re-clicking on the second balance item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleBalanceIssueItem2,
          );
          // Verifying the formatting
          expectedAllBalanceTextsFormatting = [
            isUnderlined,
            isUnderlined,
            ...List.filled(3, isNotUnderlined),
          ];
          listAllBalanceTextsValues = [];

          logt(
            "\n\nVerifying the section question, the first checkbox checked",
          );

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          // hint text + extra text
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          expect(listAllBalanceTextsValues, expectedAllBalanceTextsFormatting);

          // ─── 5. FIRST BALANCE ITEM UNCHECKED ───────────────────────────────────────
          // Re-clicking on the first balance item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleBalanceIssueItem1,
          );
          // Verifying the formatting
          expectedAllBalanceTextsFormatting = [
            isUnderlined,
            isUnderlined,
            ...List.filled(3, isNotUnderlined),
          ];
          listAllBalanceTextsValues = [];

          logt("\n\nVerifying all sections elements unchecked");

          // Balance elements: title + items
          listAllBalanceTextsNotUnderlined = List.filled(5, isNotUnderlined);
          listAllBalanceTextsValues = [];

          logt("Verifying all balance elements not underlined");

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 4,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 5,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );

          expect(listAllBalanceTextsValues, listAllBalanceTextsNotUnderlined);

          // Workplace elements: title + items
          listAllWorkplaceTextsNotUnderlined = List.filled(3, isNotUnderlined);
          listAllWorkplaceTextsValues = [];

          logt("Verifying all workplace elements not underlined");

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );

          expect(
            listAllWorkplaceTextsValues,
            listAllWorkplaceTextsNotUnderlined,
          );

          // Legacy elements: title + items
          listAllLegacyTextsNotUnderlined = List.filled(2, isNotUnderlined);
          listAllLegacyTextsValues = [];

          logt("Verifying all legacy elements not underlined");

          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );

          expect(listAllLegacyTextsValues, listAllLegacyTextsNotUnderlined);
        },
      );

      testWidgets(
        "The workplace section question is underlined if and only if an item of the section, at least, is checked, without impact on the other sections",
        (WidgetTester tester) async {
          bool isUnderlined = true;
          bool isNotUnderlined = false;

          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Acccessing the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedCAFormQuestions lfq = .new(context);

          // Expanding the expansion tile
          await caOpenIndividualExpansionTile(context, tester);

          // Searching for the Texts
          var indivTextsFinder = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Text),
            skipOffstage: false,
          );

          // ─── VERIFYING THE FORMATTING ───────────────────────────────────────

          // ─── 1. AT START ───────────────────────────────────────
          // Balance elements: title + items
          var listAllBalanceTextsNotUnderlined = List.filled(
            5,
            isNotUnderlined,
          );
          var listAllBalanceTextsValues = [];

          logt("Verifying all balance elements not underlined");

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 4,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 5,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );

          expect(listAllBalanceTextsValues, listAllBalanceTextsNotUnderlined);

          // Workplace elements: title + items
          var listAllWorkplaceTextsNotUnderlined = List.filled(
            3,
            isNotUnderlined,
          );
          var listAllWorkplaceTextsValues = [];

          logt("Verifying all workplace elements not underlined");

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );

          expect(
            listAllWorkplaceTextsValues,
            listAllWorkplaceTextsNotUnderlined,
          );

          // Legacy elements: title + items
          var listAllLegacyTextsNotUnderlined = List.filled(2, isNotUnderlined);
          var listAllLegacyTextsValues = [];

          logt("Verifying all legacy elements not underlined");

          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );

          expect(listAllLegacyTextsValues, listAllLegacyTextsNotUnderlined);

          // ─── 2. FIRST WORKPLACE ITEM CHECKED ───────────────────────────────────────

          // Clicking on the first workplace item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleWorkplaceIssueItem1,
          );
          // Verifying the formatting for the workplace issue
          var expectedAllWorkplaceTextsFormatting = [
            isUnderlined,
            isUnderlined,
            isNotUnderlined,
          ];
          listAllWorkplaceTextsValues = [];

          logt(
            "\n\nVerifying the workplace section question and the first checkbox checked",
          );

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          // hint text + extra text
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );
          expect(
            listAllWorkplaceTextsValues,
            expectedAllWorkplaceTextsFormatting,
          );

          // SEARCHING FOR SIDE EFFECTS ON THE BALANCE AND LEGACY PARTS
          // Verifying the formatting for the balance issue
          var expectedAllBalanceTextsFormatting = List.filled(
            5,
            isNotUnderlined,
          );
          listAllBalanceTextsValues = [];

          logt("Verifying all balance elements not underlined");

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 4,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 5,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );
          expect(listAllBalanceTextsValues, expectedAllBalanceTextsFormatting);

          // Verifying the formatting for the legacy issue
          var expectedAllLegacyTextsFormatting = List.filled(
            2,
            isNotUnderlined,
          );
          listAllLegacyTextsValues = [];

          logt("Verifying all legacy elements not underlined");

          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 12,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 13,
            ),
          );

          expect(listAllLegacyTextsValues, expectedAllLegacyTextsFormatting);

          // ─── 3. SECOND WORKPLACE ITEM CHECKED ───────────────────────────────────────
          // Clicking on the second workplace item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleWorkplaceIssueItem2,
          );
          // Verifying the formatting
          expectedAllWorkplaceTextsFormatting = [
            isUnderlined,
            isUnderlined,
            isUnderlined,
          ];
          listAllWorkplaceTextsValues = [];

          logt(
            "\n\nVerifying the section question, the first and second checkbox checked",
          );

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          // hint text + extra text
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );

          expect(listAllBalanceTextsValues, expectedAllBalanceTextsFormatting);

          // ─── 4. SECOND WORKPLACE ITEM UNCHECKED ───────────────────────────────────────
          // Re-clicking on the second workplace item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleWorkplaceIssueItem2,
          );
          // Verifying the formatting
          expectedAllWorkplaceTextsFormatting = [
            isUnderlined,
            isUnderlined,
            isNotUnderlined,
          ];
          listAllWorkplaceTextsValues = [];

          logt(
            "\n\nVerifying the section question, the first checkbox checked",
          );

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          // hint text + extra text
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );

          expect(
            listAllWorkplaceTextsValues,
            expectedAllWorkplaceTextsFormatting,
          );

          // ─── 5. FIRST WORKPLACE ITEM UNCHECKED ───────────────────────────────────────
          // Re-clicking on the first workplace item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleWorkplaceIssueItem1,
          );
          // Verifying the formatting
          expectedAllWorkplaceTextsFormatting = List.filled(3, isNotUnderlined);
          listAllWorkplaceTextsValues = [];

          logt("\n\nVerifying all workplace elements not underlined");

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );

          expect(
            listAllWorkplaceTextsValues,
            expectedAllWorkplaceTextsFormatting,
          );

          // Balance elements: title + items
          listAllBalanceTextsNotUnderlined = List.filled(5, isNotUnderlined);
          listAllBalanceTextsValues = [];

          logt("Verifying all balance elements not underlined");

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 4,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 5,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );

          expect(listAllBalanceTextsValues, listAllBalanceTextsNotUnderlined);

          // Legacy elements: title + items
          listAllLegacyTextsNotUnderlined = List.filled(2, isNotUnderlined);
          listAllLegacyTextsValues = [];

          logt("Verifying all legacy elements not underlined");

          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );

          expect(listAllLegacyTextsValues, listAllLegacyTextsNotUnderlined);
        },
      );

      testWidgets(
        "The legacy section question is underlined if and only if an item of the section, at least, is checked, without impact on the other sections",
        (WidgetTester tester) async {
          bool isUnderlined = true;
          bool isNotUnderlined = false;

          // Pumping the widget within the CA process to allow for the tile expansion
          await pumpCAProcess(tester);

          // Acccessing the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedCAFormQuestions lfq = .new(context);

          // Expanding the expansion tile
          await caOpenIndividualExpansionTile(context, tester);

          // Searching for the Texts
          var indivTextsFinder = find.descendant(
            of: find.byType(ExpansionTile).first,
            matching: find.byType(Text),
            skipOffstage: false,
          );

          // ─── VERIFYING THE FORMATTING ───────────────────────────────────────

          // ─── 1. AT START ───────────────────────────────────────
          // Balance elements: title + items
          var listAllBalanceTextsNotUnderlined = List.filled(
            5,
            isNotUnderlined,
          );
          var listAllBalanceTextsValues = [];

          logt("Verifying all balance elements not underlined");

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 4,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 5,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );

          expect(listAllBalanceTextsValues, listAllBalanceTextsNotUnderlined);

          // Workplace elements: title + items
          var listAllWorkplaceTextsNotUnderlined = List.filled(
            3,
            isNotUnderlined,
          );
          var listAllWorkplaceTextsValues = [];

          logt("Verifying all workplace elements not underlined");

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );

          expect(
            listAllWorkplaceTextsValues,
            listAllWorkplaceTextsNotUnderlined,
          );

          // Legacy elements: title + items
          var listAllLegacyTextsNotUnderlined = List.filled(2, isNotUnderlined);
          var listAllLegacyTextsValues = [];

          logt("Verifying all legacy elements not underlined");

          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );

          expect(listAllLegacyTextsValues, listAllLegacyTextsNotUnderlined);

          // ─── 2. LEGACY ITEM CHECKED ───────────────────────────────────────
          // Clicking on the first legacy item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleLegacyIssueItem1,
          );
          // Verifying the formatting for the legacy issue
          var expectedAllLegacyTextsFormatting = [isUnderlined, isUnderlined];
          listAllLegacyTextsValues = [];

          logt(
            "\n\nVerifying the legacy section question and the first checkbox checked",
          );

          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );
          expect(listAllLegacyTextsValues, expectedAllLegacyTextsFormatting);

          // SEARCHING FOR SIDE EFFECTS ON THE BALANCE AND WORKPLACE PARTS
          // Verifying the formatting for the balance issue
          var expectedAllBalanceTextsFormatting = List.filled(
            5,
            isNotUnderlined,
          );
          listAllBalanceTextsValues = [];

          logt("Verifying all balance elements not underlined");

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 4,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 5,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );
          expect(listAllBalanceTextsValues, expectedAllBalanceTextsFormatting);

          // Verifying the formatting for the workplace issue
          var expectedAllWorkplaceTextsFormatting = List.filled(
            3,
            isNotUnderlined,
          );
          listAllWorkplaceTextsValues = [];

          logt("Verifying all workplace elements not underlined");

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );
          expect(
            listAllWorkplaceTextsValues,
            expectedAllWorkplaceTextsFormatting,
          );

          // ─── 3. FIRST LEGACY ITEM UNCHECKED ───────────────────────────────────────
          // Re-clicking on the first legacy item and verifying the new values
          await caCheckboxChangeValue(
            tester: tester,
            checkboxText: lfq.level3TitleLegacyIssueItem1,
          );
          // Verifying the formatting
          expectedAllLegacyTextsFormatting = List.filled(2, isNotUnderlined);
          listAllLegacyTextsValues = [];

          logt("\n\nVerifying all legacy elements not underlined");

          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 10,
            ),
          );
          listAllLegacyTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 11,
            ),
          );

          expect(listAllLegacyTextsValues, expectedAllLegacyTextsFormatting);

          // Balance elements: title + items
          listAllBalanceTextsNotUnderlined = List.filled(5, isNotUnderlined);
          listAllBalanceTextsValues = [];

          logt("Verifying all balance elements not underlined");

          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 2,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 3,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 4,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 5,
            ),
          );
          listAllBalanceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 6,
            ),
          );

          expect(listAllBalanceTextsValues, listAllBalanceTextsNotUnderlined);

          // Workplace elements: title + items
          listAllWorkplaceTextsNotUnderlined = List.filled(3, isNotUnderlined);
          listAllWorkplaceTextsValues = [];

          logt("Verifying all workplace elements not underlined");

          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 7,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 8,
            ),
          );
          listAllWorkplaceTextsValues.add(
            caIsCheckboxTextUnderlined(
              tester: tester,
              textsFinder: indivTextsFinder,
              checkboxIndex: 9,
            ),
          );

          expect(
            listAllWorkplaceTextsValues,
            listAllWorkplaceTextsNotUnderlined,
          );
        },
      );
    });
  });
}
