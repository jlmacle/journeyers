import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/test_externalized_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/dashboard_const_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/4_dashboard_sessions_list_item.dart';

void main() {

  var title = 'Legacy';
  var date = 'March 20, 2026 4:51 PM';
  var keywords = ['Kw', 'Kw2'];

  // Data for the test
  final testMetadata = {
    DashboardUtils.keyTitle: title,
    DashboardUtils.keyDate: date,
    DashboardUtils.keyFilePath: pathForTestFile1,
    DashboardUtils.keyKeywords: keywords,
  };

  group('SessionsListItem Tests: \n', () 
  {  
    group('Info and tooltips Tests: \n', () 
    { 
      // 'Displays session info correctly (Title, date, keywords)'
      testWidgets('Displays session info correctly (Title, date, keywords)', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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

        // Verifies title
        expect(find.text(title), findsOneWidget);

        // Verifies date
        var dateFinder = find.byType(Text).at(1);
        Text dateWidget = tester.widget(dateFinder);
        expect(dateWidget.data, '($date)');
        
        // Verifies keywords
        expect(find.text('Keywords: Kw, Kw2'), findsOneWidget);
      });

      // 'Finds the preview tooltip label'
      testWidgets('Finds the preview tooltip label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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

        // Verifies preview tooltip present
        expect(find.byTooltip(previewTooltipLabel), findsOneWidget);      
      });

      // 'Finds the edit tooltip label'
      testWidgets('Finds the edit tooltip label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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

        // Verifies edit tooltip present
        expect(find.byTooltip(editTooltipLabel), findsOneWidget);      
      });

      // 'Finds the keywords tooltip label'
      testWidgets('Finds the keywords tooltip label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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
        // Verifies keywords tooltip present
        expect(find.byTooltip(keywordsTooltipLabel), findsOneWidget);      
      });

      // 'Finds the delete tooltip label'
      testWidgets('Finds the delete tooltip label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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

        // Verifies delete tooltip present
        expect(find.byTooltip(deleteTooltipLabel), findsOneWidget);      
      });
    });
    
    group('Preview Tests: \n', () 
    { 
      // 'Opens the CA preview'
      testWidgets('Opens the CA preview', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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

        // Preview tooltip 
        var previewTooltipFinder = find.byTooltip(previewTooltipLabel);
        await tester.tap(previewTooltipFinder);
        await tester.pumpAndSettle();
        // Verifies title level 2 present
        expect(find.text(testDataMessage), findsOneWidget);
      });

      // 'Opens the GPS preview'
      testWidgets('Opens the GPS preview', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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

        // Preview tooltip 
        var previewTooltipFinder = find.byTooltip(previewTooltipLabel);
        await tester.tap(previewTooltipFinder);
        await tester.pumpAndSettle();
        // Verifies text
        expect(find.textContaining(testDataMessage), findsOneWidget);
      });
    
    });

    group('Edit Tests: \n', () 
    { 
      // 'Shows the placeholder message'
      // testWidgets('Shows the placeholder message', (WidgetTester tester) async {
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
  
    group('Keywords Tests: \n', () 
    {
      // 'Opens the keywords edition overlay by clicking on the icon'
      testWidgets('Opens the keywords edition overlay by clicking on the icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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

        // Keywords tooltip 
        var keywordsTooltipFinder = find.byTooltip(keywordsTooltipLabel);
        await tester.tap(keywordsTooltipFinder);
        await tester.pumpAndSettle();
        // Verifies text field label present
        expect(find.text(keywordsTextFieldLabel), findsOneWidget);
      });


    // 'Opens the keywords edition overlay by clicking on the keywords data'
      testWidgets('Opens the keywords edition overlay by clicking on the keywords data', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
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

        // Keywords data 
        var keywordsDataFinder = find.byKey(const ValueKey('session-keywords-0'));
        await tester.tap(keywordsDataFinder);
        await tester.pumpAndSettle();
        // Verifies text field label present
        expect(find.text(keywordsTextFieldLabel), findsOneWidget);
      });
    });
  
  }); 
}