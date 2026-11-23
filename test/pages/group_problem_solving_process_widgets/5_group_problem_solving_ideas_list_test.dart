// ignore: file_names
import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/5_group_problem_solving_ideas_list.dart";
import "package:journeyers/utils/generic/testing/test_utils.dart";

import "../../_widget_testing_utils/widget_testing_utils.dart";

void main() {
  Future<void> pumpGPSIdeasList(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(testingLocaleOption),
        home: Scaffold(body: GPSIdeasList(ideas: [])),
      ),
    );
  }

  group("GPSIdeasList Tests: \n", () {
    group("GPSIdeasList default aspect: \n", () {
      testWidgets("The correct title is present", (WidgetTester tester) async {
        // Pumping the widget
        await pumpGPSIdeasList(tester);
        await tester.pumpAndSettle();

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "ideasListTitle",
          expectedTexts: {"en":"List of ideas", "fr":"Liste des idées"}, 
          onScreenValue: lgps.ideasListTitle,          
        );

        // Verifying the ideasListTitle present
        expect(find.text(lgps.ideasListTitle), findsOne);
      });

      testWidgets("The correct placeholder is present", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSIdeasList(tester);

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings? lgps = .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "ideasListPlaceholder",
          expectedTexts: {"en":"No ideas added yet.", "fr":"Liste d'idées vide"}, 
          onScreenValue: lgps.ideasListPlaceholder,          
        );
                
        // Verifying the placeholder present
        expect(find.text(lgps.ideasListPlaceholder), findsOne);
      });
    });

    group("GPSIdeasList overlay default aspect: \n", () {
      testWidgets("The correct appbar title is present", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSIdeasList(tester);
        await tester.pumpAndSettle();

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Tapping on the title
        await tester.tap(find.text(lgps.ideasListTitle));
        await tester.pumpAndSettle();

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "ideasListAppBarTitle",
          expectedTexts: {"en":"List of ideas", "fr":"Liste des idées"}, 
          onScreenValue: lgps.ideasListAppBarTitle,          
        );

        // Verifying the ideasListAppBarTitle present
        expect(find.text(lgps.ideasListAppBarTitle), findsNWidgets(2));
      });

      testWidgets(
        "The correct appbar foreground color is present",

        /// "[foregroundColor], which specifies the color for icons and text within
        ///  the app bar."
        (WidgetTester tester) async {
          // Pumping the widget
          await pumpGPSIdeasList(tester);
          await tester.pumpAndSettle();

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);

          // Tapping on the title
          await tester.tap(find.text(lgps.ideasListTitle));
          await tester.pumpAndSettle();

          // Verifying the color
          var iconButtonsFinder = find.byType(IconButton);
          var iconButtonWidget = tester.widget<IconButton>(
            iconButtonsFinder.last,
          );
          expect(iconButtonWidget.color, appBarWhite);
        },
      );

      testWidgets("The correct text field placeholder is present", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSIdeasList(tester);
        await tester.pumpAndSettle();

        // Accessing the localized data
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Tapping on the title
        await tester.tap(find.text(lgps.ideasListTitle));
        await tester.pumpAndSettle();

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
