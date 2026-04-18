import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';

import 'package:journeyers/widgets/utility/dashboard_widgets/4_dashboard_session_list_item.dart';

void main() {
  // Data for the test
  final testMetadata = {
    'title': 'Legacy',
    'date': 'March 20, 2026 4:51 PM',
    'filePath': '/path/to/file.csv',
    'keywords': ['Kw', 'Kw2'],
  };

  group('SessionListItem Tests', () 
  {  

    testWidgets('Checkbox reflects isChecked state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionsListItem(
              sessionMetadata: testMetadata,
              index: 0,
              isChecked: true, // Set to true
              dashboardContext: 'standard',
              onCheckboxChanged: (_) {},
              onEditTitle: () {},
              onEditKeywords: () {},
              onPreview: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find the checkbox
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });
  });
}