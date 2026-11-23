// ignore: file_names
import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/6_group_problem_solving_new_idea.dart";
import "package:journeyers/utils/generic/testing/test_utils.dart";

void main() {
  Future<void> pumpGPSNewIdea(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(testingLocaleOption),
        home: Scaffold(
          body: GPSNewIdea(newIdeaOnAddedCallbackFunction: (_) {}),
        ),
      ),
    );
  }

  group("GPSNewIdea Tests: \n", () {
    group("GPSNewIdea default aspect: \n", () {
      testWidgets("The correct hint text is present", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSNewIdea(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "newIdeaTextFieldHint",
          expectedTexts: {"en":"Please enter an idea.", "fr":"Veuillez entrer une idée."}, 
          onScreenValue: lgps.newIdeaTextFieldHint,          
        );
 
        // Verifying the newIdeaTextFieldHint present
        expect(find.text(lgps.newIdeaTextFieldHint), findsOne);
      });
    });
  });
}
