import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:journeyers/debug_constants.dart";
import "package:journeyers/l10n/app_localizations.dart";
import "package:journeyers/l10n/localized_dashboard_strings.dart";
import "package:journeyers/utils/generic/dashboard/dashboard_utils.dart";
import "package:journeyers/utils/generic/dev/test_externalized_strings.dart";
import "package:journeyers/widgets/utility/dashboard/dashboard_widgets/4_dashboard_sessions_list_item.dart";

void main() {

  var title = "Legacy";
  var date = "March 20, 2026 4:51 PM";
  var keywordsListKw1Kw2 = ["Kw", "Kw2"];

  // Data for the test
  final testMetadata = {
    DashboardUtils.keyTitle: title,
    DashboardUtils.keyDate: date,
    DashboardUtils.keyFilePath: pathForTestFile1,
    DashboardUtils.keyKeywords: keywordsListKw1Kw2,
  };

  group("SessionsListItem Tests: \n", () 
  {  
    group("Info and tooltips Tests: \n", () 
    { 
      // "Displays session info correctly (Title, date, keywords)"
      testWidgets("Displays session info correctly (Title, date, keywords)", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale(testingLocaleOption),
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition                               
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Verifies title
        expect(find.text(title), findsOneWidget);

        // Verifies date
        var dateFinder = find.byType(Text).at(1);
        Text dateWidget = tester.widget(dateFinder);
        expect(dateWidget.data, "($date)");
        
        // Verifies keywords
        expect(find.text("${lds.keywordsLabel} Kw, Kw2"), findsOneWidget);
      });

      // "Finds the preview tooltip label"
      testWidgets("Finds the preview tooltip label", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Verifies preview tooltip present
        expect(find.byTooltip(lds.previewTooltipLabel), findsOneWidget);      
      });

      // "Finds the edit tooltip label"
      testWidgets("Finds the edit tooltip label", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition                                        
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Verifies edit tooltip present
        expect(find.byTooltip(lds.editFromDashboardItemTooltipLabel), findsOneWidget);      
      });

      // "Finds the keywords tooltip label"
      testWidgets("Finds the keywords tooltip label", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition                                       
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Verifies keywords tooltip present
        expect(find.byTooltip(lds.keywordsTooltipLabel), findsOneWidget);      
      });

      // "Finds the delete tooltip label"
      testWidgets("Finds the delete tooltip label", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition 
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Verifies delete tooltip present
        expect(find.byTooltip(lds.deleteTooltipLabel), findsOneWidget);      
      });
    });
    
    group("Preview Tests: \n", () 
    { 
      // "Opens the CA preview"
      testWidgets("Opens the CA preview", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Preview tooltip 
        var previewTooltipFinder = find.byTooltip(lds.previewTooltipLabel);
        await tester.tap(previewTooltipFinder);
        await tester.pumpAndSettle();
        // Verifies title level 2 present
        expect(find.text(testDataMessage), findsOneWidget);
      });

      // "Opens the GPS preview"
      testWidgets("Opens the GPS preview", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.gpsContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Preview tooltip 
        var previewTooltipFinder = find.byTooltip(lds.previewTooltipLabel);
        await tester.tap(previewTooltipFinder);
        await tester.pumpAndSettle();
        // Verifies text
        expect(find.textContaining(testDataMessage), findsOneWidget);
      });
    
    });

    group("Edit Tests: \n", () 
    { 
      // "Shows the placeholder message"
      // testWidgets("Shows the placeholder message", (WidgetTester tester) async {
      //   await tester.pumpWidget(
      //     MaterialApp(
      //       home: Scaffold(
      //         body: SessionsListItem(
      //           sessionMetadata: testMetadata,
      //           index: 0,
      //           isChecked: false,
      //           dashboardContext: DashboardUtils.caContext, 
      //           onCheckboxChangedCallbackFunction: (_) {},
      //           onEditTitleCallbackFunction: () {},
      //           onEditSessionCallbackFunction: () {},
      //           onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
      //           onDeleteCallbackFunction: () {},
      //         ),
      //       ),
      //     ),
      //   );

      //   // Edit tooltip 
      //   var editTooltipFinder = find.byTooltip(editTooltipLabel);
      //   await tester.tap(editTooltipFinder);
      //   await tester.pumpAndSettle();
       
      //   // Verifies placeholder message
      //   expect(find.text(placeholderForEdit), findsOneWidget);
      // });
    });  
  
    group("Keywords Tests: \n", () 
    {
      // "Opens the keywords edition overlay by clicking on the icon"
      testWidgets("Opens the keywords edition overlay by clicking on the icon", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Keywords tooltip 
        var keywordsTooltipFinder = find.byTooltip(lds.keywordsTooltipLabel);
        await tester.tap(keywordsTooltipFinder);
        await tester.pumpAndSettle();
        // Verifies text field label present
        expect(find.text(lds.keywordsTextFieldLabel), findsOneWidget);
      });


    // "Opens the keywords edition overlay by clicking on the keywords data"
      testWidgets("Opens the keywords edition overlay by clicking on the keywords data", (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                sessionDataIndex: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChangedCallbackFunction: (_) {},
                onEditTitleCallbackFunction: () {},
                onEditPressedCallbackFunction: () {},
                onRetrievedSessionDataBeforeEditionCallbackFunction: 
                ({
                  required String dashboardContext,
                  required bool isSessionDataBeingEdited, 
                  required String titleWhenEdition, 
                  required Set<String> keywordsWhenEdition,
                  required Object dtoWhenEdition, 
                  required String fileNameWithoutExtensionWhenEdition,
                  required String filePathWhenEdition
                }) {},
                onKeywordsUpdatedCallbackFunction: ({required String? filePath, required Set<String> updatedKeywords}) async {},
                onDeleteCallbackFunction: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Getting the localized strings
        var context = tester.element(find.byType(Scaffold).first);
        LocalizedDashboardStrings lds = .new(context);

        // Keywords data 
        var keywordsDataFinder = find.byKey(const Key("session-keywords-0"));
        await tester.tap(keywordsDataFinder);
        await tester.pumpAndSettle();
        // Verifies text field label present
        expect(find.text(lds.keywordsTextFieldLabel), findsOneWidget);
      });
    });
  
  }); 
}