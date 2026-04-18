import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journeyers/widgets/utility/dashboard_widgets/4_dashboard_session_list_item.dart';

void main() {
  // Data for the test
  final mockSession = {
    'title': 'Morning Run',
    'date': '2023-10-27',
    'filePath': '/path/to/file.gps',
    'keywords': ['Sports', 'Outdoor'],
  };

  group('SessionListItem Tests', () {
    testWidgets('Displays session info correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionsListItem(
              sessionMetadata: mockSession,
              index: 0,
              isChecked: false,
              dashboardContext: 'standard', // Non-GPS context
              onCheckboxChanged: (_) {},
              onEditTitle: () {},
              onEditKeywords: () {},
              onPreview: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify Title and Date
      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('(2023-10-27)'), findsOneWidget);
      
      // Verify Keywords (Sorted)
      expect(find.textContaining('Outdoor, Sports'), findsOneWidget);
    });

    testWidgets('Triggers onDelete callback when delete button is pressed', (WidgetTester tester) async {
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionsListItem(
              sessionMetadata: mockSession,
              index: 0,
              isChecked: false,
              dashboardContext: 'standard',
              onCheckboxChanged: (_) {},
              onEditTitle: () {},
              onEditKeywords: () {},
              onPreview: () {},
              onDelete: () => deleteCalled = true, // Capture the call
            ),
          ),
        ),
      );

      // Find the delete button by Key and tap it
      final deleteBtn = find.byKey(const ValueKey('session-delete-0'));
      await tester.tap(deleteBtn);
      
      expect(deleteCalled, isTrue);
    });

    testWidgets('Checkbox reflects isChecked state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionsListItem(
              sessionMetadata: mockSession,
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