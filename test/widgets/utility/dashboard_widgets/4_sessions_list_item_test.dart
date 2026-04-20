import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/widgets/utility/dashboard_strings.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/4_dashboard_sessions_list_item.dart';

void main() {
  var title = 'Legacy';
  var date = 'March 20, 2026 4:51 PM';
  var keywords = ['Kw', 'Kw2'];

  // Data for the test
  final testMetadata = {
    'title': title,
    'date': date,
    'filePath': null,
    'keywords': keywords,
  };

  // 'SessionsListItem Tests'
  group('SessionsListItem Tests', () 
  {  
    group('Info and tooltips Tests', () 
    { 
      // 'Displays session info correctly (Title, date, keywords)'
      testWidgets('Displays session info correctly (Title, date, keywords)', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                index: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChanged: (_) {},
                onEditTitle: () {},
                onEditKeywords: () {},
                onDelete: () {},
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
                index: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChanged: (_) {},
                onEditTitle: () {},
                onEditKeywords: () {},
                onDelete: () {},
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
                index: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChanged: (_) {},
                onEditTitle: () {},
                onEditKeywords: () {},
                onDelete: () {},
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
                index: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChanged: (_) {},
                onEditTitle: () {},
                onEditKeywords: () {},
                onDelete: () {},
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
                index: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChanged: (_) {},
                onEditTitle: () {},
                onEditKeywords: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        // Verifies delete tooltip present
        expect(find.byTooltip(deleteTooltipLabel), findsOneWidget);      
      });
    });
    
    group('Preview Tests', () 
    { 
      testWidgets('Opens the preview', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SessionsListItem(
                sessionMetadata: testMetadata,
                index: 0,
                isChecked: false,
                dashboardContext: DashboardUtils.caContext, 
                onCheckboxChanged: (_) {},
                onEditTitle: () {},
                onEditKeywords: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        // Preview tooltip 
        var previewTooltipFinder = find.byTooltip(previewTooltipLabel);
        await tester.tap(previewTooltipFinder);
        await tester.pumpAndSettle();
        // Verifies text for absent file path
        expect(find.text('Null file path'), findsOneWidget);
      });
    });  
  });
}