import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/widgets/utility/dashboard_widgets/4_dashboard_sessions_list_item.dart';

void main() {
  var title = 'Legacy';
  var date = 'March 20, 2026 4:51 PM';
  var keywords = ['Kw', 'Kw2'];

  // Data for the test
  final testMetadata = {
    'title': title,
    'date': date,
    'filePath': '/path/to/file.csv',
    'keywords': keywords,
  };

  group('SessionsListItem Tests', () 
  {  
    testWidgets('Displays session info correctly (Title, date, keywords)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionsListItem(
              sessionMetadata: testMetadata,
              index: 0,
              isChecked: false,
              dashboardContext: DashboardUtils.contextAnalysesContext, 
              onCheckboxChanged: (_) {},
              onEditTitle: () {},
              onEditKeywords: () {},
              onPreview: () {},
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
  });
}