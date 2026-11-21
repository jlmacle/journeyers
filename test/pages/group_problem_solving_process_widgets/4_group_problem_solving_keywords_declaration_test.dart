// ignore: file_names
import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/app_themes.dart";
import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_dashboard_strings.dart";
import "package:journeyers/l10n/localized_gps_strings.dart";
import "package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/4_group_problem_solving_keywords_declaration.dart";
import "package:journeyers/utils/generic/testing/test_utils.dart";


void main() {
  Future<void> pumpGPSKeywordsDeclaration(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale(testingLocaleOption),
        home: Scaffold(
          body: GPSKeywordsDeclaration(
            currentKeywords: const {},
            onKeywordsUpdatedCallbackFunction: (_) {},
          ),
        ),
      ),
    );
  }

  group("GPSKeywordsDeclaration Tests: \n", () {
    group("GPSKeywordsDeclaration default aspect: \n", () {
      testWidgets("The correct title is present", (WidgetTester tester) async {
        // Pumping the widget
        await pumpGPSKeywordsDeclaration(tester);

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "keywordsTitle",
          expectedTexts: {"en":"Keywords", "fr":"Mots-clés"}, 
          onScreenValue: lgps.gpsKeywordsTitle,          
        );

        // Verifying the title present
        expect(find.text(lgps.gpsKeywordsTitle), findsOne);
      });

      testWidgets("The correct appbar title is present", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSKeywordsDeclaration(tester);
        await tester.pumpAndSettle();

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "keywordsAppBarTitle",
          expectedTexts: {"en":"Keywords for the\nproblem-solving session", "fr":"Mots-clés pour la\nsession de résolution du problème"}, 
          onScreenValue: lgps.gpsKeywordsOverlayAppbarTitle,          
        );

        // Tapping to open the overlay
        var keywordsTitleFinder = find.text(lgps.gpsKeywordsTitle);
        await tester.tap(keywordsTitleFinder);
        await tester.pumpAndSettle();

        // Verifying the appbar title present
        expect(find.text(lgps.gpsKeywordsOverlayAppbarTitle), findsOne);
      });

      testWidgets("The correct text hint is present", (
        WidgetTester tester,
      ) async {
        // Pumping the widget
        await pumpGPSKeywordsDeclaration(tester);
        await tester.pumpAndSettle();

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedGPSStrings lgps = .new(context);
        LocalizedDashboardStrings lds = .new(context);

        // Tapping to open the overlay
        var keywordsTitleFinder = find.text(lgps.gpsKeywordsTitle);
        await tester.tap(keywordsTitleFinder);
        await tester.pumpAndSettle();

        // Verifying the correct localized string present
        verifyLocalizedStringAsExpected
        (
          tester: tester, 
          label: "hintText",
          expectedTexts: {"en":"Please enter one keyword at a time\n(+ Enter key).", "fr":"Veuillez renseigner un mot-clé à la fois\n(+ Touche Entrée)."}, 
          onScreenValue: lds.keywordsEntryTextFieldHint,          
        );

        // Verifying the text field hint present
        expect(find.text(lds.keywordsEntryTextFieldHint), findsOneWidget);
      });

      testWidgets(
        "The correct appbar foreground color is present",

        /// "[foregroundColor], which specifies the color for icons and text within
        ///  the app bar."
        (WidgetTester tester) async {
          // Pumping the widget
          await pumpGPSKeywordsDeclaration(tester);
          await tester.pumpAndSettle();

          // Getting the localized strings
          var context = tester.element(find.byType(Scaffold).first);
          LocalizedGPSStrings lgps = .new(context);

          // Tapping to open the overlay
          var keywordsTitleFinder = find.text(lgps.gpsKeywordsTitle);
          await tester.tap(keywordsTitleFinder);
          await tester.pumpAndSettle();

          // Verifying the color
          var iconButtonsFinder = find.byType(IconButton);
          var iconButtonWidget = tester.widget<IconButton>(
            iconButtonsFinder.last,
          );
          expect(iconButtonWidget.color, appBarWhite);
        },
      );

    });
  });
}
