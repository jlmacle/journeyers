// ignore: file_names

import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/1_group_problem_solving_problem_to_solve_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/3_group_problem_solving_checklist.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/6_group_problem_solving_new_idea.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/_group_problem_solving_externalized_variables.dart";
import "package:journeyers/utils/generic/testing/test_utils.dart";
import "package:journeyers/widgets/utility/process/session_file_name_on_mobile_platforms.dart";

import "../../_widget_testing_utils/widget_testing_utils.dart";

void main() {
  Future<void> pumpGPSProblemToSolveDeclaration(WidgetTester tester) async {
    var tfec = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(testingLocaleOption),
        home: Scaffold(
          body: GPSProblemToSolveDeclaration(
            sessionTitleTec: tfec,
            caPreviousSessions: const [],
            onTitleModified: () {},
            onSessionSelected: (_) {},
            onTitleTapped: () {},
            onTextFieldLosingFocus: () {},
          ),
        ),
      ),
    );
  }

  group("GPSProblemToSolveDeclaration Tests: \n", () {
    group("Default values: \n", () {
      testWidgets("Correct default title value", (WidgetTester tester) async {
        // Pumping the widget
        await pumpGPSProblemToSolveDeclaration(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          varName: "defaultTitle",
          expectedTexts: {"en":"Problem To Solve", "fr":"Problème à résoudre"}, 
          onScreenValue: lgps.gpsDefaultProcessSessionTitle,          
        );

       
      });

      testWidgets("Correct text field hint", (WidgetTester tester) async {
        // Pumping the widget
        await pumpGPSProblemToSolveDeclaration(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          varName: "defaultTextFieldHint",
          expectedTexts: {"en":"Please enter a title or select below.", "fr":"Veuillez entrer un titre ou en choisir un ci-dessous, si disponible."}, 
          onScreenValue: lgps.gpsProcessTitleTextFieldHint,          
        );        
      });
    });

    group("Click toward text field: \n", () {
      testWidgets("Clicking on the title reveals a text field", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSProblemToSolveDeclaration(tester);

        // Verifying the text field absent
        expect(find.byType(TextField), findsNothing);

        // Default title hard-coded strings
        var defaultTitle = "";

        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch (localeLanguageCode.toLowerCase()) {
          case ("en"):
            {
              defaultTitle = "Problem To Solve";
            }
          case ("fr"):
            {
              defaultTitle = "Problème à résoudre";
            }
        }

        logt("defaultTitle", defaultTitle);

        // Getting the default title finder
        var titleFinder = find.text(defaultTitle);

        // Clicking on the default title
        await tester.tap(titleFinder);
        await tester.pumpAndSettle();

        // Verifying the text field present
        expect(find.byType(TextField), findsOne);
      });

      testWidgets("Clicking on the edit emoji reveals a text field", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSProblemToSolveDeclaration(tester);

        // Verifying the text field absent
        expect(find.byType(TextField), findsNothing);

        // Getting the edit emoji
        var emojiFinder = find.text(editEmoji);

        // Clicking on the emoji
        await tester.tap(emojiFinder);
        await tester.pumpAndSettle();

        // Verifying the text field present
        expect(find.byType(TextField), findsOne);
      });
    });

    group("Display: \n", () {
      testWidgets("Clicking on the title removes all other widgets", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSProblemToSolveDeclaration(tester);

        // Default title hard-coded strings
        var defaultTitle = "";

        var localeLanguageCode = getLocaleLanguageCode(tester);

        switch (localeLanguageCode.toLowerCase()) {
          case ("en"):
            {
              defaultTitle = "Problem To Solve";
            }
          case ("fr"):
            {
              defaultTitle = "Problème à résoudre";
            }
        }

        logt("defaultTitle", defaultTitle);

        // Clicking on the default title
        var titleFinder = find.text(defaultTitle);
        await tester.tap(titleFinder);
        await tester.pumpAndSettle();

        // Verifying the other widgets absent
        expect(find.text(addEmoji), findsNothing);
        expect(find.byType(GPSChecklist), findsNothing);
        expect(find.text(editEmoji), findsNothing);
        expect(find.byType(GPSKeywordsDeclaration), findsNothing);
        expect(find.byType(GPSIdeasList), findsNothing);
        expect(find.byType(GPSNewIdea), findsNothing);
        expect(find.byType(SessionFileNameOnMobilePlatforms), findsNothing);
      });
    });
  });
}
